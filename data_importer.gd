extends Node

# Lightweight YAML import system using the Godot YAML addon.
# - Loads schemas (optional)
# - Parses multiple YAML files (supports $schema auto-discovery)
# - Validates against schemas
# - Groups entities by category and resolves simple references

class_name DataImporter

@export var schemas_dir: String = "res://schemas"
@export var data_dirs: Array = ["res://data"]

var _schemas: Dictionary = {}
var _entities: Dictionary = {} # category -> id -> data
var _errors: Array = []
var _validation_reports: Array = []
var _resources: Dictionary = {} # category -> id -> Resource
var _entity_directory: Dictionary = {} # category -> id -> deserialized entity object

var import_order: Array = ["skills", "skillsets", "items", "itemsets", "loot_tables", "npcs", "creatures", "actions", "locations", "stores"]

# Maps field names to their expected reference type (category)
var _reference_type_map: Dictionary = {
	"equip_skill_id": "skills",
	"equip_skill_ids": "skills",
	"action_node_ids": "action-nodes",
	"mob_ids": "mobs",
	"item_ids": "items",
	"inventory_ids": "items",
	"npc_ids": "npcs",
	"skill_ids": "skills",
	"location_ids": "locations",
}

var _entity_class_map: Dictionary = {} # category -> class

func _init() -> void:
	_register_entity_classes()

func _register_entity_classes() -> void:
	YAML.register_class(GameEntity)
	YAML.register_class(Skill)
	YAML.register_class(Item)
	YAML.register_class(Creature)
	YAML.register_class(ActionNode)
	YAML.register_class(Location)
	YAML.register_class(NPC)
	YAML.register_class(SkillSet)
	YAML.register_class(ItemSet)
	YAML.register_class(LootTable)
	YAML.register_class(Store)

	# Map category names to entity classes for conversion
	_entity_class_map = {
		"items": Item,
		"skills": Skill,
		"npcs": NPC,
		"creatures": Creature,
		"action-nodes": ActionNode,
		"locations": Location,
		"skillsets": SkillSet,
		"itemsets": ItemSet,
		"loot_tables": LootTable,
		"stores": Store,
	}

	# Prepare empty registries
	_entity_directory = {}
	_resources = {}


func _ready():
	pass

func clear():
	_schemas.clear()
	_entities.clear()
	_errors.clear()
	_validation_reports.clear()

func import_all():
	"""Main entry: load schemas, then import YAML files from configured data_dirs.
	Returns true on success (no parse/validation errors), false otherwise.
	Stops immediately on any error (fatal mode).
	"""
	clear()
	_load_schemas_from_dir(schemas_dir)

	# Collect files per category then import in order
	var file_map := _collect_data_files(data_dirs)

	# Import in configured order first
	for category in import_order:
		if file_map.has(category):
			_import_files_for_category(category, file_map[category])
			if not _errors.is_empty():
				return false
			file_map.erase(category)

	# Import any remaining categories
	for category in file_map.keys():
		_import_files_for_category(category, file_map[category])
		if not _errors.is_empty():
			return false

	# After all imports, resolve references
	_resolve_references()
	if not _errors.is_empty():
		return false

	# Convert imported intermediate entities into typed Resource objects
	_convert_entities_to_resources()
	if not _errors.is_empty():
		return false

	return true

func _load_schemas_from_dir(dir_path: String) -> void:
	# Attempt to load any .yaml/.yml schema files found in dir_path
	var files := _list_files(dir_path)
	for f in files:
		if f.to_lower().ends_with(".yaml") or f.to_lower().ends_with(".yml"):
			var schema = YAML.load_schema_from_file(f)
			if schema:
				# If the schema has an $id it will be registered globally by the addon
				_schemas[f] = schema

func _collect_data_files(dirs: Array) -> Dictionary:
	# Returns: category -> [file paths]
	var map := {}
	for d in dirs:
		var files := _list_files(d)
		for f in files:
			if not (f.to_lower().ends_with(".yaml") or f.to_lower().ends_with(".yml")):
				continue
			var base := _basename_no_ext(f).to_lower()
			# Use filename as default category (e.g., items.yaml -> items)
			if not map.has(base):
				map[base] = []
			map[base].append(f)
	return map

func _import_files_for_category(category: String, files: Array) -> void:
	if not _entities.has(category):
		_entities[category] = {}
	for f in files:
		var content: Variant = _read_file_text(f)
		if content == null:
			_errors.append("Failed to read: %s" % f)
			continue

		# If schema auto-discovery is desired, call parse_and_validate without schema
		var result = YAML.parse_and_validate(content)
		if result.has_error():
			_errors.append("Parse error in %s: %s" % [f, result.get_error()])
			continue

		if result.has_validation_errors():
			# Build human-friendly, structured validation errors
			var raw_errors := []
			for err in result.get_validation_errors():
				var ev := {
					"message": err.message,
					"instance_path": err.instance_path,
					"keyword": err.keyword,
					"invalid_value": str(err.invalid_value),
				}
				raw_errors.append(ev)

			var report = {
				"file": f,
				"summary": result.get_validation_summary(),
				"count": result.get_validation_error_count(),
				"errors": raw_errors,
			}
			_validation_reports.append(report)
			_errors.append("Validation errors in %s:\n%s" % [f, report.summary])
			# continue parsing but still record data (optional)

		# Support multi-document or single document
		if result.has_multiple_documents():
			for i in range(result.get_document_count()):
				var doc = result.get_document(i)
				_store_entities_from_doc(category, doc, f)
		else:
			var data = result.get_data()
			_store_entities_from_doc(category, data, f)

func _store_entities_from_doc(category: String, data, source_path: String) -> void:
	# Expect either an array of entities or a map of id->entity, or a single entity
	if typeof(data) == TYPE_ARRAY:
		for e in data:
			_store_single_entity(category, e, source_path)
	elif typeof(data) == TYPE_DICTIONARY:
		# If dictionary contains a top-level list key like the category name (e.g. 'items') or 'entities', use it
		if (data.has(category) and typeof(data[category]) == TYPE_ARRAY):
			for e in data[category]:
				_store_single_entity(category, e, source_path)
			return
		if data.has("entities") and typeof(data.entities) == TYPE_ARRAY:
			for e in data.entities:
				_store_single_entity(category, e, source_path)
			return

		# If it looks like a mapping of id->entity (all values are dicts), store them
		var all_dicts := true
		for key in data.keys():
			if typeof(data[key]) != TYPE_DICTIONARY:
				all_dicts = false
				break
		if all_dicts:
			for key in data.keys():
				var entity = data[key]
				entity["id"] = entity.get("id", key)
				_store_single_entity(category, entity, source_path)
			return

		# Otherwise, treat the dictionary itself as a single entity
		_store_single_entity(category, data, source_path)
	else:
		_errors.append("Unsupported YAML root type in %s" % source_path)

func _store_single_entity(category: String, entity: Dictionary, source_path: String) -> void:
	if typeof(entity) != TYPE_DICTIONARY:
		_errors.append("Invalid entity format in %s: expected map/dict" % source_path)
		return

	var id = entity.get("id", null)
	if id == null:
		# Try name or generate synthetic id
		id = entity.get("name", null)
		if id == null:
			id = "%s_%d" % [category, randi()]
	id = str(id)
	_entities[category][id] = entity.duplicate(true)

func _resolve_references() -> void:
	# Reference validation with type checking (no duplication):
	# - Use _reference_type_map to constrain reference types
	# - field names ending with _id or _ref refer to single entity id
	# - arrays named *_ids or *_refs contain ids
	# Entities are stored once; references are validated but not duplicated.
	for category in _entities.keys():
		for id in _entities[category].keys():
			var ent = _entities[category][id]
			for key in ent.keys():
				var val = ent[key]
				if typeof(val) == TYPE_STRING and (key.ends_with("_id") or key.ends_with("_ref")):
					var expected_type = _reference_type_map.get(key, null)
					var target = _find_entity_by_any_category(val, expected_type)
					if target == null:
						_errors.append("Unresolved reference: %s.%s -> %s" % [category, id, val])

				elif typeof(val) == TYPE_ARRAY and (key.ends_with("_ids") or key.ends_with("_refs")):
					var expected_type = _reference_type_map.get(key, null)
					for ref in val:
						var target = _find_entity_by_any_category(ref, expected_type)
						if target == null:
							_errors.append("Unresolved reference in array: %s.%s -> %s" % [category, id, str(ref)])

func _find_entity_by_any_category(id_or_name: String, expected_type: Variant = null):
	# Try exact category:id match (category:id) first
	if id_or_name.find(":") != -1:
		var parts = id_or_name.split(":", false, 2)
		if parts.size() >= 2:
			var cat = parts[0]
			var eid = parts[1]
			if _entities.has(cat) and _entities[cat].has(eid):
				var entity = _entities[cat][eid]
				# Validate type if specified
				if expected_type != null and not _validate_entity_type(entity, cat, expected_type):
					return null
				return entity

	# Otherwise search across categories by id or name, respecting type constraint
	for cat in _entities.keys():
		if expected_type != null and cat != expected_type:
			continue  # Skip categories that don't match expected type
		if _entities[cat].has(id_or_name):
			return _entities[cat][id_or_name]
		# try by name field
		for e in _entities[cat].values():
			if typeof(e) == TYPE_DICTIONARY and e.get("name", "") == id_or_name:
				return e
	return null

func get_converted_resource(category: String, id: String):
	if _resources.has(category):
		return _resources[category].get(id, null)
	return null

func get_converted_resource_by_identifier(id_or_name: String):
	# Accept forms "category:id" or plain id/name and search converted resources
	if id_or_name.find(":") != -1:
		var parts = id_or_name.split(":", false, 2)
		if parts.size() >= 2:
			return get_converted_resource(parts[0], parts[1])

	for cat in _resources.keys():
		if _resources[cat].has(id_or_name):
			return _resources[cat][id_or_name]
		for r in _resources[cat].values():
			if r != null and typeof(r) == TYPE_OBJECT:
				if r.name == id_or_name:
					return r
	return null

func _get_resource_or_log(category: String, id: String, owner_category: String, owner_id: String):
	# Return a converted resource or log an error; owner_category/owner_id are used for error context
	var r = get_converted_resource(category, id)
	if r == null:
		_errors.append("Unresolved %s %s referenced by %s %s" % [category, id, owner_category, owner_id])
	return r

func _resolve_and_append_array(target: Array, category: String, id: String, owner_category: String, owner_id: String) -> void:
	var r = _get_resource_or_log(category, id, owner_category, owner_id)
	if r != null:
		target.append(r)

func _get_resource_by_identifier_or_log(id_or_name: String, owner_category: String, owner_id: String):
	var r = get_converted_resource_by_identifier(id_or_name)
	if r == null:
		_errors.append("Unresolved identifier %s referenced by %s %s" % [id_or_name, owner_category, owner_id])
	return r

func _convert_entities_to_resources() -> void:
	# Two-pass conversion to avoid circular reference problems:
	# Pass 1: deserialize all raw entries into entity objects and register in _entity_directory
	_entity_directory.clear()
	for cat in _entities.keys():
		_entity_directory[cat] = {}
		for id in _entities[cat].keys():
			var raw = _entities[cat][id]
			var cls = _entity_class_map.get(cat, null)
			if cls != null and cls.has_method("deserialize"):
				var obj = cls.deserialize(raw)
				if obj == null:
					_errors.append("Failed to deserialize entity %s:%s" % [cat, id])
					continue
				_entity_directory[cat][id] = obj
			else:
				# Keep raw dict available but note we can't convert to typed object
				_errors.append("No class for category %s; cannot create object for %s" % [cat, id])

	# Pass 2a: create resource shells for every entity (no cross-linking yet)
	_resources.clear()
	for cat in _entity_directory.keys():
		_resources[cat] = {}
		for id in _entity_directory[cat].keys():
			var obj = _entity_directory[cat][id]
			if obj.has_method("create_resource_shell"):
				var shell = obj.create_resource_shell()
				if shell == null:
					_errors.append("create_resource_shell returned null for %s:%s" % [cat, id])
					continue
				shell.id = id
				_resources[cat][id] = shell
			else:
				_errors.append("Entity %s:%s missing create_resource_shell" % [cat, id])

	# Pass 2b: populate resource references now that all shells exist
	for cat in _entity_directory.keys():
		for id in _entity_directory[cat].keys():
			var obj = _entity_directory[cat][id]
			var shell = _resources[cat].get(id, null)
			if shell == null:
				continue
			if obj.has_method("populate_resource"):
				obj.populate_resource(shell, self)
			# else no-op

func get_resources(category: String) -> Dictionary:
	return _resources.get(category, {}).duplicate()

func _validate_entity_type(entity: Variant, category: String, expected_type: String) -> bool:
	# Check if entity belongs to expected type category
	if category == expected_type:
		return true
	# If entity has a get_entity_type method, use it
	if typeof(entity) == TYPE_OBJECT and entity.has_method("get_entity_type"):
		return entity.get_entity_type() == expected_type
	return false

func get_entities(category: String) -> Dictionary:
	return _entities.get(category, {})

func get_entity(category: String, id: String) -> Variant:
	"""Query a single entity by category and id. Returns null if not found."""
	if _entities.has(category):
		return _entities[category].get(id, null)
	return null

func query(category: String, id: String) -> Variant:
	"""Convenience alias for get_entity()."""
	return get_entity(category, id)

func get_errors() -> Array:
	return _errors.duplicate()

func get_validation_reports() -> Array:
	return _validation_reports.duplicate()

# -------------------- Helpers --------------------
func _read_file_text(path: String) -> Variant:
	var f = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var txt = f.get_as_text()
	f.close()
	return txt

func _basename_no_ext(path: String) -> String:
	var n = path.get_file()
	var dot = n.rfind('.') #n.find_last('.')
	if dot == -1:
		return n
	return n.substr(0, dot)

func _list_files(path: String) -> Array:
	var out := []
	var dir = DirAccess.open(path)
	if dir == null:
		return out
	dir.list_dir_begin()
	while true:
		var entry_name = dir.get_next()
		if entry_name == "":
			break
		var full = path + "/" + entry_name
		if dir.current_is_dir():
			out += _list_files(full)
		else:
			out.append(full)
	dir.list_dir_end()
	return out

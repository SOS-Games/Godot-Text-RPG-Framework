class_name Creature extends GameEntity

var level: int

func _init(p_id: String = "", p_name: String = "", p_level: int = 0) -> void:
	super(p_id, p_name)
	level = p_level

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("Creature expects Dictionary")
	var d: Dictionary = data
	return Creature.new(d.get("id", ""), d.get("name", ""), d.get("level", 0))

func serialize() -> Dictionary:
	var base = super.serialize()
	base["level"] = level
	return base

func get_entity_type() -> String:
	return "creatures"

func create_resource_shell() -> Resource:
	var shell := CreatureData.new()
	shell.id = id
	shell.name = _name
	shell.level = level
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	# Resolve loot_table and skillset references
	# These would come from raw entity data stored during deserialization
	# For now, a placeholder for future implementation
	return


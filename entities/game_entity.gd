class_name GameEntity extends Node

var id: String
#var name: String # name is already declared in Node

func _init(p_id: String = "", name: String = "") -> void:
	id = p_id
	#name = name

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("GameEntity expects Dictionary")
	var d: Dictionary = data
	return GameEntity.new(d.get("id", ""), d.get("name", ""))

func serialize() -> Dictionary:
	return {"id": id, "name": name}

func get_entity_type() -> String:
	return "entity"

func to_resource(converter: Object = null) -> Resource:
	# This is the canonical conversion entry point. Child classes must override.
	push_error("Error: to_resource must be implemented in child class.")
	return null

func create_resource_shell() -> Resource:
	# Return a minimal Resource instance (id/name) for this entity. Child classes must override.
	push_error("Error: create_resource_shell must be implemented in child class.")
	return null

func populate_resource(res: Resource, importer: Object) -> void:
	# Populate cross-references on an already-created Resource shell. Child classes override as needed.
	return

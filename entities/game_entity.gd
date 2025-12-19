class_name GameEntity extends Node

var _id: String
var _name: String # name is already declared in Node

func _init(p_id: String = "", p_name: String = "") -> void:
	_id = p_id
	_name = p_name

# note: you better get these deserialize fields right!
# they should be the same as the fields in the yaml file, not the fields in the data class!
# the fields in _init() are the same ones as the ones defined here in deserialize()
static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("GameEntity expects Dictionary")
	var d: Dictionary = data
	return GameEntity.new(d.get("id", ""), d.get("name", ""))

func serialize() -> Dictionary:
	return {"id": _id, "name": _name}

func get_entity_type() -> String:
	return "entity"

#func to_resource(converter: Object = null) -> Resource:
#	# This is the canonical conversion entry point. Child classes must override.
#	push_error("Error: to_resource must be implemented in child class.")
#	return null

func create_resource_shell() -> Resource:
	# Return a minimal Resource instance (id/name) for this entity. Child classes must override.
	push_error("Error: create_resource_shell must be implemented in child class.")
	return null

func populate_resource(res: Resource, importer: Object) -> void:
	# Populate cross-references on an already-created Resource shell. Child classes override as needed.
	return

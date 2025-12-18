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

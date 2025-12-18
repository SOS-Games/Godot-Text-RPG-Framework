class_name Location extends GameEntity

var action_node_ids: Array
var mob_ids: Array

func _init(p_id: String = "", p_name: String = "", p_action_node_ids: Array = [], p_mob_ids: Array = []) -> void:
	super(p_id, p_name)
	action_node_ids = p_action_node_ids.duplicate()
	mob_ids = p_mob_ids.duplicate()

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("Location expects Dictionary")
	var d: Dictionary = data
	var action_ids = d.get("action_node_ids", [])
	if typeof(action_ids) != TYPE_ARRAY:
		action_ids = []
	var mob_ids_data = d.get("mob_ids", [])
	if typeof(mob_ids_data) != TYPE_ARRAY:
		mob_ids_data = []
	return Location.new(d.get("id", ""), d.get("name", ""), action_ids, mob_ids_data)

func serialize() -> Dictionary:
	var base = super.serialize()
	base["action_node_ids"] = action_node_ids
	base["mob_ids"] = mob_ids
	return base

func get_entity_type() -> String:
	return "locations"

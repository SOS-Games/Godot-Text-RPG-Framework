class_name ActionNode extends GameEntity

var _drop: String
var _max_hp: int
var _type: String

func _init(p_id: String = "", p_name: String = "", p_drop: String = "", p_max_hp: int = 100, p_type: String = "") -> void:
	super(p_id, p_name)
	_drop = p_drop
	_max_hp = p_max_hp
	_type = p_type

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("ActionNode expects Dictionary")
	var d: Dictionary = data
	return ActionNode.new(d.get("id", ""), d.get("name", ""), d.get("drop", ""), d.get("max_hp", 100), d.get("type", ""))

func serialize() -> Dictionary:
	var base = super.serialize()
	base["drop"] = _drop
	base["max_hp"] = _max_hp
	base["type"] = _type
	return base

func get_entity_type() -> String:
	return "action_nodes"

func create_resource_shell() -> Resource:
	var shell := ActionData.new()
	shell.id = _id
	shell.name = _name
	#shell.drop # This is a placeholder for the actual drop resource
	shell.max_hp = _max_hp
	shell.type = _type
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	if _drop != "":
		var resolved = importer._get_resource_or_log("items", _drop, _id)
		if resolved != null:
			res.drop = resolved

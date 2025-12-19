class_name ActionNode extends GameEntity

var _drop: String

func _init(p_id: String = "", p_name: String = "", p_drop: String = "") -> void:
	super(p_id, p_name)
	_drop = p_drop

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("ActionNode expects Dictionary")
	var d: Dictionary = data
	return ActionNode.new(d.get("id", ""), d.get("name", ""), d.get("drop", ""))

func serialize() -> Dictionary:
	var base = super.serialize()
	base["drop"] = _drop
	return base

func get_entity_type() -> String:
	return "action-nodes"

func create_resource_shell() -> Resource:
	var shell := ActionData.new()
	shell.id = _id
	shell.name = _name
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	if _drop != "":
		var resolved = importer._get_resource_or_log("items", _drop, _id)
		if resolved != null:
			res.drop = resolved
	# Future: populate loot_table and req_skillset references from raw data
	return

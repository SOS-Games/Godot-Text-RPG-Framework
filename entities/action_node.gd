class_name ActionNode extends GameEntity

var resource: String

func _init(p_id: String = "", p_name: String = "", p_resource: String = "") -> void:
	super(p_id, p_name)
	resource = p_resource

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("ActionNode expects Dictionary")
	var d: Dictionary = data
	return ActionNode.new(d.get("id", ""), d.get("name", ""), d.get("resource", ""))

func serialize() -> Dictionary:
	var base = super.serialize()
	base["resource"] = resource
	return base

func get_entity_type() -> String:
	return "action-nodes"

class_name ActionNode extends GameEntity

var drop: String

func _init(p_id: String = "", p_name: String = "", p_drop: String = "") -> void:
	super(p_id, p_name)
	drop = p_drop

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("ActionNode expects Dictionary")
	var d: Dictionary = data
	return ActionNode.new(d.get("id", ""), d.get("name", ""), d.get("drop", ""))

func serialize() -> Dictionary:
	var base = super.serialize()
	base["drop"] = drop
	return base

func get_entity_type() -> String:
	return "action-nodes"

func create_resource_shell() -> Resource:
	var shell = ActionData.new()
	shell.id = id
	shell.name = name
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	if drop != "":
		var resolved = importer._get_resource_or_log("items", drop, id)
		if resolved != null:
			res.drop = resolved
	# Future: populate loot_table and req_skillset references from raw data
	return

class_name NPC extends GameEntity

func _init(p_id: String = "", p_name: String = "") -> void:
	super(p_id, p_name)

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("NPC expects Dictionary")
	var d: Dictionary = data
	return NPC.new(d.get("id", ""), d.get("name", ""))

func serialize() -> Dictionary:
	var base = super.serialize()
	return base

func get_entity_type() -> String:
	return "npcs"

func create_resource_shell() -> Resource:
	var shell := NPCData.new()
	shell.id = _id
	shell.name = _name
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	# Extend this to populate NPC-specific references (equipment_set, skillset)
	# These would be resolved from the loaded resources during second pass
	return


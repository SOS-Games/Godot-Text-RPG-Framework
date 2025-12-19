class_name Item extends GameEntity

var equip_skill_id: String

func _init(p_id: String = "", p_name: String = "", p_equip_skill_id: String = "") -> void:
	super(p_id, p_name)
	equip_skill_id = p_equip_skill_id

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("Item expects Dictionary")
	var d: Dictionary = data
	return Item.new(d.get("id", ""), d.get("name", ""), d.get("equip_skill_id", ""))

func serialize() -> Dictionary:
	var base = super.serialize()
	base["equip_skill_id"] = equip_skill_id
	return base

func get_entity_type() -> String:
	return "items"

func create_resource_shell() -> Resource:
	var shell = ItemData.new()
	shell.id = id
	shell.name = name
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	# Resolve equip_skill reference into a SkillData resource
	if equip_skill_id != "":
		var skill_res = importer._get_resource_or_log("skills", equip_skill_id, id)
		if skill_res != null:
			res.equip_skill = skill_res

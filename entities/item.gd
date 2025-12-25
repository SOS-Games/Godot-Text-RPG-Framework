class_name Item extends GameEntity

var _equip_skill_id: String
var _equip_slot: String

func _init(p_id: String = "", p_name: String = "", p_equip_skill_id: String = "", p_equip_slot: String = "") -> void:
	super(p_id, p_name)
	_equip_skill_id = p_equip_skill_id
	_equip_slot = p_equip_slot

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("Item expects Dictionary")
	var d: Dictionary = data
	return Item.new(d.get("id", ""), d.get("name", ""), d.get("equip_skill_id", ""), d.get("equip_slot", ""))

func serialize() -> Dictionary:
	var base = super.serialize()
	base["equip_skill_id"] = _equip_skill_id
	base["equip_slot"] = _equip_slot
	return base

func get_entity_type() -> String:
	return "items"

func create_resource_shell() -> Resource:
	var shell := ItemData.new()
	shell.id = _id
	shell.name = _name
	shell.equip_skill = null
	shell.equip_slot = Utils.EquipSlot.NONE
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	# Resolve equip_skill reference into a SkillData resource
	if _equip_skill_id != "":
		var skill_res = importer._get_resource_or_log("skills", _equip_skill_id, _id)
		if skill_res != null:
			res.equip_skill = skill_res

	# validate equip_slot
	if _equip_slot != "":
		res.equip_slot = Utils.get_equip_slot(_equip_slot, importer)
		var valid_slots = ["head", "body", "shoe", "primary_hand", "offhand"]
		if not _equip_slot in valid_slots:
			# throw error if slot is invalid
			return YAMLResult.error("Invalid equip_slot: " + _equip_slot)

class_name ItemSet extends GameEntity

var _slots: Dictionary

func _init(p_id: String = "", p_name: String = "", p_slots: Dictionary = {}) -> void:
	super(p_id, p_name)
	_slots = p_slots

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("ItemSet expects Dictionary")
	var d: Dictionary = data
	return ItemSet.new(d.get("id", ""), d.get("name", ""), d.get("slots", {}))

func serialize() -> Dictionary:
	var base = super.serialize()
	return base

func get_entity_type() -> String:
	return "itemsets"

func create_resource_shell() -> Resource:
	var shell := ItemSetData.new()
	shell.id = _id
	shell.name = _name
	shell.head_slot = null
	shell.body_slot = null
	shell.shoe_slot = null
	shell.primary_hand_slot = null
	shell.offhand_slot = null
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	var _res: ItemSetData = res
	# Resolve slots
	for slot in _slots:
		# todo: this is not a simple object. this wont work:
		var item_id = _slots[slot]
		var item_res = importer._get_resource_or_log("items", item_id, _id)
		if item_res == null:
			continue

		if slot == "head":
			_res.head_slot = item_res
		elif slot == "body":
			_res.body_slot = item_res
		elif slot == "shoe":
			_res.shoe_slot = item_res
		elif slot == "primary_hand":
			_res.primary_hand_slot = item_res
		elif slot == "offhand":
			_res.offhand_slot = item_res
			
	res = _res
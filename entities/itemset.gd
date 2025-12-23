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
	shell.slots = []
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	# Resolve slots
	for slot_id in _slots:
		# todo: this is not a simple object. this wont work:
		importer._resolve_and_append_array("slots", slot_id, _id, res.slots)

class_name LootTable extends GameEntity

var _drops: Array

func _init(p_id: String = "", p_name: String = "", p_drops = []) -> void:
	super(p_id, p_name)
	self._drops = p_drops

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("LootTable expects Dictionary")
	var d: Dictionary = data
	return LootTable.new(d.get("id", ""), d.get("name", ""), d.get("drops", []))

func serialize() -> Dictionary:
	var base = super.serialize()
	return base

func get_entity_type() -> String:
	return "loot_tables"

func create_resource_shell() -> Resource:
	var shell := LootTableData.new()
	shell.id = _id
	shell.name = _name
	shell.drops = []
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	for drop in _drops:
		var _drop := LootDrop.new()
		var _drop_id = drop.get("item_id", "")
		_drop.item = importer._get_resource_or_log("items", _drop_id, _id)
		_drop.chance = drop.get("chance", 1.0)
		_drop.min_quantity = drop.get("min_quantity", 1)
		_drop.max_quantity = drop.get("max_quantity", 1)
		res.drops.append(_drop)
		# we only need to resolve drops.item_id, the rest are plain data
		# are loot drops a resource?

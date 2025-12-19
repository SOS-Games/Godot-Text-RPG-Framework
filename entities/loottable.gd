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
	pass
	#for drop in _drops:
	#	importer._resolve_and_append_array("items", drop, _id, res.drops)

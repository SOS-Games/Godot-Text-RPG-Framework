class_name Store extends GameEntity

func _init(p_id: String = "", p_name: String = "") -> void:
	super(p_id, p_name)

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("Store expects Dictionary")
	var d: Dictionary = data
	return Store.new(d.get("id", ""), d.get("name", ""))

func serialize() -> Dictionary:
	var base = super.serialize()
	return base

func get_entity_type() -> String:
	return "stores"

func create_resource_shell() -> Resource:
	var shell := StoreData.new()
	shell.id = id
	shell.name = _name
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	# To be extended: populate store references
	return


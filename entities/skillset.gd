class_name SkillSet extends GameEntity

func _init(p_id: String = "", p_name: String = "") -> void:
	super(p_id, p_name)

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("SkillSet expects Dictionary")
	var d: Dictionary = data
	return SkillSet.new(d.get("id", ""), d.get("name", ""))

func serialize() -> Dictionary:
	var base = super.serialize()
	return base

func get_entity_type() -> String:
	return "skillsets"

func create_resource_shell() -> Resource:
	var shell = SkillSetData.new()
	shell.id = id
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	# To be extended: populate skill entries from raw data
	return


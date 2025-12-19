class_name SkillSet extends GameEntity

var skills: Array

func _init(p_id: String = "", p_name: String = "", p_skills: Array = []) -> void:
	super(p_id, p_name)
	skills = p_skills

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
	var shell := SkillSetData.new()
	shell.id = id
	shell.name = _name
	shell.skills = []
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	# Resolve action nodes
	for skill_id in skills:
		importer._resolve_and_append_array("skills", skill_id, id, res.skills)

	# To be extended: populate skill entries from raw data
	return

class_name Skill extends GameEntity

var level: int

func _init(p_id: String = "", p_name: String = "", p_level: int = 0) -> void:
	super(p_id, p_name)
	level = p_level

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("Skill expects Dictionary")
	var d: Dictionary = data
	return Skill.new(d.get("id", ""), d.get("name", ""), d.get("level", 0))

func serialize() -> Dictionary:
	var base = super.serialize()
	base["level"] = level
	return base

func get_entity_type() -> String:
	return "skills"

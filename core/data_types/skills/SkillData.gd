extends ResourceData

class_name SkillData

@export var level: int = 0

func fields_to_string(show_class = true) -> String:
	return "SkillData  %s  level=%d" % [super.fields_to_string(false), level]

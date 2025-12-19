extends ResourceData

class_name SkillSetData

# Array of skill entries with skill resources and their levels
@export var skills: Array[SkillEntry] = []

func fields_to_string(show_class = true) -> String:
	return "SkillSetData  id=%s  name=%s  skills=%s" % [id, name, get_attr_array("skills")]
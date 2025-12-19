extends UnitData

class_name NPCData

@export var is_talkable: bool = true
@export var is_hostile: bool = false
@export var equipment_set: ItemSetData = null
@export var skillset: SkillSetData = null
@export var dialogue_id: String = ""

func fields_to_string(show_class = true) -> String:
	var myfields = "%s  is_talkable=%s  is_hostile=%s  equipment_set=%s  skillset=%s  dialogue_id=%s" % [super.fields_to_string(false), is_talkable, is_hostile, get_attr("equipment_set"), get_attr("skillset"), dialogue_id]

	if show_class:
		return "NPCData  " + myfields
	else:
		return myfields
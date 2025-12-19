extends ResourceData

class_name ItemData

@export var sell_price: int = 0
@export var equip_skill: SkillData = null

func fields_to_string(show_class = true) -> String:
	return "ItemData  id=%s  name=%s  sell_price=%d  equip_skill=%s" % [id, name, sell_price, get_attr("equip_skill")]
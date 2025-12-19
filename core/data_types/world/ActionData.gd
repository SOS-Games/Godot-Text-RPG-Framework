extends ResourceData

class_name ActionData

@export var drop: ItemData = null
@export var loot_table: LootTableData = null
@export var req_skillset: SkillSetData = null

func fields_to_string(show_class = true) -> String:
	return "ActionData  %s  drop=%s  loot_table=%s  req_skillset=%s" % [super.fields_to_string(false), get_attr("drop"), get_attr("loot_table"), get_attr("req_skillset")]
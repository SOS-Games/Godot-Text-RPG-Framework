extends ResourceData

class_name ActionData

@export var drop: ItemData = null
@export var loot_table: LootTableData = null
@export var req_skillset: SkillSetData = null
@export var max_hp: int = 0
@export var type: String = ""

func fields_to_string(show_class = true) -> String:
	return "ActionData  %s  drop=%s  loot_table=%s  req_skillset=%s  max_hp=%s  type=%s" % [super.fields_to_string(false), get_attr("drop"), get_attr("loot_table"), get_attr("req_skillset"), max_hp, type]
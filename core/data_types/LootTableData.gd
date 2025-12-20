extends ResourceData

class_name LootTableData

# Array of typed loot drops
@export var drops: Array[LootDrop] = []

func fields_to_string(show_class = true) -> String:
	return "LootTableData  %s  drops=%s" % [super.fields_to_string(false), get_attr_array("drops", "item", "id")]

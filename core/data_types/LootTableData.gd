extends ResourceData

class_name LootTableData

# Array of typed loot drops
@export var drops: Array[LootDrop] = []

func fields_to_string(show_class = true) -> String:
	return "LootTableData  id=%s  name=%s  drops=%s" % [id, name, drops.size()]

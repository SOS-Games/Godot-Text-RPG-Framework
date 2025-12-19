extends ResourceData

class_name UnitData
	
@export var max_health: int = 100
@export var base_attack: int = 0
@export var base_defense: int = 0

func take_damage(amount: int) -> void:
	max_health = max(0, max_health - amount)

func fields_to_string(show_class = true) -> String:
	var myfields = "%s  max_health=%s  base_attack=%s  base_defense=%s" % [super.fields_to_string(false), max_health, base_attack, base_defense]

	if show_class:
		return "UnitData  " + myfields
	else:
		return myfields
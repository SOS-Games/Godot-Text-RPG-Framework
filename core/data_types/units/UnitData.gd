extends Resource

class_name UnitData

@export var id: String = ""
@export var name: String = ""
@export var max_health: int = 100
@export var base_attack: int = 0
@export var base_defense: int = 0

func take_damage(amount: int) -> void:
    max_health = max(0, max_health - amount)

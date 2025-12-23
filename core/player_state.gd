extends Node

const PROTOSET = preload("res://addons/gloot/tests/data/protoset_basic.json")

var inventory: Inventory
var equipment: Inventory
var player_id: String = ""
var player_name: String = "Player"
var current_location_id: String = "locations:forest"

func _ready():
    inventory = Inventory.new()
    inventory.name = "player_inventory"
    inventory.protoset = PROTOSET
    add_child(inventory)

    equipment = Inventory.new()
    equipment.name = "player_equipment"
    equipment.protoset = PROTOSET
    add_child(equipment)

func save_to_player_data(player_data: PlayerSaveData) -> void:
    if player_data == null:
        return
    if inventory != null:
        player_data.inventory_data = inventory.serialize()
    if equipment != null:
        player_data.equipment_data = equipment.serialize()

func get_player_save_data() -> PlayerSaveData:
    var pd = PlayerSaveData.new()
    pd.player_id = player_id if player_id != "" else str(randi())
    pd.player_name = player_name
    pd.current_location_id = current_location_id
    save_to_player_data(pd)
    return pd

func load_from_player_data(player_data: PlayerSaveData) -> void:
    if player_data == null:
        return
    if inventory != null and player_data.inventory_data and player_data.inventory_data.size() > 0:
        inventory.deserialize(player_data.inventory_data)
    if equipment != null and player_data.equipment_data and player_data.equipment_data.size() > 0:
        equipment.deserialize(player_data.equipment_data)

func apply_player_save_data(player_data: PlayerSaveData) -> void:
    if player_data == null:
        return
    player_id = player_data.player_id
    player_name = player_data.player_name
    current_location_id = player_data.current_location_id
    load_from_player_data(player_data)

func clear() -> void:
    if inventory:
        inventory.clear()
    if equipment:
        equipment.clear()

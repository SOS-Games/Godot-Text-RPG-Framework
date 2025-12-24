extends Node

var inventory: Inventory
var equipment: Node
var slots: Dictionary = {}
var protoset: JSON = null
var player_id: String = ""
var player_name: String = "Player"
var current_location_id: String = "locations:forest"

func _ready():
    inventory = Inventory.new()
    inventory.name = "player_inventory"
    if protoset:
        inventory.protoset = protoset
    add_child(inventory)
    equipment = Node.new()
    equipment.name = "player_equipment"
    add_child(equipment)
    # Create explicit ItemSlot nodes for named equipment slots
    var SlotClass = preload("res://addons/gloot/core/item_slot.gd")
    var slot_names = ["head", "body", "weapon"]
    for sname in slot_names:
        var slot = SlotClass.new()
        slot.name = sname
        slot.slot_name = sname
        if protoset:
            slot.protoset = protoset
        equipment.add_child(slot)
        slots[sname] = slot

func save_to_player_data(player_data: PlayerSaveData) -> void:
    if player_data == null:
        return
    if inventory != null:
        player_data.inventory_data = inventory.serialize()
    # Persist per-slot equipment data
    var eq_slots: Dictionary = {}
    for sname in slots.keys():
        var slot = slots[sname]
        eq_slots[sname] = slot.serialize()
    player_data.equipment_slots_data = eq_slots
    # Keep legacy equipment_data empty for compatibility
    player_data.equipment_data = {}

func set_protoset(json_protoset: JSON) -> void:
    protoset = json_protoset
    if inventory != null:
        inventory.protoset = protoset
    # Apply protoset to equipment slots
    for sname in slots.keys():
        var slot = slots[sname]
        if is_instance_valid(slot):
            slot.protoset = protoset

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
    # Load per-slot equipment data if present
    if player_data.equipment_slots_data and player_data.equipment_slots_data.size() > 0:
        for sname in player_data.equipment_slots_data.keys():
            if slots.has(sname):
                var slot = slots[sname]
                slot.deserialize(player_data.equipment_slots_data[sname])
    elif player_data.equipment_data and player_data.equipment_data.size() > 0:
        # legacy: try to load equipment inventory if present (not implemented)
        pass

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
    for sname in slots.keys():
        var slot = slots[sname]
        slot.clear()

func get_slot(slot_name: String) -> ItemSlot:
    if slots.has(slot_name):
        return slots[slot_name]
    return null

func equip_prototype_to_slot(prototype_id: String, slot_name: String) -> bool:
    if protoset == null:
        return false
    var item := InventoryItem.new(protoset, prototype_id)
    var slot = get_slot(slot_name)
    if slot == null:
        return false
    return slot.equip(item)

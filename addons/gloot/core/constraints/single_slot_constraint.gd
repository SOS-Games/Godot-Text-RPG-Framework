@tool
extends InventoryConstraint
class_name SingleSlotConstraint

@export var slot_name: String = ""

func get_space_for(item: InventoryItem) -> int:
    if item == null:
        return 0
    if not _item_matches_slot(item):
        return 0
    # If there is already an item occupying this slot in the inventory, no space
    for it in inventory.get_items():
        if it == item:
            continue
        if _item_matches_slot(it):
            return 0
    return 1

func has_space_for(item: InventoryItem) -> bool:
    return get_space_for(item) > 0

func _item_matches_slot(item: InventoryItem) -> bool:
    var s = item.get_property("equip_slot", "")
    if typeof(s) == TYPE_STRING and s == slot_name:
        return true
    return false

func serialize() -> Dictionary:
    return {"slot_name": slot_name}

func deserialize(source: Dictionary) -> bool:
    if source.has("slot_name"):
        slot_name = source["slot_name"]
    return true

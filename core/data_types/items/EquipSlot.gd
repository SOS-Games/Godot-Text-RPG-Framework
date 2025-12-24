enum EquipSlot {
    None,
	Head,
	Body,
	Shoe,
	PrimaryHand,
	OffHand
}

# get EquipSlot by string
def get_slot(slot_str: str) -> EquipSlot:
    if slot_str == "head":
        return EquipSlot.Head
    elif slot_str == "body":
        return EquipSlot.Body
    elif slot_str == "shoe":
        return EquipSlot.Shoe
    elif slot_str == "primary_hand":
        return EquipSlot.PrimaryHand
    elif slot_str == "offhand":
        return EquipSlot.OffHand
    else:
        return EquipSlot.None
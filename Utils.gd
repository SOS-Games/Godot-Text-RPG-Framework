extends Node

enum EquipSlot {
	NONE,
	HEAD,
	BODY,
	SHOE,
	PRIMARY_HAND,
	OFF_HAND
}

# get EquipSlot by string
func get_equip_slot(slot_str: String, importer: Object) -> EquipSlot:
	if slot_str == "head":
		return EquipSlot.HEAD
	elif slot_str == "body":
		return EquipSlot.BODY
	elif slot_str == "shoe":
		return EquipSlot.SHOE
	elif slot_str == "primary_hand":
		return EquipSlot.PRIMARY_HAND
	elif slot_str == "offhand":
		return EquipSlot.OFF_HAND
	elif slot_str == "none" or slot_str == "":
		return EquipSlot.NONE
	else:
		importer._errors.append("Invalid EquipSlot string: " + slot_str)
		return EquipSlot.NONE

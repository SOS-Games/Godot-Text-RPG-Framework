extends ResourceData

class_name ItemSetData

@export var head_slot: ItemData = null
@export var body_slot: ItemData = null
@export var shoe_slot: ItemData = null
@export var primary_hand_slot: ItemData = null
@export var offhand_slot: ItemData = null

func fields_to_string(show_class = true) -> String:
	return "ItemSetData  %s  head=%s, body=%s, shoe=%s, primary_hand=%s, offhand=%s" % [super.fields_to_string(false), head_slot, body_slot, shoe_slot, primary_hand_slot, offhand_slot]

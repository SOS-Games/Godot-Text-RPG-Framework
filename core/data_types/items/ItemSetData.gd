extends ResourceData

class_name ItemSetData

@export var slots: Array[ItemSlot] = []

func fields_to_string(show_class = true) -> String:
	return "ItemSetData  %s  slots=%s" % [super.fields_to_string(false), get_attr_array("slots")]

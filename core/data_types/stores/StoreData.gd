extends ResourceData

class_name StoreData

@export var buys: Array[ItemData] = []
@export var sells: Array[ItemData] = []
@export var base_prices: Dictionary = {}

func fields_to_string(show_class = true) -> String:
	return "StoreData  %s  buys=%s  sells=%s  base_prices=%s" % [super.fields_to_string(false), get_attr_array("buys"), get_attr_array("sells"), base_prices]
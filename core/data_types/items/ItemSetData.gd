extends ResourceData

class_name ItemSetData

@export var slots: Array[EquipmentItemSlot] = []
'''
# todo:
itemsets:
  - id: "knight_gear"
    name: "Knight Gear"
    slots:
      head:
        - "iron_helm"
      body:
        - "iron_chest"
      weapon:
        - "iron_sword"
'''
func fields_to_string(show_class = true) -> String:
	return "ItemSetData  %s  slots=%s" % [super.fields_to_string(false), get_attr_array("slots")]

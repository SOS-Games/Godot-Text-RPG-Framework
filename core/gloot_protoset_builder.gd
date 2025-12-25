extends Node

class_name GlootProtosetBuilder

static func build(resources: Dictionary) -> JSON:
	var proto_dict: Dictionary = {}
	if resources == null or not resources.has("items"):
		var empty_json := JSON.new()
		empty_json.parse(JSON.stringify(proto_dict))
		return empty_json

	var items = resources["items"]
	for key in items.keys():
		var item = items[key]
		var entry: Dictionary = {}
		entry["name"] = item.name if (item.has_method("name") or item.name != null) else str(key)
		# Prefer explicit equip_slot on the item resource if present
		if (typeof(item) == TYPE_OBJECT) and item.has_method("get"):
			if item.equip_slot != Utils.EquipSlot.NONE:
				entry["equip_slot"] = str(item.equip_slot)
		'''
		# Fallback to heuristic if not provided
		if slot_val == "":
			slot_val = _infer_equip_slot(item)
		if slot_val != "":
			entry["equip_slot"] = slot_val
		'''
		proto_dict[key] = entry

	var json := JSON.new()
	json.parse(JSON.stringify(proto_dict))
	return json

'''
static func _infer_equip_slot(item) -> String:
	if item == null:
		return ""
	var id = ""
	if item.has_method("get"):
		# ResourceData: id field
		id = str(item.get("id"))
	if id == "":
		id = str(item.name).to_lower()
	var lname = id.to_lower()
	if lname.find("sword") != -1 or lname.find("staff") != -1 or lname.find("staff") != -1 or lname.find("weapon") != -1:
		return "weapon"
	if lname.find("helm") != -1 or lname.find("hat") != -1:
		return "head"
	if lname.find("chest") != -1 or lname.find("robe") != -1 or lname.find("armor") != -1:
		return "body"
	return ""
'''

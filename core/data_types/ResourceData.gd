extends Resource

class_name ResourceData

# base class for all resources, provides common attributes and methods

@export var id: String = ""
@export var name: String = ""

func fields_to_string(show_class = true) -> String:
	var myfields = "id=%s  name=%s" % [id, name]

	if show_class:
		return "ResourceData  " + myfields
	else:
		return myfields

func get_attr(attr) -> String:
	if self.get(attr):
		return "<%s>" % self.get(attr).id
	else:
		return ""

func get_attr_array(attr, field_name = "id", field_name2 = "") -> String:
	var mystring = ""
	mystring += "Array<"
	var datas = self.get(attr)
	for i in range(datas.size()):
		if i > 0:
			mystring += ", "
		if (field_name2 != ""):
			mystring += "%s" % datas[i].get(field_name).get(field_name2)
		else:
			mystring += "%s" % datas[i].get(field_name)
	mystring += ">"
	return mystring

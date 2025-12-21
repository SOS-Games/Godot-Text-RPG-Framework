extends ResourceData

class_name GodData

@export var description: String = ""
@export var followers: String = ""

func fields_to_string(show_class = true) -> String:
	return "GodData  %s  id=%s  name=%s  description=%s  followers=%s" % [super.fields_to_string(false), id, name, description, followers]

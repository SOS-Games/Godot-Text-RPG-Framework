class_name God extends GameEntity

var _description: String
var _followers: String

func _init(p_id: String = "", p_name: String = "", p_description: String = "", p_followers: String = "") -> void:
	super(p_id, p_name)
	_description = p_description
	_followers = p_followers

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("God expects Dictionary")
	var d: Dictionary = data
	return God.new(d.get("id", ""), d.get("name", ""), d.get("description", ""), d.get("followers", ""))

func serialize() -> Dictionary:
	var base = super.serialize()
	base["description"] = _description
	base["followers"] = _followers
	return base

func get_entity_type() -> String:
	return "gods"

func create_resource_shell() -> Resource:
	var shell := GodData.new()
	shell.id = _id
	shell.name = _name
	shell.description = _description
	shell.followers = _followers
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	pass

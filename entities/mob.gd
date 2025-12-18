class_name Mob extends GameEntity

var level: int

func _init(p_id: String = "", p_name: String = "", p_level: int = 0) -> void:
	super(p_id, p_name)
	#print(p_name)
	level = p_level

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("Mob expects Dictionary")
	var d: Dictionary = data
	return Mob.new(d.get("id", ""), d.get("name", ""), d.get("level", 0))

func serialize() -> Dictionary:
	var base = super.serialize()
	base["level"] = level
	return base

func get_entity_type() -> String:
	return "mobs"

func create_resource_shell() -> Resource:
	var shell = CreatureData.new()
	shell.id = id
	shell.name = name
	shell.level = level
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	# No cross-entity refs in basic Mob; extend if drops, loot, etc. are present
	return

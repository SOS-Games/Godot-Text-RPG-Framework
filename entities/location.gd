class_name Location extends GameEntity

var action_node_ids: Array
var unit_ids: Array
var exits: Dictionary

func _init(p_id: String = "", p_name: String = "", p_action_node_ids: Array = [], p_unit_ids: Array = [], p_exits: Dictionary = {}) -> void:
	super(p_id, p_name)
	action_node_ids = p_action_node_ids.duplicate()
	unit_ids = p_unit_ids.duplicate()
	exits = p_exits.duplicate()

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("Location expects Dictionary")
	var d: Dictionary = data
	var action_ids = d.get("action_node_ids", [])
	if typeof(action_ids) != TYPE_ARRAY:
		action_ids = []
	var unit_ids_data = d.get("unit_ids", [])
	if typeof(unit_ids_data) != TYPE_ARRAY:
		unit_ids_data = []
	var exits_map = d.get("exits", {})
	if typeof(exits_map) != TYPE_DICTIONARY:
		exits_map = {}
	return Location.new(d.get("id", ""), d.get("name", ""), action_ids, unit_ids_data, exits_map)

func serialize() -> Dictionary:
	var base = super.serialize()
	base["action_node_ids"] = action_node_ids
	base["unit_ids"] = unit_ids
	return base

func get_entity_type() -> String:
	return "locations"

func create_resource_shell() -> Resource:
	var shell := LocationData.new()
	shell.id = id
	shell.name = _name
	shell.action_nodes = []
	shell.npc_agents = []
	shell.creature_agents = []
	shell.exits = []
	return shell

func populate_resource(res: Resource, importer: Object) -> void:
	# Resolve action nodes
	for action_node_id in action_node_ids:
		importer._resolve_and_append_array("action-nodes", action_node_id, id, res.action_nodes)

	# Resolve creatures (NPCs)
	for unit_id in unit_ids:
		importer._resolve_and_append_array("creatures", unit_id, id, res.creature_agents)
	# Resolve exits (direction -> location id)
	for dir in exits.keys():
		var dest_id = exits[dir]
		var dest = importer._get_resource_or_log("locations", str(dest_id), id)
		if dest != null:
			var exit = LocationExit.new()
			exit.direction = dir
			exit.destination = dest
			res.exits.append(exit)

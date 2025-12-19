extends ResourceData

class_name LocationData

@export var action_nodes: Array[ActionData] = []
@export var npc_agents: Array[NPCData] = []
@export var creature_agents: Array[CreatureData] = []
@export var exits: Array[LocationExit] = []

func fields_to_string(show_class = true) -> String:
	return "LocationData  %s  action_nodes=%s  npc_agents=%s  creature_agents=%s  exits=%s" % [super.fields_to_string(false), get_attr_array("action_nodes"), get_attr_array("npc_agents"), get_attr_array("creature_agents"), get_attr_array("exits")]
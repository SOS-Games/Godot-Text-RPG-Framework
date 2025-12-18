extends Resource

class_name LocationData

@export var id: String = ""
@export var name: String = ""
@export var action_nodes: Array[ActionData] = []
@export var npc_agents: Array[NPCData] = []
@export var creature_agents: Array[CreatureData] = []
@export var exits: Array[LocationExit] = []

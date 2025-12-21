extends Node

var game_start = false

# todo: should put rewards into an inventory (gloot). can delay for now
var current_reward_mining = 0
var current_reward_fishing = 0
var current_reward_woodcutting = 0

# todo: should load a location from DB
var default_location = "locations:forest"

# todo: should load action nodes from the current location's data
var all_actions = [
	{
		"name": "Mining",
		"id": "mining"
	},
	{
		"name": "Fishing",
		"id": "fishing"
	},
	{
		"name": "Woodcutting",
		"id": "woodcutting"
	}
]

# todo: should load from the current action node data
var current_action_id = "fishing"
var max_action_hp = 100
var current_action_hp = 100
var damage_min = 15
var damage_max = 30

var primary_timer = Timer.new()

func _ready():
	primary_timer.autostart = true
	primary_timer.paused = false
	add_child(primary_timer)
	primary_timer.timeout.connect(_on_primary_timer_timeout)

#func _process(delta):
	# Handle game logic and updates
	# might not need this since we are using a timer
	#pass

func start_game():
	primary_timer.paused = false

func _on_primary_timer_timeout():
	if current_action_id == "mining":
		print("Mining...")
	elif current_action_id == "fishing":
		print("Fishing...")
	elif current_action_id == "woodcutting":
		print("Woodcutting...")

	if current_action_hp > 0:
		_do_action()

func _do_action():
	current_action_hp -= randi_range(damage_min, damage_max)
	if current_action_hp <= 0:
		_complete_action()

func _complete_action():
	current_action_hp = max_action_hp
	if current_action_id == "mining":
		current_reward_mining += 1
		print("Mining reward: ", current_reward_mining)
	elif current_action_id == "fishing":
		current_reward_fishing += 1
		print("Fishing reward: ", current_reward_fishing)
	elif current_action_id == "woodcutting":
		current_reward_woodcutting += 1
		print("Woodcutting reward: ", current_reward_woodcutting)

func change_action(new_action_id):
	if _check_action_validity(new_action_id):
		current_action_id = new_action_id
		current_action_hp = max_action_hp
		print("Changed action to: ", current_action_id)
	else:
		print("Invalid action: ", new_action_id)

func _check_action_validity(new_action_id):
	# check if id is in list of action objects
	for action in all_actions:
		if action["id"] == new_action_id:
			return true
	return false
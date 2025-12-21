extends Node

var game_start = false

var resources: Dictionary = {} # category -> id -> Resource

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
	var importer = DataImporter.new()
	importer.schemas_dir = "res://schemas"
	importer.data_dirs = ["res://data"]
	var ok = importer.import_all()
	if not ok:
		print("Import completed with errors:")
		for e in importer.get_errors():
			print(" - ", e)
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		return
	else:
		print("Import successful - no errors")
	
	importer.print_all_resources()
	
	# Print validation reports if any
	var reports = importer.get_validation_reports()
	if reports.size() > 0:
		print("\nValidation reports:")
		for r in reports:
			print(" - File:", r.file, "errors:", r.count)
			for e in r.errors:
				print("    path:", e.instance_path, "|", e.message, "(", e.keyword, ")")
	
	resources = importer._resources.duplicate()
	importer.free()

	primary_timer.autostart = true
	primary_timer.paused = true
	add_child(primary_timer)
	primary_timer.timeout.connect(_on_primary_timer_timeout)

#func _process(delta):
	# Handle game logic and updates
	# might not need this since we are using a timer
	#pass

func initUI():
	var location: LocationData = query("locations", default_location)
	if location:
		print(location.fields_to_string())
		for action_node in location.action_nodes:
			UiManager.create_button(action_node.name, action_node.id)
	start_game()

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

func query(category: String, id: String) -> Variant:
	"""Convenience alias for get_resource()."""
	return get_resource(category, id)

func get_resource(category: String, id: String) -> Resource:
	"""Query a single resource by category and id. Returns null if not found."""
	if resources.has(category):
		return resources[category].get(id, null)
	return null

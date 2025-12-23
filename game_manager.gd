extends Node

var game_start = false

var resources: Dictionary = {} # category -> id -> Resource
var persistence_manager: PersistenceManager
var player_data: PlayerSaveData

var default_location = "locations:forest"

var current_action_id = ""
var current_action_data: ActionData = null
var max_action_hp = 100
var current_action_hp = 100

# todo: should load these from equipment
# need to store equipped items and load them, need to persist
# can delay until I have equipment slots and an inventory
var damage_min = 15
var damage_max = 30

var primary_timer = Timer.new()

var current_location_data: LocationData = null

func _ready():
	init_data()
	init_persistence()

	primary_timer.autostart = true
	primary_timer.paused = true
	add_child(primary_timer)
	primary_timer.timeout.connect(_on_primary_timer_timeout)

#func _process(delta):
	# Handle game logic and updates
	# might not need this since we are using a timer
	#pass

func initUI():
	current_location_data = query("locations", default_location)
	if current_location_data:
		print(current_location_data.fields_to_string())
		for action_node in current_location_data.action_nodes:
			print(action_node.fields_to_string())
			UiManager.create_button(action_node.name, action_node.id)
	start_game()

func start_game():
	primary_timer.paused = false

func _on_primary_timer_timeout():
	if !current_action_data:
		return
	
	var current_action_type = current_action_data.type
	if current_action_type == "mining":
		print("Mining...")
	elif current_action_type == "fishing":
		print("Fishing...")
	elif current_action_type == "woodcutting":
		print("Woodcutting...")

	if current_action_hp > 0:
		_do_action()

func _do_action():
	current_action_hp -= randi_range(damage_min, damage_max)
	if current_action_hp <= 0:
		_complete_action()

func _complete_action():
	current_action_hp = max_action_hp
	var current_action_type = current_action_data.type
	
	# todo: should put rewards into an inventory (gloot)
	# inventory needs to be persisted
	if current_action_type == "mining":
		print("You have mined a ", current_action_data.drop.id)
	elif current_action_type == "fishing":
		print("You have fished a ", current_action_data.drop.id)
	elif current_action_type == "woodcutting":
		print("You have cut a ", current_action_data.drop.id)
	
	save_game()

func change_action(new_action_id):
	if _check_action_validity(new_action_id):
		print("Changed action to: ", current_action_data.name)
		save_game()
	else:
		print("Invalid action: ", new_action_id)

func _check_action_validity(new_action_id):
	# checks if id is in list of action objects
	for action_node in current_location_data.action_nodes:
		if action_node.id == new_action_id:
			current_action_data = action_node
			current_action_id = new_action_id
			current_action_hp = current_action_data.max_hp
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

func init_persistence():
	persistence_manager = PersistenceManager.new()
	add_child(persistence_manager)
	
	# Try to load existing save, otherwise create new player
	player_data = persistence_manager.load_game()
	if player_data == null:
		print("No existing save found. Creating new player...")
		player_data = persistence_manager.create_new_player("Player")
		save_game()
	else:
		print("Loaded existing player: ", player_data.name)

func save_game():
	if persistence_manager and player_data:
		# Update player data with current game state
		if current_location_data == null:
			player_data.current_location_id = default_location
		else:
			player_data.current_location_id = current_location_data.id
		persistence_manager.save_game(player_data)

func init_data():
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

extends Node

class_name PersistenceManager

const SAVE_DIR = "user://saves/"
const SAVE_FILE = "user://saves/player_save.tres"

func _ready():
	# Ensure save directory exists
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)

func save_game(player_data: PlayerSaveData) -> bool:
	"""Save player data to disk. Returns true if successful."""
	if player_data == null:
		print("ERROR: Cannot save null player data")
		return false
	
	var error = ResourceSaver.save(player_data, SAVE_FILE)
	if error != OK:
		print("ERROR: Failed to save player data. Error code: ", error)
		return false
	
	print("SUCCESS: Player data saved to ", SAVE_FILE)
	return true

func load_game() -> PlayerSaveData:
	"""Load player data from disk. Returns null if no save exists."""
	if not ResourceLoader.exists(SAVE_FILE):
		print("No save file found at ", SAVE_FILE)
		return null
	
	var player_data = ResourceLoader.load(SAVE_FILE)
	if player_data == null:
		print("ERROR: Failed to load player data")
		return null
	
	print("SUCCESS: Player data loaded from ", SAVE_FILE)
	return player_data

func has_save() -> bool:
	"""Check if a save file exists."""
	return ResourceLoader.exists(SAVE_FILE)

func delete_save() -> bool:
	"""Delete the save file. Returns true if successful."""
	if not has_save():
		print("No save file to delete")
		return true
	
	var error = DirAccess.remove_absolute(SAVE_FILE)
	if error != OK:
		print("ERROR: Failed to delete save file. Error code: ", error)
		return false
	
	print("SUCCESS: Save file deleted")
	return true

func create_new_player(player_name: String) -> PlayerSaveData:
	"""Create a new player save data."""
	var player_data = PlayerSaveData.new()
	player_data.player_id = str(randi())
	player_data.player_name = player_name
	player_data.current_location_id = "locations:forest"
	#player_data.item_ids = []
	return player_data

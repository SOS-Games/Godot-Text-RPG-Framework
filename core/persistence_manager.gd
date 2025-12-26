extends Node

class_name PersistenceManager

const SAVE_DIR = "user://saves/"
const DEFAULT_SAVE_FILE = "user://saves/player_save.tres"

var save_file: String = DEFAULT_SAVE_FILE

func _ready():
	# Ensure save directory exists
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)

func save_game(player_data: PlayerSaveData) -> bool:
	"""Save player data to disk. Returns true if successful."""
	if player_data == null:
		print("ERROR: Cannot save null player data")
		return false
	
	var error = ResourceSaver.save(player_data, save_file)
	if error != OK:
		print("ERROR: Failed to save player data. Error code: ", error)
		return false
	
	print("SUCCESS: Player data saved to ", save_file)
	return true

func load_game() -> PlayerSaveData:
	"""Load player data from disk. Returns null if no save exists."""
	if not ResourceLoader.exists(save_file):
		print("No save file found at ", save_file)
		return null
	
	var player_data = ResourceLoader.load(save_file)
	if player_data == null:
		print("ERROR: Failed to load player data")
		return null
	
	print("SUCCESS: Player data loaded from ", save_file)
	return player_data

func has_save() -> bool:
	"""Check if a save file exists."""
	return ResourceLoader.exists(save_file)

func delete_save() -> bool:
	"""Delete the save file. Returns true if successful."""
	if not has_save():
		print("No save file to delete")
		return true
	
	var error = DirAccess.remove_absolute(save_file)
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

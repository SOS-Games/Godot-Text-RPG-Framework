extends Node

class_name PersistenceTest

var persistence_manager: PersistenceManager
var test_results: Array = []

func _ready():
	persistence_manager = PersistenceManager.new()
	add_child(persistence_manager)
	
	# Run all tests
	print("\n========== PERSISTENCE TESTS ==========\n")
	test_create_player()
	test_save_game()
	test_load_game()
	test_modify_and_save()
	test_delete_save()
	print_test_results()

func test_create_player() -> void:
	print("[TEST] Creating new player...")
	var player = persistence_manager.create_new_player("TestHero")
	
	if player and player.player_name == "TestHero" and player.player_id != "":
		_add_result("test_create_player", true, "Player created successfully")
		print("✓ PASS: Player created with name=", player.player_name, " id=", player.player_id)
	else:
		_add_result("test_create_player", false, "Failed to create player")
		print("✗ FAIL: Player creation failed")
	print()

func test_save_game() -> void:
	print("[TEST] Saving game...")
	var player = persistence_manager.create_new_player("SaveTestHero")
	# populate inventory and equip an item into a slot
	PlayerState.inventory.create_and_add_item("item1")
	PlayerState.equip_prototype_to_slot("minimal_item", "head")
	player.current_location_id = "locations:castle"

	# Serialize PlayerState into player save data and persist
	PlayerState.save_to_player_data(player)
	var success = persistence_manager.save_game(player)
	
	if success:
		_add_result("test_save_game", true, "Game saved successfully")
		print("✓ PASS: Game saved successfully")
	else:
		_add_result("test_save_game", false, "Failed to save game")
		print("✗ FAIL: Save failed")
	print()

func test_load_game() -> void:
	print("[TEST] Loading game...")
	
	# First ensure we have a save
	var player = persistence_manager.create_new_player("LoadTestHero")
	# add items and save (inventory + equipment slots)
	PlayerState.inventory.create_and_add_item("item1")
	PlayerState.equip_prototype_to_slot("minimal_item_2", "body")
	player.current_location_id = "locations:dungeon"
	PlayerState.save_to_player_data(player)
	persistence_manager.save_game(player)

	PlayerState.clear()

	# Now load it
	var loaded_player = persistence_manager.load_game()

	# Load into a fresh PlayerState to verify inventory deserialization
	PlayerState.apply_player_save_data(loaded_player)

	if loaded_player and loaded_player.player_name == "LoadTestHero" and loaded_player.current_location_id == "locations:dungeon" and PlayerState.inventory.get_item_count() > 0 and PlayerState.get_slot("head").get_item() != null and PlayerState.get_slot("body").get_item() != null:
		_add_result("test_load_game", true, "Game loaded and data matches")
		print("✓ PASS: Game loaded - name=", loaded_player.player_name, " location=", loaded_player.current_location_id)
		print("  Inventory count: ", PlayerState.inventory.get_item_count(), " Equipment head/body: ", PlayerState.get_slot("head").get_item() != null, ",", PlayerState.get_slot("body").get_item() != null)
	else:
		_add_result("test_load_game", false, "Loaded data doesn't match saved data")
		print("✗ FAIL: Load failed or data mismatch")
	print()

func test_modify_and_save() -> void:
	print("[TEST] Modifying and re-saving game...")
	
	# Load existing save
	var player = persistence_manager.load_game()
	if player == null:
		_add_result("test_modify_and_save", false, "No existing save to modify")
		print("✗ FAIL: No save file to load")
		return
	
	# Modify it
	# Load into PlayerState, modify inventory, then save back
	PlayerState.load_from_player_data(player)
	var original_count = PlayerState.inventory.get_item_count()
	PlayerState.inventory.create_and_add_item("minimal_item")
	player.current_location_id = "locations:village"
	PlayerState.save_to_player_data(player)
	
	# Save again
	var save_success = persistence_manager.save_game(player)
	
	# Load and verify
	var reloaded = persistence_manager.load_game()
	PlayerState.apply_player_save_data(reloaded)

	var items_match = PlayerState.inventory.get_item_count() == original_count + 1
	var location_match = reloaded.current_location_id == "locations:village"
	
	if save_success and items_match and location_match:
		_add_result("test_modify_and_save", true, "Modifications persisted correctly")
		print("✓ PASS: Modifications saved and loaded correctly")
		print("  Items count: ", original_count, " -> ", PlayerState.inventory.get_item_count())
		print("  New location: ", reloaded.current_location_id)
	else:
		_add_result("test_modify_and_save", false, "Modifications not persisted correctly")
		print("✗ FAIL: Modifications not persisted")
	print()

func test_delete_save() -> void:
	print("[TEST] Deleting save...")
	
	# Ensure there's a save to delete
	var player = persistence_manager.create_new_player("DeleteTestHero")
	persistence_manager.save_game(player)
	
	# Verify it exists
	if not persistence_manager.has_save():
		_add_result("test_delete_save", false, "Save file wasn't created")
		print("✗ FAIL: Save file doesn't exist")
		return
	
	# Delete it
	var delete_success = persistence_manager.delete_save()
	var save_exists_after = persistence_manager.has_save()
	
	if delete_success and not save_exists_after:
		_add_result("test_delete_save", true, "Save deleted successfully")
		print("✓ PASS: Save file deleted successfully")
	else:
		_add_result("test_delete_save", false, "Failed to delete save or file still exists")
		print("✗ FAIL: Delete failed")
	print()

func _add_result(test_name: String, passed: bool, message: String) -> void:
	test_results.append({
		"name": test_name,
		"passed": passed,
		"message": message
	})

func print_test_results() -> void:
	print("========== TEST SUMMARY ==========\n")
	
	var passed_count = 0
	var total_count = test_results.size()
	
	for result in test_results:
		var status = "✓ PASS" if result["passed"] else "✗ FAIL"
		print(status, " | ", result["name"], " | ", result["message"])
		if result["passed"]:
			passed_count += 1
	
	print("\nTotal: ", passed_count, "/", total_count, " tests passed")
	print("=====================================\n")

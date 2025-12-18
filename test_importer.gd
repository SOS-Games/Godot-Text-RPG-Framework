extends Node

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
	
	print("\n=== ENTITIES (no duplication) ===")
	print("Skills loaded:")
	for skill_id in importer.get_entities("skills").keys():
		var _skill = importer.query("skills", skill_id)
		print("  - %s: %s (level %d)" % [skill_id, _skill.name, _skill.level])

	print("Items loaded:")
	for item_id in importer.get_entities("items").keys():
		var _item = importer.query("items", item_id)
		print("  - %s: %s (requires skill: %s)" % [item_id, _item.name, _item.equip_skill_id])
	
	print("Locations loaded:")
	for loc_id in importer.get_entities("locations").keys():
		var loc = importer.query("locations", loc_id)
		print("  - %s: %s (mobs: %s, action-nodes: %s)" % [loc_id, loc.name, loc.mob_ids, loc.action_node_ids])
	
	print("NPCs loaded:")
	for npc_id in importer.get_entities("npcs").keys():
		var npc = importer.query("npcs", npc_id)
		print("  - %s: %s" % [npc_id, npc.name])
	
	print("Mobs loaded:")
	for mob_id in importer.get_entities("mobs").keys():
		var mob = importer.query("mobs", mob_id)
		print("  - %s: %s" % [mob_id, mob.name])
	
	print("Action Nodes loaded:")
	for an_id in importer.get_entities("action-nodes").keys():
		var an = importer.query("action-nodes", an_id)
		print("  - %s: %s (resource: %s)" % [an_id, an.name, an.resource])
	
	# Demonstrate query API (no duplication)
	print("\n=== QUERY API DEMO ===")
	var skill = importer.query("skills", "skills:combat")
	if skill:
		print("Queried skill: %s" % skill.name)
	
	var item = importer.query("items", "items:sword_iron")
	if item:
		print("Queried item: %s (equip skill ref: %s)" % [item.name, item.equip_skill_id])
		# To get the actual skill, call query again:
		var actual_skill = importer.query("skills", item.equip_skill_id)
		print("  -> Resolved skill: %s" % actual_skill.name)

	# Print validation reports if any
	var reports = importer.get_validation_reports()
	if reports.size() > 0:
		print("\nValidation reports:")
		for r in reports:
			print(" - File:", r.file, "errors:", r.count)
			for e in r.errors:
				print("    path:", e.instance_path, "|", e.message, "(", e.keyword, ")")

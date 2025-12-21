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
	
	importer.print_all_resources()
	
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

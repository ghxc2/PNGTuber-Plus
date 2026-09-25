extends Node

var redemptions = Global.redemptions

const SAVE_PATH := "user://redemptions.json"


func save() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("Failed to open save file.")
		return

	file.store_string(JSON.stringify(redemptions))
	file.close()


func load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No redemption configuration found.")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		print("Failed to open save file.")
		return

	var json_string = file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_string)
	
	redemptions.clear()
	if data is Dictionary:
		redemptions.merge(data)

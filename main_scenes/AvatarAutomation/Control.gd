extends Control

const SAVE_PATH := "user://redemptions.json"
const SETTINGS_PATH := "user://settings.json"

var current_row: HBoxContainer
var redemptions = Global.redemptions

@onready var redemption_name: LineEdit = $VBoxContainer/HBoxContainer/RedemptionName
@onready var file_path: LineEdit = $VBoxContainer/HBoxContainer/FilePath
@onready var browse: Button = $VBoxContainer/HBoxContainer/Browse
@onready var save_button: Button = $VBoxContainer/GUIButtons/Save
@onready var new_button: Button = $VBoxContainer/GUIButtons/New
@onready var file_dialog: FileDialog = $FileDialog
@onready var vbox: VBoxContainer = $VBoxContainer
@onready var window: Window = $".."


func _ready() -> void:
	browse.pressed.connect(_on_browse_pressed)
	save_button.pressed.connect(_on_save_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
	new_button.pressed.connect(_on_new_pressed)
	
	
	load_redemptions()
	populate_redemptions()
	


func _on_browse_pressed() -> void:
	file_dialog.popup_centered()


func _on_file_selected(path: String) -> void:
	file_path.text = path
	if current_row:
		current_row.get_node("FilePath").text = path


func _on_save_pressed() -> void:
	redemptions.clear()

	for row in $VBoxContainer.get_children():
		if not row is HBoxContainer:
			continue

		# Ignore the hidden template
		if row == $VBoxContainer/HBoxContainer:
			continue
		if row == $VBoxContainer/GUIButtons:
			continue
		if row == $VBoxContainer/TimerSettings:
			continue

		var name_field: LineEdit = row.get_node_or_null("RedemptionName")
		var path_field: LineEdit = row.get_node_or_null("FilePath")

		if name_field == null or path_field == null:
			print("Row is missing RedemptionName or FilePath")
			continue

		var name := name_field.text.strip_edges()
		var path := path_field.text.strip_edges()

		if name.is_empty() or path.is_empty():
			continue

		redemptions[name] = path
	save_redemptions()

func _on_new_pressed() -> void:
	create_redemption_row("", "")

func save_redemptions() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("Failed to open save file.")
		return
	print(str(redemptions))
	file.store_string(JSON.stringify(redemptions))
	file.close()
	
	print("Redemptions saved.")


func load_redemptions() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No redemption configuration found.")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		print("Failed to open save file.")
		return

	var json_string := file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_string)

	if data is Dictionary:
		redemptions.merge(data)

	print("Redemptions loaded: ", redemptions)
	
func create_redemption_row(reward_name: String, path: String) -> void:
	var row = $VBoxContainer/HBoxContainer.duplicate()

	row.visible = true

	row.get_node("RedemptionName").text = reward_name
	row.get_node("FilePath").text = path

	var browse_button: Button = row.get_node("Browse")
	browse_button.pressed.connect(
		func():
			_on_row_browse_pressed(row)
	)
	
	# Delete button
	var delete_button: Button = row.get_node("Delete")
	delete_button.pressed.connect(
		func():
			_on_delete_pressed(row)
	)
	
	# Load button
	var load_button: Button = row.get_node("Load")
	load_button.pressed.connect(
		func():
			Global.loadAvatar(row.get_node("FilePath").text)
	)
	
	$VBoxContainer.add_child(row)
	$VBoxContainer.move_child(row, $VBoxContainer.get_child_count() - 2)

func _on_row_browse_pressed(row: HBoxContainer) -> void:
	current_row = row
	file_dialog.popup_centered()

func populate_redemptions() -> void:
	if redemptions.is_empty():
		create_redemption_row("", "")
		return
		
	for reward_name in redemptions:
		create_redemption_row(
			reward_name,
			redemptions[reward_name]
		)

func _on_delete_pressed(row: HBoxContainer) -> void:
	row.queue_free()
	
func _on_window_size_changed() -> void:
	if vbox == null:
		return
	
	vbox.size = window.size

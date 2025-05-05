class_name main
extends Node2D

@onready var hidden_screen: Sprite2D = $HiddenScreen
@onready var back_btn: TextureButton = $SendToBackButton
@onready var dragged_btn: CanvasLayer = $CanvasLayer
@onready var tween: Tween = create_tween()
var html_template := """<!DOCTYPE html>
<html>
<head>
<title>My Page</title>
</head>
<body>
{content}
</body>
</html>"""
var html_snippets := {}

func _ready() -> void:
	# Connect the buttons to their respective functions
	$BringToFrontButton.connect("pressed", Callable(self, "_on_bring_to_front_button_pressed"))
	$SendToBackButton.connect("pressed", Callable(self, "_on_send_to_back_button_pressed"))
	$SaveButton.connect("pressed",Callable(self,"save_ui_config"))
	$LoadButton.connect("pressed",Callable(self,"load_ui_config"))
	for button in get_tree().get_nodes_in_group("draggable_buttons"):
		button.connect("code_added", Callable(self, "_on_code_added"))
		#button.connect("button_deleted", Callable(self, "_on_button_deleted"))
		if not button.is_connected("button_deleted", Callable(self, "_on_button_deleted")):
			button.connect("button_deleted", Callable(self, "_on_button_deleted"))


func _on_button_deleted(button_id: String):
	# Double cleanup
	if html_snippets.has(button_id):
		html_snippets.erase(button_id)
	
	# Verify the button is actually gone
	for child in $CanvasLayer.get_children():
		if child.name == button_id:
			child.queue_free()
	generate_html()

func _on_bring_to_front_button_pressed() -> void:
	#print("Current snippets:", html_snippets)
	hidden_screen.z_index = 20
	back_btn.z_index = 20
	dragged_btn.layer = -20
	#var final_html = html_template.format({"content": combine_html_snippets()})
	#save_html_file(final_html)
	generate_html()
	OS.shell_open("file://" + OS.get_user_data_dir() + "/webcraft_output.html")

func _on_send_to_back_button_pressed() -> void:
	hidden_screen.z_index = -20
	back_btn.z_index = -20
	dragged_btn.layer = 20

func save_html_file(html_text: String, file_name: String = "webcraft_output.html"):
	var file = FileAccess.open("user://" + file_name, FileAccess.WRITE)
	if file:
		file.store_string(html_text)
		file.close()
		#print("HTML file saved as", file_name)
	'''else:
		print("Failed to save HTML file.")
'''
func _on_code_added(button_name: String, html_code: String) -> void:
	html_snippets[button_name] = html_code
	#print("Added snippet from:", button_name)
	


'''func combine_html_snippets() -> String:
	var combined := ""
	for snippet in html_snippets.values():
		combined += snippet + "\n"
	return combined
'''
func combine_html_snippets() -> String:
	var combined := ""
	# Get all current buttons in workspace
	var current_buttons = []
	for node in $CanvasLayer.get_children():
		if node is TextureButton:
			current_buttons.append(node.name)
	
	# Only include snippets for existing buttons
	for button_name in html_snippets:
		if button_name in current_buttons:
			combined += html_snippets[button_name] + "\n"
	return combined

func generate_html():
	var final_html = html_template.format({"content": combine_html_snippets()})
	save_html_file(final_html)
func save_ui_config() ->void:
	print("file saved")
	var ui_data = {
		"buttons": [],      # Stores button positions/text
		"html_code": ""     # Final generated HTML
	}
	
	# Example: Save all buttons in a VBoxContainer
	for button in $Control/ScrollContainer/VBoxContainer.get_children():
		if button is TextureButton:
			ui_data["buttons"].append({
				"name": button.name,
				"x": button.position.x,
				"y": button.position.y,
				"texture": button.texture_normal.resource_path  # Save image path
			})
	# Convert to JSON and save
	var save_file = FileAccess.open("user://ui_config.json", FileAccess.WRITE)
	save_file.store_string(JSON.stringify(ui_data))

func load_ui_config():
	if not FileAccess.file_exists("user://ui_config.json"):
		print("No saved UI found.")
		return
	var file = FileAccess.open("user://ui_config.json", FileAccess.READ)
	var ui_data = JSON.parse_string(file.get_as_text())
	
	# Clear existing buttons (optional)
	'''for child in $Control/ScrollContainer/VBoxContainer.get_children():
		child.queue_free()
	'''
	# Recreate buttons from data
	for button_data in ui_data["buttons"]:
		var new_button = TextureButton.new()
		new_button.name = button_data["name"]
		new_button.position = Vector2(button_data["x"], button_data["y"])
		
		# Load texture or use fallback
		var texture_path = button_data["texture"]
		if ResourceLoader.exists(texture_path):
			new_button.texture_normal = load(texture_path)
		else:
			print("Texture not found: ", texture_path)
			new_button.texture_normal = load("res://fallback.png")
		$Control/ScrollContainer/VBoxContainer.add_child(new_button)
	print("UI loaded successfully!")

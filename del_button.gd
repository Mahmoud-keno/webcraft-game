extends TextureButton

# Configuration
const BACK_LAYER_Z_INDEX := -100  # Ensure this is lower than other elements
const DELETE_BUTTON_POSITION := Vector2(550, 350)  # Adjust as needed

func _ready():
	# Initial setup
	hide()
	disabled = true
	z_index = 100  # Keep delete button on top
	
	# Connect signals
	connect("pressed", Callable(self, "_on_pressed"))
	await get_tree().process_frame
	
	var parent = get_parent()
	if parent is TextureButton:
		parent.connect("button_up", Callable(self, "_on_parent_dropped"))
	else:
		push_error("DeleteButton must be child of a TextureButton")

func _on_parent_dropped():
	show()
	disabled = false
	position = DELETE_BUTTON_POSITION
	
	# Auto-hide after delay
	get_tree().create_timer(1.0).timeout.connect(
		func():
			if not disabled:
				hide()
				disabled = true
	)

func _on_pressed():
	var parent = get_parent()
	if parent is TextureButton:
		# Ensure both deletion methods are called
		if parent.has_method("delete_button"):
			parent.delete_button()
	else:
		parent.emit_signal("button_deleted", parent.name)
		parent.queue_free()
		
		# Force immediate HTML update
	var main = get_node("/root/main")
	if main and main.has_method("generate_html"):
		main.generate_html()

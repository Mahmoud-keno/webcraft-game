extends TextureButton  # or Button, depending on your node
signal code_added(button_name: String, html_code: String)
var is_dragging := false
var drag_copy : TextureButton = null  # This will hold the duplicate button
var is_in_workspace := false  # Track if the block is in the workspace
var drag_offset := Vector2()  # Offset between the mouse and the block's position
var target_position := Vector2()  # Target position for smooth movement
var lerp_speed := 20.0  # Speed of smooth movement (higher = faster)
var indx:int =0
var codes=Dictionary()
signal button_deleted(button_id)

func delete_button():
	# Clean up before deletion
	emit_signal("button_deleted", name)
	if codes.has(name):
		codes.erase(name)
	
	# Remove from CanvasLayer
	if get_parent():
		get_parent().remove_child(self)
	queue_free()
func _ready() -> void:
	# Connect the button's pressed signal to start dragging
	connect("button_down", Callable(self, "_on_button_down"))
	connect("button_up", Callable(self, "_on_button_up"))
	add_to_group("draggable_buttons")

func _on_button_down() -> void:
	# Start dragging
	is_dragging = true

	# Calculate the offset between the mouse and the block's position
	drag_offset = get_global_mouse_position() - global_position

	# If the block is in the scrollbar, create a copy in the workspace
	if not is_in_workspace:
		create_drag_copy()
		store_str(self.name,drag_copy.name,codes)
	else:
		# If the block is already in the workspace, drag it directly
		drag_copy = self

func _on_button_up() -> void:
	# Stop dragging
	is_dragging = false

	if drag_copy:
		# If the block was copied, mark it as part of the workspace
		if drag_copy != self:
			drag_copy.is_in_workspace = true

		# Disconnect the duplicate's signals (if it was a copy)
		if drag_copy != self:
			drag_copy.disconnect("button_down", Callable(self, "_on_button_down"))
			drag_copy.disconnect("button_up", Callable(self, "_on_button_up"))

		drag_copy = null  # Clear the reference to the duplicate

func _process(delta: float) -> void:
	if is_dragging and drag_copy:
		# Calculate the target position for smooth movement
		target_position = get_global_mouse_position() - drag_offset

		# Use linear interpolation (lerp) to smoothly move the block
		drag_copy.global_position = drag_copy.global_position.lerp(target_position, lerp_speed * delta)

func create_drag_copy() -> void:
	# Duplicate the original button
	drag_copy = duplicate()
	drag_copy.name=self.name+str(indx) 
	drag_copy.position = global_position  # Set the duplicate's position to match the original

	# Find the CanvasLayer (or workspace) and add the duplicate to it
	var canvas_layer = get_tree().root.get_node("main/CanvasLayer")
	if canvas_layer:
		canvas_layer.add_child(drag_copy)

	# Connect the duplicate's signals (so it can be dragged again)
	drag_copy.connect("button_down", Callable(self, "_on_button_down"))
	drag_copy.connect("button_up", Callable(self, "_on_button_up"))


func store_str(name:String,key,co:Dictionary) ->void:
	match name:
		"DraggableButton":
			co[key]="<h1>Hello world!</h1>"
		"DraggableButton2":
			co[key]="<h2>Hello world!</h2>"
		"DraggableButton3":
			co[key]="<h3>Hello world!</h3>"
		"DraggableButton4":
			co[key]="<h4>Hello world!</h4>"
		"DraggableButton5":
			co[key]="<a href=link>Visit W3Schools.com!</a>"
		"DraggableButton6":
			co[key]="<p>My mother has <span style='color:blue'>blue</span> eyes.</p>"
		"DraggableButton7":
			co[key]="<p>My mother has <span style='color:blue'>blue</span> eyes.</p>"
		"DraggableButton8":
			co[key]="<strong>This text is important!</strong>"
		"DraggableButton9":
			co[key]="<textarea rows='3' cols='20'>Enter your text here...</textarea>"
		"DraggableButton10":
			co[key]="<button type='button'>Click Me!</button>"
		"DraggableButton11":
			co[key]="<button type='button'>Click Me!</button>"
		"DraggableButton12":
			co[key]="<img src='pic_trulli.jpg' alt='Italian Trulli'>"
		"DraggableButton13":
			co[key]="<input type='image' src='submit.gif' alt='Submit' style='float:right' width='48' height='48'>"
	emit_signal("code_added", key, co[key])

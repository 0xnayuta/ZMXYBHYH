extends TextureButton

@onready var text_key: Label = $Key
@onready var size_node: TextureButton = $Control/TextureButton
@onready var control_: Control = $Control

var key: String
var text_str: String
var is_set: bool
var tree: SceneTree
var is_click: bool = false
var is_size: bool = false
var offset_: Vector2 = Vector2.ZERO


func _ready():
	tree = get_tree()
	text_key.text = text_str
	if !is_set:
		control_.queue_free()


func _physics_process(_delta):
	if is_set:
		size_node.size = size / 8
		if size_node.size < Vector2(20, 20):
			size_node.size = Vector2(20, 20)
	if is_click:
		position = get_global_mouse_position() - offset_
	elif is_size:
		size = get_global_mouse_position() - position + offset_


func _on_button_down():
	if is_set:
		offset_ = get_global_mouse_position() - position
		is_click = true
	else:
		Input.action_press(key)


func _on_button_up():
	if is_set:
		is_click = false
	else:
		Input.action_release(key)


func _on_texture_button_button_down():
	offset_ = size - (get_global_mouse_position() - position)
	is_size = true


func _on_texture_button_button_up():
	is_size = false

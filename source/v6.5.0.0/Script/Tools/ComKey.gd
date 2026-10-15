class_name ComKey extends TextureButton

@onready var TextKey: Label = $Key
@onready var sizeNode: TextureButton = $Control / TextureButton
@onready var control_: Control = $Control

var Key: String
var Text: String
var isSet: bool
var tree: SceneTree
var isClick: bool = false
var isSize: bool = false
var offset_: Vector2 = Vector2.ZERO

func _ready():
	tree = get_tree()
	TextKey.text = Text
	if !isSet:
		control_.queue_free()

func _physics_process(_delta):
	if isSet:
		sizeNode.size = size / 8
		if sizeNode.size < Vector2(20, 20):
			sizeNode.size = Vector2(20, 20)
	if isClick:
		position = get_global_mouse_position() - offset_
	elif isSize:
		size = get_global_mouse_position() - position + offset_

func _on_button_down():
	if isSet:
		offset_ = get_global_mouse_position() - position
		isClick = true
	else:
		Input.action_press(Key)

func _on_button_up():
	if isSet:
		isClick = false
	else:
		Input.action_release(Key)

func _on_texture_button_button_down():
	offset_ = size - (get_global_mouse_position() - position)
	isSize = true

func _on_texture_button_button_up():
	isSize = false

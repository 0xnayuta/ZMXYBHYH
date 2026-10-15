extends TouchScreenButton

var isClick: bool = false
var offset: Vector2 = Vector2.ZERO

func _physics_process(_delta):
	if isClick:
		position = get_global_mouse_position() - offset

func _on_button_button_down():
	offset = get_global_mouse_position() - position
	isClick = true


func _on_button_button_up():
	isClick = false

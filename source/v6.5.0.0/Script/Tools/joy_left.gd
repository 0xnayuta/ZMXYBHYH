extends Control

var is_set: bool = false
var touch_scale: float = 1.0
var size_: Vector2 = Vector2(200, 200)
var curSize: float = 200.0


func _physics_process(_delta: float) -> void:
	var side: float = min(size_.x, size_.y)
	if side <= 0:
		side = curSize
	scale = Vector2(side / max(curSize, 1.0), side / max(curSize, 1.0)) * touch_scale


func _release_dirs() -> void:
	var joy = get_node_or_null("joyBG/joy")
	if joy != null and joy.has_method("_release_dirs"):
		joy._release_dirs()


func _on_button_pressed() -> void:
	pass

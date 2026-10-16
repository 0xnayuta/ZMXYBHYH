extends Node2D
@onready var texture_rect: TextureRect = $TextureRect

var Num: int
var is_set: bool


func _physics_process(delta: float) -> void:
	if not is_set:
		texture_rect.texture = load_(Num)
		$AnimationPlayer.play("show")
		is_set = true


func load_(name_):
	var abc = load("res://Art/Level/Challenge/ui_beizhan_pj_" + str(name_) + ".png")
	return abc

extends Node2D

var Speed: int
var MaxPosition_x: int
var Direction: int = 1
var PD: bool
var currentposition: Vector2
var Catch: bool = false
var Player: BaseHero
var is_set: bool = false

func _physics_process(_delta: float) -> void :
	if not is_set:
		currentposition = position
		is_set = true
	self.position.x += Direction * Speed
	if PD:
		if position.x >= MaxPosition_x:
			position = currentposition
	else:
		if position.x <= MaxPosition_x:
			position = currentposition
	if Catch:
		if Player != null:
			Player.position.x += Direction * Speed

func _on_area_2d_body_entered(body: Node2D) -> void :
	Catch = true
	if body is BaseHero:
		Player = body

func _on_area_2d_body_exited(_body: Node2D) -> void :
	Catch = false

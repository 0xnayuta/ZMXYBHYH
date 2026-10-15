extends Sprite2D
var Type: String
@onready var move_player: AnimationPlayer = $MovePlayer
var Player
var dir: int
var is_set: bool
var catch: bool
func _ready() -> void :
	if randi_range(0, 100) <= 50:
		dir = 1
	else:
		dir = -1

func _physics_process(delta: float) -> void :









	pass
func _on_area_2d_body_entered(body: Node2D) -> void :
	catch = true
	if body is BaseHero:
		Player = body


func _on_area_2d_body_exited(body: Node2D) -> void :
	catch = false

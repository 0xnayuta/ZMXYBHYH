extends Node2D

var Speed: int = 50
var MaxPosition_x: int = 300
var Direction: int = 1
var PD: bool = true
var currentposition: Vector2
var Catch: bool = false
var Player: BaseHero
var is_set: bool = false

var platform_texture: Texture2D
@onready var sprite: Sprite2D = $ZlwFloor


func _ready() -> void:
	if platform_texture != null:
		sprite.texture = platform_texture


func _physics_process(_delta: float) -> void:
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


func set_texture(texture: Texture2D) -> void:
	"动态设置贴图"
	if sprite != null:
		sprite.texture = texture
	platform_texture = texture


func _on_area_2d_body_entered(body: Node2D) -> void:
	Catch = true
	if body is BaseHero:
		Player = body


func _on_area_2d_body_exited(_body: Node2D) -> void:
	Catch = false

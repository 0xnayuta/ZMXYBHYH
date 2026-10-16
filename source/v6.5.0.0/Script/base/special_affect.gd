extends AnimatedSprite2D
@onready var special_effect: AnimatedSprite2D = $"."
@onready var effect_player: AnimationPlayer = $SpecialAffect
enum { do, remove }
var effect_name: String
var state = do
var effect_dir: bool
var effect_speed: float
var scale_


func _physics_process(_delta: float) -> void:
	match state:
		do:
			do_action(effect_name)
		remove:
			pass


func do_action(name_):
	effect_player.speed_scale = effect_speed
	special_effect.flip_h = effect_dir
	special_effect.scale = scale_
	effect_player.play(name_)
	await effect_player.animation_finished
	state = remove
	pass

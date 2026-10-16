extends MonsterBullet

var distance_: int
var speed_: int
var dir_


func _ready():
	set_meta("is_monster_bullet", true)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)


func do_action(name_):
	if dir == false:
		hit_box.scale.x = 1
	else:
		hit_box.scale.x = -1
	bullet_player.speed_scale = speed
	bullet_ani.flip_h = dir

	bullet_player.play(name_)
	await bullet_player.animation_finished
	state = remove


func _on_hit_box_area_entered(area: Area2D) -> void:
	var target = area.get_parent().get_parent()

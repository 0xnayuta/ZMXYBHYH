extends RoleBullet




func _physics_process(_delta: float) -> void :
	if not is_set:

		bullet_players.play(name_)
		if Direction:
			middle.scale.x = -1
		else:
			middle.scale.x = 1
		is_set = true

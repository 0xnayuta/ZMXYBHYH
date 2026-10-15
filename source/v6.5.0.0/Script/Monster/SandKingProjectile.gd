extends WutaiMinghaiProjectile

var collide_with_terrain: bool = false

func _physics_process(delta: float) -> void :
	if owner_monster == null or not is_instance_valid(owner_monster) or owner_monster.is_queued_for_deletion() or owner_monster.death():
		finished_callback = Callable()
		queue_free()
		return
	if collide_with_terrain and not _finished and not _impacting:
		var next_position: Vector2 = global_position + (motion_velocity + motion_acceleration * delta) * delta
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, next_position, 1)
		query.collide_with_areas = false
		var collision: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
		if not collision.is_empty():
			global_position = collision["position"]
			_finish()
			return
	super._physics_process(delta)

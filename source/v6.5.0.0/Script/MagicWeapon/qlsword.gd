extends BaseMagicWeapon
class_name qlsword

var floor_instance: Node2D = null
var floor_timer: Timer = Timer.new()
var follow_timer: Timer = Timer.new()
var target_position_y: float = 0.0
var is_following_y: bool = true
var last_player_y: float = 0.0
var is_moving_down: bool = false
var is_player_on_floor: bool = false
var floor_locked_y: float = 0.0
var floor_area: Area2D = null

var weapon_level: int = 1
var floor_duration_base: float = 10.0
var floor_duration_per_level: float = 2.0

var floor_texture_path: String = "res://Art/MagicWeapon/MagicWeapon_qlsword/2-1.png"
var floor_scale: Vector2 = Vector2(0.09, 0.09)
const idle_sword_texture_path := "res://Art/MagicWeapon/MagicWeapon_qlsword/2.png"
const cast_sword_texture_path := "res://Art/MagicWeapon/MagicWeapon_qlsword/1.png"


func _ready() -> void:
	_setup_sword_sprite_frames()
	mg_action.visible = true
	add_child(floor_timer)
	add_child(follow_timer)

	floor_timer.timeout.connect(_on_floor_timeout)
	follow_timer.timeout.connect(_on_follow_timeout)


func _setup_sword_sprite_frames() -> void:
	var idle_texture := Global.get_cached_texture(idle_sword_texture_path)
	var cast_texture := Global.get_cached_texture(cast_sword_texture_path)
	if idle_texture == null:
		return

	var frames := SpriteFrames.new()
	frames.add_animation(&"wait")
	frames.set_animation_loop(&"wait", true)
	frames.set_animation_speed(&"wait", 5.0)
	frames.add_frame(&"wait", idle_texture)

	frames.add_animation(&"hit")
	frames.set_animation_loop(&"hit", false)
	frames.set_animation_speed(&"hit", 25.0)
	frames.add_frame(&"hit", cast_texture if cast_texture != null else idle_texture)
	mg_action.sprite_frames = frames
	mg_action.animation = &"wait"
	mg_action.scale = Vector2(0.04, 0.04)


func _physics_process(delta: float) -> void:
	self.FB_Level = PlayerData.get_mostLevel("qlsword") + 1
	weapon_level = self.FB_Level

	super._physics_process(delta)

	if not is_use:
		mg_player.play("wait")

	if floor_instance != null and Player != null:
		_update_floor_position(delta)


func ShowSkill():
	mg_player.play("hit")

	await mg_player.animation_finished

	_remove_floor()
	_create_floor()
	Useover()


func _create_floor():
	if Player == null:
		return

	var floor_scene = preload("res://Scene/Level/zlw_fly_floor.tscn")
	floor_instance = floor_scene.instantiate()

	_set_floor_appearance()

	if floor_instance.has_node("Area2D"):
		floor_area = floor_instance.get_node("Area2D")
		floor_area.body_entered.connect(_on_floor_body_entered)
		floor_area.body_exited.connect(_on_floor_body_exited)

	var parent_scene = get_tree().current_scene
	if parent_scene:
		parent_scene.add_child(floor_instance)
	else:
		get_parent().add_child(floor_instance)

	var player_pos := Player.global_position
	if Player is Role4Hero:
		var support_y := _get_role4_floor_position_y()
		target_position_y = support_y
		last_player_y = player_pos.y
		floor_instance.global_position = Vector2(player_pos.x, support_y)
	else:
		var floor_offset_y := -40.0
		var local_player_pos := Player.position
		target_position_y = local_player_pos.y
		last_player_y = local_player_pos.y + floor_offset_y
		floor_instance.position = Vector2(local_player_pos.x, local_player_pos.y + floor_offset_y)

	if floor_instance.has_method("set_physics_process"):
		floor_instance.set_physics_process(false)

	var floor_duration = _get_floor_duration()
	floor_timer.start(floor_duration)

	is_following_y = true
	is_moving_down = false
	is_player_on_floor = false


func _set_floor_appearance():
	if floor_instance == null:
		return

	var sprite_node = floor_instance.get_node("ZlwFloor") as Sprite2D
	if sprite_node != null:
		var texture := Global.get_cached_texture(floor_texture_path)
		if texture != null:
			sprite_node.texture = texture

		sprite_node.scale = floor_scale

		print("青灵剑：设置地砖贴图路径 = ", floor_texture_path, "，缩放 = ", floor_scale)


func _update_floor_position(delta: float):
	if floor_instance == null or Player == null:
		return

	if Player is Role4Hero:
		floor_instance.global_position.x = Player.global_position.x
		_update_role4_floor_position(delta)
		return

	floor_instance.position.x = Player.position.x

	if is_player_on_floor:
		target_position_y = floor_instance.position.y
		is_following_y = true
		follow_timer.stop()
		return

	var current_player_y = Player.position.y
	is_moving_down = current_player_y > last_player_y

	if not is_moving_down:
		target_position_y = current_player_y - 30
		is_following_y = true
		follow_timer.stop()
	else:
		if is_following_y and not follow_timer.is_processing():
			follow_timer.start(0.2)
			is_following_y = false

	if is_following_y:
		floor_instance.position.y = lerp(floor_instance.position.y, target_position_y, 10.0 * delta)

	last_player_y = current_player_y


func _get_role4_floor_position_y() -> float:
	var player_pz := Player.get_node_or_null("pz") as CollisionShape2D
	var floor_pz := floor_instance.get_node_or_null("StaticBody2D/FlyPZ") as CollisionShape2D
	if player_pz == null or player_pz.shape == null or floor_pz == null or floor_pz.shape == null:
		return Player.global_position.y - 40.0

	var player_rect := player_pz.shape.get_rect()
	var player_foot_y := player_pz.to_global(Vector2(0.0, player_rect.end.y)).y
	var floor_top_local_y := floor_pz.position.y + floor_pz.shape.get_rect().position.y
	return player_foot_y - floor_top_local_y


func _update_role4_floor_position(delta: float) -> void:
	var current_player_y := Player.global_position.y
	is_moving_down = current_player_y > last_player_y

	if is_player_on_floor:
		floor_locked_y = floor_instance.global_position.y
		target_position_y = floor_locked_y
		is_following_y = false
		follow_timer.stop()
	elif not is_moving_down:
		target_position_y = _get_role4_floor_position_y()
		is_following_y = true
		follow_timer.stop()
		floor_instance.global_position.y = lerp(
			floor_instance.global_position.y, target_position_y, minf(1.0, 10.0 * delta)
		)
	else:
		follow_timer.stop()
		is_following_y = false

	last_player_y = current_player_y


func _on_floor_body_entered(body: Node2D):
	if body == Player:
		is_player_on_floor = true
		if floor_instance != null:
			floor_locked_y = floor_instance.global_position.y


func _on_floor_body_exited(body: Node2D):
	if body == Player:
		is_player_on_floor = false
		if Player != null and not Player is Role4Hero:
			target_position_y = Player.position.y - 30

			if not is_moving_down:
				is_following_y = true
			else:
				if not follow_timer.is_processing():
					follow_timer.start(0.2)
					is_following_y = false


func _on_follow_timeout():
	if Player != null and not is_player_on_floor and not Player is Role4Hero:
		target_position_y = Player.position.y - 30
		is_following_y = true


func _on_floor_timeout():
	_remove_floor()


func _remove_floor():
	if floor_instance != null:
		if floor_area != null:
			if floor_area.body_entered.is_connected(_on_floor_body_entered):
				floor_area.body_entered.disconnect(_on_floor_body_entered)
			if floor_area.body_exited.is_connected(_on_floor_body_exited):
				floor_area.body_exited.disconnect(_on_floor_body_exited)

		var sprite_node := floor_instance.get_node_or_null("ZlwFloor") as Sprite2D
		if sprite_node != null:
			sprite_node.texture = null
		floor_instance.queue_free()
		floor_instance = null
		floor_area = null

	follow_timer.stop()
	floor_timer.stop()

	is_following_y = true
	is_moving_down = false
	is_player_on_floor = false


func Useover():
	var cd_time = _get_floor_duration()

	self.usecd = cd_time
	Global.FB_CD = 1
	is_use = false

	skill_cd.start(cd_time)


func is_floor_active() -> bool:
	return floor_instance != null and not floor_timer.is_stopped()


func get_floor_remaining_time() -> float:
	if floor_timer != null and not floor_timer.is_stopped():
		return floor_timer.time_left
	return 0.0


func _get_floor_duration() -> float:
	var level = max(1, weapon_level)
	return floor_duration_base + (level - 1) * floor_duration_per_level


func set_floor_texture(texture_path: String):
	floor_texture_path = texture_path
	if floor_instance != null:
		_set_floor_appearance()


func set_floor_scale(scale_value: Vector2):
	floor_scale = scale_value
	if floor_instance != null:
		_set_floor_appearance()


func _exit_tree():
	_remove_floor()

	if floor_timer.timeout.is_connected(_on_floor_timeout):
		floor_timer.timeout.disconnect(_on_floor_timeout)
	if follow_timer.timeout.is_connected(_on_follow_timeout):
		follow_timer.timeout.disconnect(_on_follow_timeout)

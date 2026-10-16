extends Node

const MOUNT_CATALOG := preload("res://Script/Mount/mount_catalog.gd")
const MOUNT_SKILL_EFFECT := preload("res://Script/Mount/mount_skill_effect.gd")
const MOUNT_VISUAL := preload("res://Script/Mount/mount_visual.gd")
const RIDE_SPEED_MULTIPLIER := 1.2
const RIDING_TITLE_OFFSET := Vector2(0.0, -80.0)
const RIDER_ADJUSTMENT_ROOT := "res://Scene/Mount/RiderAdjustments"
const RIDER_POSE_FRAMES := {
	1: 8 * 6 + 1,
	2: 7 * 6 + 2,
	3: 11 * 6 + 3,
	4: 7 * 6 + 2,
	5: 14 * 8 + 4,
	6: 0,
}
const FATIGUE_TICK_SECONDS := 10.0
const REST_TICK_SECONDS := 1.0
const SKILL_ACTIONS := ["slz", "lys", "lyfb", "hmz", "hytj"]

var hero: BaseHero
var mount_visual: MountVisual
var mount_overlay_visual: MountVisual
var skill_cooldowns: Dictionary = {}
var active_skills: Array = []
var _current_mount_id := ""
var _fatigue_elapsed := 0.0
var _rest_elapsed := 0.0
var _normal_attack_cooldown := 0.0
var _initialized := false
var _original_action_visible := true
var _hero_action_hidden_by_mount := false
var _original_title_position := Vector2.ZERO
var _title_shifted_by_mount := false
var _mount_action_locked := false
var _skill_movement: Dictionary = {}
var _skill_movement_elapsed := 0.0
var _skill_movement_direction := 1.0
var _skill_movement_target := Vector2.ZERO


func setup(target: BaseHero) -> void:
	hero = target
	call_deferred("_initialize_runtime")


func _ready() -> void:
	call_deferred("_initialize_runtime")


func _initialize_runtime() -> void:
	if _initialized or hero == null or not is_instance_valid(hero):
		return
	_initialized = true
	if not PlayerData.is_mount_system_unlocked():
		PlayerData.set_mount_riding(false)
		return
	PlayerData.ensure_mount_data()
	mount_visual = MOUNT_VISUAL.new()
	mount_visual.name = "MountVisual"
	mount_visual.z_index = 5
	mount_visual.visible = false
	mount_visual.animation_finished.connect(_on_mount_animation_finished)
	hero.add_child(mount_visual)
	mount_overlay_visual = MOUNT_VISUAL.new()
	mount_overlay_visual.name = "MountOverlayVisual"
	mount_overlay_visual.z_index = 8
	mount_overlay_visual.visible = false
	hero.add_child(mount_overlay_visual)
	_refresh_mount_visual()
	_set_riding(bool(PlayerData.player_data.get(PlayerData.MOUNT_AUTO_RIDE_KEY, false)))


func _unhandled_input(event: InputEvent) -> void:
	if (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and (event.physical_keycode == KEY_Z or event.keycode == KEY_Z)
	):
		if not PlayerData.is_mount_system_unlocked():
			return
		toggle_riding()
		get_viewport().set_input_as_handled()


func toggle_riding() -> void:
	if not PlayerData.is_mount_system_unlocked():
		PlayerData.set_mount_riding(false)
		return
	var riding := bool(PlayerData.player_data.get(PlayerData.MOUNT_RIDING_KEY, false))
	if not riding and hero != null and (hero.is_attacking or hero.is_be_attacking or hero.is_using_skills):
		return
	_set_riding(not riding)


func is_riding_mount() -> bool:
	return (
		PlayerData.is_mount_system_unlocked()
		and _current_mount_id != ""
		and bool(PlayerData.player_data.get(PlayerData.MOUNT_RIDING_KEY, false))
	)


func get_mount_skill_for_slot(slot: int) -> Dictionary:
	if slot < 0 or slot >= active_skills.size() or not (active_skills[slot] is Dictionary):
		return {}
	return (active_skills[slot] as Dictionary).duplicate(true)


func get_mount_skill_cooldown(slot: int) -> float:
	var skill := get_mount_skill_for_slot(slot)
	if skill.is_empty():
		return 0.0
	return maxf(0.0, float(skill_cooldowns.get(str(skill.get("id", "")), 0.0)))


func get_mount_skill_cooldown_total(slot: int) -> float:
	var skill := get_mount_skill_for_slot(slot)
	return maxf(0.0, float(skill.get("cooldown", 0.0))) if not skill.is_empty() else 0.0


func _set_riding(enabled: bool) -> void:
	var riding := PlayerData.set_mount_riding(enabled)
	if hero != null and is_instance_valid(hero):
		hero.mount_speed_multiplier = RIDE_SPEED_MULTIPLIER if riding else 1.0
		if riding:
			if not _hero_action_hidden_by_mount:
				_original_action_visible = hero.action.visible
			if not _title_shifted_by_mount:
				_original_title_position = hero.tx.position
				_title_shifted_by_mount = true
			hero.tx.position = _original_title_position + RIDING_TITLE_OFFSET
			_hero_action_hidden_by_mount = true
			hero.action.visible = false
			hero.is_attacking = false
			hero.is_using_skills = false
			hero.get_action = "mount"
			if hero.role_action_player != null:
				hero.role_action_player.stop()
		else:
			if _hero_action_hidden_by_mount:
				hero.action.visible = _original_action_visible
			if _title_shifted_by_mount:
				hero.tx.position = _original_title_position
			_title_shifted_by_mount = false
			_hero_action_hidden_by_mount = false
			hero.is_using_skills = false
			hero.is_attacking = false
			hero.get_action = ""
	if mount_visual != null and is_instance_valid(mount_visual):
		mount_visual.visible = riding and _current_mount_id != ""
		if riding:
			_mount_action_locked = false
			mount_visual.play("idle", true)
	if mount_overlay_visual != null and is_instance_valid(mount_overlay_visual):
		mount_overlay_visual.visible = riding and _current_mount_id == "1002800"


func process_mounted_control(_delta: float) -> bool:
	if not bool(PlayerData.player_data.get(PlayerData.MOUNT_RIDING_KEY, false)):
		return false
	if hero == null or not is_instance_valid(hero) or hero.IsDeath:
		return true

	hero.is_using_skills = false
	var direction := Input.get_axis("move_left", "move_right")
	if hero.IsReverseMove:
		direction = -direction
	if direction > 0.0:
		hero.action.scale.x = -1.0
		hero.base_damagebox.scale.x = -1.0
		hero.PlayerDir = true
	elif direction < 0.0:
		hero.action.scale.x = 1.0
		hero.base_damagebox.scale.x = 1.0
		hero.PlayerDir = false
	var speed_multiplier := RIDE_SPEED_MULTIPLIER * _get_active_skill_speed_multiplier()
	if direction != 0.0:
		hero.velocity.x = (
			direction * hero.walk_speed * RoleProp.ws_up_power * hero.ReverseMoveSpeedMultiplier * speed_multiplier
		)
	else:
		hero.velocity.x = move_toward(
			hero.velocity.x, 0.0, hero.walk_speed * RoleProp.ws_up_power * hero.ReverseMoveSpeedMultiplier
		)
	_apply_active_skill_movement(_delta)
	if Input.is_action_just_pressed("jump") and not hero.is_Bound_to_the_ground:
		hero.jump()
	if Input.is_action_just_pressed("normalhit") and _normal_attack_cooldown <= 0.0:
		_normal_attack_cooldown = 0.5
		_cast_normal_attack()
	for slot in range(SKILL_ACTIONS.size()):
		if Input.is_action_just_pressed(SKILL_ACTIONS[slot]):
			cast_skill(slot)
			break
	return true


func _process(delta: float) -> void:
	if not _initialized or hero == null or not is_instance_valid(hero):
		return
	if not PlayerData.is_mount_system_unlocked():
		if bool(PlayerData.player_data.get(PlayerData.MOUNT_RIDING_KEY, false)):
			_set_riding(false)
		return
	_normal_attack_cooldown = maxf(0.0, _normal_attack_cooldown - delta)
	for skill_id_value in skill_cooldowns.keys():
		skill_cooldowns[skill_id_value] = maxf(0.0, float(skill_cooldowns[skill_id_value]) - delta)
	var active_mount := PlayerData.get_active_mount()
	var active_id := str(active_mount.get("ID", ""))
	if active_id != _current_mount_id:
		var was_riding := bool(PlayerData.player_data.get(PlayerData.MOUNT_RIDING_KEY, false))
		_refresh_mount_visual()
		_set_riding(was_riding or bool(PlayerData.player_data.get(PlayerData.MOUNT_AUTO_RIDE_KEY, false)))
		active_mount = PlayerData.get_active_mount()
	var riding := bool(PlayerData.player_data.get(PlayerData.MOUNT_RIDING_KEY, false))
	if mount_visual != null and is_instance_valid(mount_visual):
		mount_visual.scale.x = 1.0 if bool(hero.PlayerDir) else -1.0
		mount_visual.visible = riding and not active_mount.is_empty() and not hero.IsDeath
		if riding:
			_update_mount_locomotion()
	if mount_overlay_visual != null and is_instance_valid(mount_overlay_visual):
		mount_overlay_visual.scale.x = 1.0 if bool(hero.PlayerDir) else -1.0
		mount_overlay_visual.visible = riding and _current_mount_id == "1002800" and not hero.IsDeath
	if active_mount.is_empty():
		return
	if riding:
		_rest_elapsed = 0.0
		_fatigue_elapsed += delta
		if _fatigue_elapsed >= FATIGUE_TICK_SECONDS:
			_fatigue_elapsed -= FATIGUE_TICK_SECONDS
			active_mount["疲劳"] = maxi(0, int(active_mount.get("疲劳", 0)) - int(active_mount.get("骑乘消耗", 40)))
			if int(active_mount["疲劳"]) <= 0:
				_set_riding(false)
	else:
		_fatigue_elapsed = 0.0
		_rest_elapsed += delta
		if _rest_elapsed >= REST_TICK_SECONDS:
			_rest_elapsed -= REST_TICK_SECONDS
			active_mount["疲劳"] = mini(
				int(active_mount.get("疲劳上限", 2400)), int(active_mount.get("疲劳", 0)) + int(active_mount.get("休息恢复", 10))
			)


func cast_skill(slot: int) -> bool:
	if (
		not bool(PlayerData.player_data.get(PlayerData.MOUNT_RIDING_KEY, false))
		or slot < 0
		or slot >= active_skills.size()
	):
		return false
	var skill_value: Variant = active_skills[slot]
	if not (skill_value is Dictionary):
		return false
	var skill: Dictionary = skill_value
	var skill_id := str(skill.get("id", ""))
	if skill_id == "" or float(skill_cooldowns.get(skill_id, 0.0)) > 0.0:
		return false
	skill_cooldowns[skill_id] = float(skill.get("cooldown", 10.0))
	_begin_skill_movement(skill_id)
	_play_mount_action("aoyiSkill" if slot == 4 else "effect%d" % (slot + 1))
	_spawn_skill_effect(skill)
	return true


func _begin_skill_movement(skill_id: String) -> void:
	_skill_movement = MOUNT_CATALOG.get_official_movement(skill_id)
	if not _skill_movement.is_empty():
		_skill_movement["skill_id"] = skill_id
	_skill_movement_elapsed = 0.0
	_skill_movement_direction = 1.0 if bool(hero.PlayerDir) else -1.0
	_skill_movement_target = _nearest_monster_position()


func stop_skill_movement_on_hit(skill_id: String) -> void:
	if str(_skill_movement.get("skill_id", "")) != skill_id:
		return
	if bool(_skill_movement.get("stop_on_hit", false)):
		_skill_movement.clear()
		hero.velocity.x = 0.0


func _get_active_skill_speed_multiplier() -> float:
	if _skill_movement.is_empty() or str(_skill_movement.get("mode", "")) != "speed_buff":
		return 1.0
	var start := float(_skill_movement.get("start", 0.0))
	var end := start + float(_skill_movement.get("duration", 0.0))
	return (
		float(_skill_movement.get("multiplier", 1.0))
		if _skill_movement_elapsed >= start and _skill_movement_elapsed < end
		else 1.0
	)


func _apply_active_skill_movement(delta: float) -> void:
	if _skill_movement.is_empty():
		return
	_skill_movement_elapsed += delta
	var mode := str(_skill_movement.get("mode", ""))
	if mode == "forward":
		var start := float(_skill_movement.get("start", 0.0))
		var end := start + float(_skill_movement.get("duration", 0.0))
		if _skill_movement_elapsed >= start and _skill_movement_elapsed < end:
			hero.velocity.x = _skill_movement_direction * float(_skill_movement.get("speed", 0.0))
			if _skill_movement.has("speed_y"):
				hero.velocity.y = float(_skill_movement.get("speed_y", 0.0))
		elif _skill_movement_elapsed >= end:
			_skill_movement.clear()
	elif mode == "target_leap":
		_apply_target_leap_movement()
		if _skill_movement_elapsed >= float(_skill_movement.get("duration", 0.0)):
			_skill_movement.clear()
	elif mode == "speed_buff":
		var end := float(_skill_movement.get("start", 0.0)) + float(_skill_movement.get("duration", 0.0))
		if _skill_movement_elapsed >= end:
			_skill_movement.clear()


func _apply_target_leap_movement() -> void:
	var jump_start := float(_skill_movement.get("jump_start", 0.0))
	var jump_end := jump_start + float(_skill_movement.get("jump_duration", 0.0))
	if _skill_movement_elapsed >= jump_start and _skill_movement_elapsed < jump_end:
		hero.velocity = Vector2(
			_skill_movement_direction * float(_skill_movement.get("jump_speed_x", 0.0)),
			float(_skill_movement.get("jump_speed_y", 0.0))
		)
	var land_start := float(_skill_movement.get("land_start", 0.0))
	var land_duration := maxf(0.001, float(_skill_movement.get("land_duration", 0.2)))
	if _skill_movement_elapsed < land_start or _skill_movement_elapsed >= land_start + land_duration:
		return
	var offset := _skill_movement_target - hero.global_position
	var max_distance := float(_skill_movement.get("max_distance", 400.0))
	if offset.length() > max_distance:
		offset = offset.normalized() * max_distance
	hero.velocity = offset / maxf(land_duration - (_skill_movement_elapsed - land_start), 0.001)


func _nearest_monster_position() -> Vector2:
	var result := hero.global_position + Vector2(_skill_movement_direction * 400.0, 0.0)
	var nearest_distance := INF
	for value in get_tree().get_nodes_in_group("monsters"):
		if not (value is BaseMonster) or value.Hp <= 0 or value.NoTarget:
			continue
		var distance := hero.global_position.distance_squared_to(value.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			result = value.global_position
	return result


func _cast_normal_attack() -> void:
	_play_mount_action("attack1")
	_spawn_skill_effect(
		{"id": "mount_normal", "name": "坐骑普攻", "description": "坐骑普通攻击", "cooldown": 0.5, "power": 1.15, "kind": "claw"}
	)


func _spawn_skill_effect(skill: Dictionary) -> void:
	var effect := MOUNT_SKILL_EFFECT.new()
	effect.setup(hero, skill, _current_mount_id)
	var parent := get_tree().current_scene
	if parent == null:
		parent = hero.get_parent()
	parent.add_child(effect)


func _refresh_mount_visual() -> void:
	var mount := PlayerData.get_active_mount()
	_current_mount_id = str(mount.get("ID", ""))
	var skills_value: Variant = mount.get("技能", MOUNT_CATALOG.get_skills(_current_mount_id))
	active_skills = skills_value if skills_value is Array else []
	if mount_visual == null or not is_instance_valid(mount_visual):
		return
	if mount.is_empty():
		mount_visual.visible = false
		if mount_overlay_visual != null and is_instance_valid(mount_overlay_visual):
			mount_overlay_visual.visible = false
			mount_overlay_visual.set_process(false)
		return

	var visual_id := "1003100" if _current_mount_id == "1002200" else _current_mount_id
	MOUNT_VISUAL.prewarm_mount_assets(visual_id)
	mount_visual.setup(visual_id, "idle")
	mount_visual.set_async_texture_loading(true)
	_refresh_rider_pose()
	mount_visual.scale = Vector2(1.0 if bool(hero.PlayerDir) else -1.0, 1.0)
	mount_visual.position = Vector2(0.0, _get_hero_collision_bottom_y())
	mount_visual.visible = bool(PlayerData.player_data.get(PlayerData.MOUNT_RIDING_KEY, false))
	if mount_overlay_visual != null and is_instance_valid(mount_overlay_visual):
		if _current_mount_id == "1002800":
			mount_overlay_visual.setup(visual_id, "res2")
			mount_overlay_visual.set_async_texture_loading(true)
			mount_overlay_visual.scale = mount_visual.scale
			mount_overlay_visual.position = mount_visual.position
			mount_overlay_visual.visible = mount_visual.visible
		else:
			mount_overlay_visual.visible = false
			mount_overlay_visual.set_process(false)


func _refresh_rider_pose() -> void:
	if mount_visual == null or not is_instance_valid(mount_visual):
		return
	var role_id := _get_rider_role_id()
	if role_id <= 0 or _current_mount_id == "":
		mount_visual.clear_rider_pose()
		return
	var pose_path := "%s/Role%d/%s.tscn" % [RIDER_ADJUSTMENT_ROOT, role_id, _current_mount_id]
	var pose_scene := load(pose_path) as PackedScene
	if pose_scene == null:
		mount_visual.clear_rider_pose()
		push_error("骑乘 2D 调整场景无法加载: %s" % pose_path)
		return
	var body_texture: Texture2D = null
	var body_front_texture: Texture2D = null
	var horizontal_frames := 1
	var vertical_frames := 1
	if role_id == 6 and hero is NeZhaHero:
		var rider_textures := (hero as NeZhaHero).get_mount_rider_textures()
		body_texture = rider_textures.get("body") as Texture2D
		body_front_texture = rider_textures.get("body_front") as Texture2D
	else:
		body_texture = hero.RoleBody.texture
		horizontal_frames = hero.RoleBody.hframes
		vertical_frames = hero.RoleBody.vframes
	mount_visual.set_rider_pose(
		pose_scene,
		pose_path,
		body_texture,
		body_front_texture,
		horizontal_frames,
		vertical_frames,
		int(RIDER_POSE_FRAMES.get(role_id, 0))
	)


func refresh_rider_appearance() -> void:
	_refresh_rider_pose()


func _get_rider_role_id() -> int:
	if hero is Role1Hero:
		return 1
	if hero is Role2Hero:
		return 2
	if hero is Role3Hero:
		return 3
	if hero is Role4Hero:
		return 4
	if hero is Role5Hero:
		return 5
	if hero is NeZhaHero:
		return 6
	return 0


func _get_hero_collision_bottom_y() -> float:
	if hero == null or not is_instance_valid(hero):
		return 0.0
	var collision := hero.get_node_or_null("pz") as CollisionShape2D
	if collision == null or collision.shape == null:
		return 0.0
	var half_extents := Vector2.ZERO
	if collision.shape is CapsuleShape2D:
		var capsule := collision.shape as CapsuleShape2D
		half_extents = Vector2(capsule.radius, capsule.height * 0.5)
	elif collision.shape is RectangleShape2D:
		half_extents = (collision.shape as RectangleShape2D).size * 0.5
	elif collision.shape is CircleShape2D:
		var radius := (collision.shape as CircleShape2D).radius
		half_extents = Vector2(radius, radius)
	else:
		return collision.position.y
	var collision_in_hero := hero.global_transform.affine_inverse() * collision.global_transform
	var transformed_half_height := (
		absf(collision_in_hero.x.y) * half_extents.x + absf(collision_in_hero.y.y) * half_extents.y
	)
	return collision_in_hero.origin.y + transformed_half_height


func _play_mount_action(action_name: String) -> void:
	if mount_visual == null or not is_instance_valid(mount_visual):
		return
	var requested := action_name
	if not mount_visual.has_animation(requested):
		requested = "attack1"
	_mount_action_locked = mount_visual.play(requested, true)


func _update_mount_locomotion() -> void:
	if _mount_action_locked or mount_visual == null:
		return
	var locomotion := "idle"
	if not hero.is_on_floor():
		if hero.velocity.y < 0.0:
			locomotion = (
				"jumpTwo" if int(hero.jump_count) > 1 and mount_visual.has_animation("jumpTwo") else "jumpNormal"
			)
		else:
			locomotion = "jumpDown"
	elif absf(hero.velocity.x) > 1.0:
		locomotion = "walk"
	if not mount_visual.has_animation(locomotion):
		locomotion = "walk" if locomotion.begins_with("jump") and mount_visual.has_animation("walk") else "idle"
	mount_visual.play(locomotion)


func _on_mount_animation_finished(_animation_name: String) -> void:
	_mount_action_locked = false
	if bool(PlayerData.player_data.get(PlayerData.MOUNT_RIDING_KEY, false)):
		_update_mount_locomotion()

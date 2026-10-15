extends Node2D

const MONSTER_SCENE: = preload("res://Scene/Monster/EastContinentMonster.tscn")
const OUTPUT_PATH: = "res://.tmp/east_late_skill_effects.png"

var _failed: = false


class TrackingTarget:
	extends BaseHero

	func _ready() -> void :
		pass

	func _physics_process(_delta: float) -> void :
		pass

	func _add_role_hit_effect_throttled() -> void :
		pass

	func _pet_turtle_link_unit() -> Node:
		return null

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	var background: = Polygon2D.new()
	background.polygon = PackedVector2Array([
		Vector2.ZERO, Vector2(1152.0, 0.0), Vector2(1152.0, 648.0), Vector2(0.0, 648.0), 
	])
	background.color = Color("18212a")
	background.z_index = -100
	add_child(background)

	var old_source_player: Variant = RoleProp.SourcePlayer
	var old_role_position: Variant = RoleProp.role_pos
	RoleProp.SourcePlayer = null
	var projectiles: Array[WutaiMinghaiProjectile] = []
	projectiles.append( await _spawn_effect(3222, &"hit1", Vector2(170.0, 390.0), Vector2(460.0, 390.0)))
	var tracked_target: = _create_tracking_target()
	tracked_target.position = Vector2(780.0, 390.0)
	add_child(tracked_target)
	RoleProp.SourcePlayer = tracked_target
	var tracking_projectile: = await _spawn_effect(
		3200, &"hit3", Vector2(535.0, 300.0), tracked_target.position
	)
	projectiles.append(tracking_projectile)
	RoleProp.SourcePlayer = null
	projectiles.append( await _spawn_effect(3343, &"hit2", Vector2(930.0, 340.0), Vector2(760.0, 390.0)))

	await get_tree().create_timer(0.1, false).timeout
	var initial_rotation: float = float(tracking_projectile.get_node("middle").rotation)\
	if tracking_projectile != null and is_instance_valid(tracking_projectile) else 0.0
	tracked_target.position = Vector2(650.0, 540.0)
	await get_tree().create_timer(0.2, false).timeout
	if tracking_projectile != null and is_instance_valid(tracking_projectile):
		var middle: = tracking_projectile.get_node("middle") as Node2D
		_check(tracking_projectile.track_target, "怪物3200追踪特效没有锁定目标")
		_check(
			absf(angle_difference(middle.rotation, tracking_projectile.motion_velocity.angle())) < 0.01, 
			"怪物3200追踪特效角度没有跟随飞行方向"
		)
		_check(
			absf(angle_difference(initial_rotation, middle.rotation)) > 0.1, 
			"怪物3200追踪特效没有随目标移动改变角度"
		)

	var saw_visual: Dictionary = {}
	var saw_collision: Dictionary = {}
	for sample_index in range(20):
		await get_tree().create_timer(0.05, false).timeout
		for projectile: WutaiMinghaiProjectile in projectiles:
			if projectile == null or not is_instance_valid(projectile):
				continue
			var stream: = projectile.get_node_or_null("middle/VisualStream") as StreamedPngEffect
			if stream != null and stream.frame_paths.size() > 0:
				saw_visual[projectile.skill_name] = true
			var shape_node: = projectile.get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
			var shape: = shape_node.shape as RectangleShape2D if shape_node != null else null
			if shape != null and shape.size.x > 1.0 and shape.size.y > 1.0:
				saw_collision[projectile.skill_name] = true
	await RenderingServer.frame_post_draw
	for projectile: WutaiMinghaiProjectile in projectiles:
		if projectile == null or not is_instance_valid(projectile):
			continue
		_check(saw_visual.has(projectile.skill_name), "%s没有可见帧" % projectile.skill_name)
		_check(saw_collision.has(projectile.skill_name), "%s没有有效碰撞范围" % projectile.skill_name)

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tmp"))
	var image: = get_viewport().get_texture().get_image()
	var screenshot_path: = ProjectSettings.globalize_path(OUTPUT_PATH)
	_check(image != null and image.save_png(screenshot_path) == OK, "无法保存后续关卡技能截图")
	await _audit_all_late_effects(tracked_target)
	await _audit_multiphase_effects(tracked_target)
	RoleProp.SourcePlayer = old_source_player
	RoleProp.role_pos = old_role_position
	if not _failed:
		print("EAST_LATE_SKILL_EFFECTS_VISUAL_PROBE_OK effects=3 screenshot=" + screenshot_path)
	get_tree().quit(1 if _failed else 0)

func _spawn_effect(
	monster_id: int, 
	attack_name: StringName, 
	monster_position: Vector2, 
	target_position: Vector2
) -> WutaiMinghaiProjectile:
	var monster: = MONSTER_SCENE.instantiate() as EastContinentMonster
	monster.monster_kind = monster_id
	monster.position = monster_position
	add_child(monster)
	await get_tree().process_frame
	monster.set_process(false)
	monster.set_physics_process(false)
	RoleProp.role_pos = target_position
	var effect_key: = monster._late_effect_key(attack_name)
	var effect_config: Dictionary = EastContinentMonster.LATE_SKILL_EFFECTS[effect_key]
	monster._spawn_late_skill_effect(attack_name, effect_config, 0, 1)
	await get_tree().process_frame
	for child: Node in monster.bullet.get_children():
		if child is WutaiMinghaiProjectile:
			(child as WutaiMinghaiProjectile).lifetime = 10.0
			return child as WutaiMinghaiProjectile
	_check(false, "怪物%d没有生成%s特效" % [monster_id, str(attack_name)])
	return null

func _audit_all_late_effects(tracked_target: TrackingTarget) -> void :
	for effect_key_value: Variant in EastContinentMonster.LATE_SKILL_EFFECTS:
		var effect_key: = str(effect_key_value)
		var key_parts: = effect_key.split(":", false, 1)
		if key_parts.size() != 2:
			continue
		var monster_id: = int(key_parts[0])
		var attack_name: = StringName(key_parts[1])
		tracked_target.position = Vector2(980.0, 520.0)
		RoleProp.SourcePlayer = tracked_target
		RoleProp.role_pos = tracked_target.global_position

		var monster: = MONSTER_SCENE.instantiate() as EastContinentMonster
		monster.monster_kind = monster_id
		monster.position = Vector2(240.0, 240.0)
		add_child(monster)
		await get_tree().process_frame
		monster.set_process(false)
		monster.set_physics_process(false)
		var effect_config: Dictionary = EastContinentMonster.LATE_SKILL_EFFECTS[effect_key]
		var repeats: = maxi(int(effect_config.get("repeats", 1)), 1)
		monster._spawn_late_skill_effect(attack_name, effect_config, 0, repeats)
		await get_tree().process_frame

		var projectile: WutaiMinghaiProjectile = null
		for child: Node in monster.bullet.get_children():
			if child is WutaiMinghaiProjectile:
				projectile = child as WutaiMinghaiProjectile
				break
		_check(projectile != null, "怪物%s没有生成可检查的技能特效" % effect_key)
		if projectile != null:
			projectile.lifetime = 10.0
			var stream: = projectile.get_node_or_null("middle/VisualStream") as StreamedPngEffect
			var shape_node: = projectile.get_node_or_null(
				"middle/HitBox/Hit_Box"
			) as CollisionShape2D
			var shape: = shape_node.shape as RectangleShape2D if shape_node != null else null
			_check(
				stream != null and stream.frame_paths.size() > 0, 
				"怪物%s特效没有可见帧" % effect_key
			)
			_check(
				shape != null and shape.size.x > 1.0 and shape.size.y > 1.0, 
				"怪物%s特效没有有效碰撞范围" % effect_key
			)
			var targeted: = bool(effect_config.get("targeted", false))
			var moving: = projectile.motion_velocity.length_squared() > 1.0
			if targeted and moving:
				_check(projectile.orient_to_motion, "怪物%s特效没有启用动态角度" % effect_key)
				var middle: = projectile.get_node("middle") as Node2D
				_check(
					absf(angle_difference(
						middle.rotation, projectile.motion_velocity.angle()
					)) < 0.01, 
					"怪物%s特效角度和飞行方向不一致" % effect_key
				)
				var should_track: = bool(effect_config.get("track_target", true))
				if should_track:
					_check(projectile.track_target, "怪物%s特效没有锁定目标" % effect_key)
					var initial_angle: = middle.rotation
					_check(
						projectile.target_offset.distance_to(Vector2(0.0, -5.0)) < 0.1, 
						"怪物%s没有瞄准人物受击盒中心" % effect_key
					)
					tracked_target.position += Vector2(-180.0, 120.0)
					RoleProp.role_pos = tracked_target.global_position
					await get_tree().create_timer(0.08, false).timeout
					_check(
						absf(angle_difference(initial_angle, middle.rotation)) > 0.03, 
						"怪物%s没有随目标移动改变角度" % effect_key
					)
					_check(
						absf(angle_difference(
							middle.rotation, projectile.motion_velocity.angle()
						)) < 0.01, 
						"怪物%s追踪后的特效角度不正确" % effect_key
					)
			if effect_config.has("spawn_above_target"):
				_check(
					projectile.motion_velocity.y > 0.0\
					and absf(projectile.motion_velocity.x) < 0.1, 
					"怪物%s落雷没有垂直落向目标区域" % effect_key
				)
		monster.queue_free()
		await get_tree().process_frame
	RoleProp.SourcePlayer = null

func _audit_multiphase_effects(tracked_target: TrackingTarget) -> void :
	tracked_target.position = Vector2(900.0, 500.0)
	RoleProp.SourcePlayer = tracked_target
	RoleProp.role_pos = tracked_target.global_position

	var bird: = await _create_audit_monster(3309, Vector2(300.0, 280.0))
	bird._attack_serial = 1
	bird._start_late_skill_effect(&"hit1", 1)
	var max_bird_projectiles: = 0
	for _sample in range(12):
		await get_tree().create_timer(0.05, false).timeout
		max_bird_projectiles = maxi(max_bird_projectiles, bird.bullet.get_child_count())
	_check(max_bird_projectiles >= 4, "琉璃鸟没有完整释放四方向连射")
	bird.queue_free()
	await get_tree().process_frame

	var fox: = await _create_audit_monster(3310, Vector2(420.0, 390.0))
	fox._attack_serial = 1
	fox._start_late_skill_effect(&"hit3", 1)
	await get_tree().create_timer(2.6, false).timeout
	var rain_count: = 0
	for child: Node in fox.bullet.get_children():
		if child is WutaiMinghaiProjectile\
		and (child as WutaiMinghaiProjectile).atlas_sequence == "effect3_2":
			rain_count += 1
	_check(rain_count == 9, "九尾天狐没有在目标区域生成九道落雨特效")
	fox.queue_free()
	await get_tree().process_frame

	var master: = await _create_audit_monster(3352, Vector2(380.0, 300.0))
	master._attack_serial = 1
	master._start_late_skill_effect(&"hit2", 1)
	await get_tree().create_timer(1.3, false).timeout
	var saw_target_burst: = false
	for child: Node in master.bullet.get_children():
		if child is WutaiMinghaiProjectile\
		and (child as WutaiMinghaiProjectile).atlas_sequence == "effect2_2":
			saw_target_burst = true
			break
	_check(saw_target_burst, "通天教主没有在目标两侧生成落点特效")
	master.queue_free()
	await get_tree().process_frame
	RoleProp.SourcePlayer = null

func _create_audit_monster(monster_id: int, spawn_position: Vector2) -> EastContinentMonster:
	var monster: = MONSTER_SCENE.instantiate() as EastContinentMonster
	monster.monster_kind = monster_id
	monster.position = spawn_position
	add_child(monster)
	await get_tree().process_frame
	monster.set_process(false)
	monster.set_physics_process(false)
	return monster

func _create_tracking_target() -> TrackingTarget:
	var hero: = TrackingTarget.new()
	hero.name = "TrackedTarget"
	hero.add_child(_named_node(Timer.new(), "ZhenFa"))
	hero.add_child(_named_node(AnimationPlayer.new(), "RolePlayer"))
	hero.add_child(_named_node(Node2D.new(), "Damage_Text"))
	hero.add_child(_named_node(CollisionShape2D.new(), "pz"))
	hero.add_child(_named_node(Timer.new(), "WSTimer"))
	hero.add_child(_named_node(Node2D.new(), "MagicWeapon"))
	hero.add_child(_named_node(Label.new(), "Name_"))
	hero.add_child(_named_node(Node2D.new(), "Bullet"))
	hero.add_child(_named_node(Node.new(), "Buff"))
	hero.add_child(_named_node(AnimatedSprite2D.new(), "tx"))

	var action: = _named_node(Node2D.new(), "Action") as Node2D
	hero.add_child(action)
	action.add_child(_named_node(Sprite2D.new(), "RoleBody"))
	action.add_child(_named_node(Sprite2D.new(), "RoleEquipment"))
	action.add_child(_named_node(AnimatedSprite2D.new(), "Wings"))
	var effect_body: = _named_node(Node2D.new(), "EffectBody") as Node2D
	action.add_child(effect_body)
	for part_name in ["toukui", "jianjia", "huwan", "shenti", "yaodai", "xiabai", "wuqi"]:
		effect_body.add_child(_named_node(AnimatedSprite2D.new(), part_name))

	var damage_box: = _named_node(Node2D.new(), "base_damagebox") as Node2D
	damage_box.position = Vector2(0.0, -30.0)
	hero.add_child(damage_box)
	var hurt_area: = _named_node(Area2D.new(), "HurtBox") as Area2D
	hurt_area.collision_layer = 128
	hurt_area.collision_mask = 4
	damage_box.add_child(hurt_area)
	var hurt_shape: = _named_node(CollisionShape2D.new(), "HurtBox") as CollisionShape2D
	hurt_shape.position = Vector2(0.0, 25.0)
	var capsule: = CapsuleShape2D.new()
	capsule.radius = 20.0
	capsule.height = 98.0
	hurt_shape.shape = capsule
	hurt_area.add_child(hurt_shape)
	hurt_area.area_entered.connect(hero._on_hurt_box_area_entered)
	return hero

func _named_node(node: Node, node_name: String) -> Node:
	node.name = node_name
	return node

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("EAST_LATE_SKILL_EFFECTS_VISUAL_PROBE_FAIL " + message)

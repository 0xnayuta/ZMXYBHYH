extends SceneTree

const OUTPUT_FILE: = "mount_runtime_visual_probe.png"
const IDLE_OUTPUT_FILE: = "mount_runtime_idle_probe.png"
const MOUNT_CATALOG: = preload("res://Script/Mount/MountCatalog.gd")
const MOUNT_VISUAL: = preload("res://Script/Mount/MountVisual.gd")
const SKILL_ACTIONS: = ["slz", "lys", "lyfb", "hmz", "hytj"]

var failures: Array[String] = []

func _initialize() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _run() -> void :
	var player_data_node: = root.get_node_or_null("PlayerData")
	_check(player_data_node != null, "PlayerData Autoload 未加载")
	if player_data_node == null:
		_finish(1)
		return
	var original: Dictionary = player_data_node.player_data.duplicate(true)
	player_data_node.player_data["Myself"] = 1
	player_data_node.player_data["通天教主"] = 1
	player_data_node.call("ensure_mount_data")
	player_data_node.call("set_active_mount", "1003900")
	player_data_node.call("set_mount_auto_ride", false)
	player_data_node.call("set_mount_riding", false)
	root.size = Vector2i(940, 590)
	var background: = ColorRect.new()
	background.color = Color(0.08, 0.1, 0.14, 1.0)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)
	var hero_scene: = load("res://Scene/Hero/Role_1/Role1.tscn") as PackedScene
	_check(hero_scene != null, "孙悟空角色场景无法加载")
	if hero_scene == null:
		player_data_node.player_data = original
		_finish(1)
		return
	var hero: = hero_scene.instantiate()
	hero.position = Vector2(470.0, 430.0)
	root.add_child(hero)
	await process_frame
	await process_frame
	hero.set_process(false)
	hero.set_physics_process(false)
	var original_title_position: Vector2 = hero.tx.position
	var runtime_script: = load("res://Script/Mount/MountRuntime.gd")
	_check(runtime_script != null, "坐骑战斗运行时脚本无法加载")
	if runtime_script == null:
		player_data_node.player_data = original
		_finish(1)
		return
	var runtime: Node = runtime_script.new()
	runtime.name = "MountRuntime"
	hero.add_child(runtime)
	runtime.call("setup", hero)
	await process_frame
	await process_frame
	await process_frame
	runtime.set_process(false)
	var summon_event: = InputEventKey.new()
	summon_event.pressed = true
	summon_event.physical_keycode = KEY_Z
	runtime.call("_unhandled_input", summon_event)
	await process_frame
	var mount_hud: = runtime.get_node_or_null("MountHud")
	_check(mount_hud == null, "右上角坐骑状态面板仍然存在")
	if mount_hud != null:
		_check(mount_hud.find_children("*", "HBoxContainer", true, false).is_empty(), "仍然创建了独立坐骑技能栏")
	var visual: = hero.get_node_or_null("MountVisual") as Node2D
	var collision_ground_y: float = float(hero.global_position.y)
	_check(visual != null, "战斗坐骑原版模型未创建")
	if visual != null:
		var back: = visual.get_node_or_null("Back") as Sprite2D
		var front: = visual.get_node_or_null("Front") as Sprite2D
		_check(back != null and front != null, "战斗坐骑前后层未创建")
		_check(
			(back != null and back.visible and back.texture != null)
			or (front != null and front.visible and front.texture != null), 
			"战斗坐骑原版动画图集未加载"
		)
		_check(visual.visible, "骑乘状态下坐骑不可见")
		_check(str(visual.get("mount_id")) == "1003900", "战斗坐骑模型 ID 错误")
		_check(str(visual.get("animation_name")) == "idle", "召唤后没有播放原版 idle")
		var rider: = visual.get_node_or_null("Rider") as Node2D
		_check(rider != null and rider.visible, "孙悟空没有显示在坐骑 ride 挂点")
		_check(front != null and rider != null and front.z_index > rider.z_index, "坐骑前景特效层没有覆盖人物层")
		if rider != null:
			var rider_pose_scene: = load("res://Scene/Mount/RiderAdjustments/Role1/1003900.tscn") as PackedScene
			var adjustment: = rider_pose_scene.instantiate() as Node2D if rider_pose_scene != null else null
			var editable_pose: = adjustment.get_node_or_null("Pose") as Node2D if adjustment != null else null
			var rider_pose: = rider.get_node_or_null("Pose") as Node2D
			var rider_body: = rider.get_node_or_null("Pose/Body") as Sprite2D
			var rider_body_front: = rider.get_node_or_null("Pose/BodyFront") as Sprite2D
			var rider_equipment: = rider.get_node_or_null("Pose/Equipment") as Sprite2D
			_check(
				editable_pose != null and rider_pose != null and rider_pose.transform.is_equal_approx(editable_pose.transform), 
				"运行时覆盖了人物×坐骑调整场景中的 Pose 变换"
			)
			_check(rider_pose != null and rider_pose.scale.is_equal_approx(Vector2.ONE), "孙悟空骑乘姿态方向被额外翻转")
			_check(rider_body != null and rider_body.texture != null and rider_body.frame == 49, "孙悟空身体没有使用装备图第九行第二格")
			_check(rider_equipment == null, "骑乘姿态仍然创建了武器层")
			_check(rider_body_front != null and not rider_body_front.visible, "孙悟空错误显示哪吒身体前层")
			var editable_body: = editable_pose.get_node_or_null("Body") as Sprite2D if editable_pose != null else null
			_check(
				editable_body != null and rider_body != null and rider_body.transform.is_equal_approx(editable_body.transform), 
				"运行时覆盖了骑乘姿态场景中的 Body 变换"
			)
			_check(rider_body != null and rider_body.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR, "孙悟空骑乘身体没有沿用人物线性过滤")
			if adjustment != null:
				adjustment.free()
		_check((visual.call("get_registration_anchor") as Vector2).is_equal_approx(Vector2.ZERO), "战斗坐骑没有保留原始骨架落地点")
		var player_collision: = hero.get_node_or_null("pz") as CollisionShape2D
		_check(player_collision != null and player_collision.shape != null, "玩家 pz 碰撞体不存在")
		if player_collision != null and player_collision.shape != null:
			var collision_bottom_y: = _collision_bottom_y_in_hero(hero, player_collision)
			collision_ground_y = hero.to_global(Vector2(0.0, collision_bottom_y)).y
			_check(is_equal_approx(visual.position.y, collision_bottom_y), "坐骑模型没有对齐玩家碰撞体脚底")
			var visual_foot_y: float = visual.to_global(Vector2.ZERO).y
			var collision_foot_y: float = hero.to_global(Vector2(0.0, collision_bottom_y)).y
			_check(absf(visual_foot_y - collision_foot_y) <= 2.0, "坐骑骨架原始落地点没有对齐人物脚底")
	_check( not hero.action.visible, "召唤坐骑后人物模型没有隐藏")
	_check(hero.tx.position.is_equal_approx(original_title_position + Vector2(0.0, -80.0)), "骑乘后称号没有上移避让人物")
	_check( not hero.is_using_skills, "骑乘状态错误占用人物施法状态并阻止无双")
	_check(is_equal_approx(float(hero.mount_speed_multiplier), 1.2), "骑乘移速未提高 20%")
	_check(bool(runtime.call("process_mounted_control", 0.016)), "骑乘状态没有接管人物控制")
	_check( not hero.is_using_skills, "骑乘控制每帧错误恢复人物施法状态")
	runtime.call("_cast_normal_attack")
	if visual != null:
		_check(str(visual.get("animation_name")) == "attack1", "坐骑普攻没有播放原版 attack1")
	_check(bool(runtime.call("cast_skill", 0)), "坐骑技能无法释放")
	if visual != null:
		_check(str(visual.get("animation_name")) == "effect1", "第一坐骑技能没有播放原版 effect1")
		var skill_animation: Dictionary = visual.get("_animation_data")
		var has_skill_front_layer: = false
		for frame_value in skill_animation.get("frames", []):
			if frame_value is Dictionary and frame_value.get("front", null) is Dictionary:
				has_skill_front_layer = true
				break
		_check(has_skill_front_layer, "坐骑技能动画没有可覆盖人物的前景特效帧")
	hero.velocity = Vector2.ZERO
	runtime.call("_apply_active_skill_movement", 0.69)
	_check(is_zero_approx(hero.velocity.x), "屠戮之角在官方21帧前提前位移")
	runtime.call("_apply_active_skill_movement", 0.02)
	_check(is_equal_approx(absf(hero.velocity.x), 300.0), "屠戮之角没有按官方帧和速度位移")
	runtime.call("stop_skill_movement_on_hit", "3104200")
	_check(is_equal_approx(absf(hero.velocity.x), 300.0), "屠戮之角错误套用了独立弹幕的命中停止规则")
	var cooldowns: Dictionary = runtime.get("skill_cooldowns")
	_check(cooldowns.size() > 0, "坐骑技能释放后没有进入冷却")
	_check(str((runtime.call("get_mount_skill_for_slot", 0) as Dictionary).get("id", "")) == "3104200", "人物技能槽未获得当前坐骑技能")
	_check(float(runtime.call("get_mount_skill_cooldown", 0)) > 0.0, "坐骑技能冷却未提供给人物技能槽")
	_check(bool(runtime.call("cast_skill", 2)), "带原版弹幕的坐骑技能无法释放")
	await process_frame
	var effect_script: = load("res://Script/Mount/MountSkillEffect.gd")
	var official_effect_found: = false
	var official_effect_above_rider: = false
	for child in root.get_children():
		if child.get_script() == effect_script and str((child.get("skill") as Dictionary).get("id", "")) == "3104400":
			var effect_visuals: Array = child.get("_effect_visuals")
			official_effect_found = not effect_visuals.is_empty()
			official_effect_above_rider = visual != null and child.z_index > visual.z_index
			child.call("_process", 0.2)
			break
	_check(official_effect_found, "坐骑技能释放后没有创建原版独立弹幕")
	_check(official_effect_above_rider, "坐骑独立技能特效没有覆盖骑乘人物")
	var role_hud_scene: = load("res://Scene/Base/BaseRole.tscn") as PackedScene
	_check(role_hud_scene != null, "桌面人物技能栏场景无法加载")
	var role_hud = role_hud_scene.instantiate() if role_hud_scene != null else null
	if role_hud != null:
		role_hud.Player = hero
		root.add_child(role_hud)
		await process_frame
		role_hud.set_physics_process(false)
		role_hud.call("_set_skill_pic")
		await physics_frame
		var desktop_keys: = ["Y", "U", "I", "O", "L"]
		for slot in range(5):
			var mount_skill: Dictionary = runtime.call("get_mount_skill_for_slot", slot)
			var mount_skill_id: = str(mount_skill.get("id", ""))
			var icon = role_hud.get_node_or_null("role_menu/skil_%d/%s" % [slot + 1, desktop_keys[slot]])
			_check(icon != null, "桌面第 %d 个技能槽没有创建坐骑图标" % (slot + 1))
			if icon != null:
				_check(int(icon.get("mount_skill_slot")) == slot, "桌面第 %d 个技能槽没有切换为坐骑技能" % (slot + 1))
				_check(str(icon.get("SkillName")) == mount_skill_id, "桌面第 %d 个技能槽坐骑技能 ID 错误" % (slot + 1))
				_check(str(icon.get("_loaded_icon_path")) == MOUNT_CATALOG.get_icon_path(mount_skill_id), "桌面第 %d 个技能槽仍在显示人物技能图标" % (slot + 1))
				_check(icon.texture != null, "桌面第 %d 个坐骑技能图标未加载" % (slot + 1))
				if slot == 0:
					_check(float(icon.get_node("PicBox").value) > 0.0, "桌面坐骑技能冷却遮罩未读取坐骑冷却")
	var controls_scene: = load("res://Scene/Tools/set_com.tscn") as PackedScene
	_check(controls_scene != null, "人物技能槽场景无法加载")
	var controls = controls_scene.instantiate() if controls_scene != null else null
	if controls != null:
		root.add_child(controls)
		await process_frame
		await physics_frame
		var key_list_value: Variant = controls.get("keyList")
		_check(key_list_value is Array and key_list_value.size() >= 5, "人物五个技能槽未创建")
		if key_list_value is Array and key_list_value.size() >= 5:
			var key_list: Array = key_list_value
			for slot in range(5):
				var user_key = key_list[slot]
				var mount_skill: Dictionary = runtime.call("get_mount_skill_for_slot", slot)
				var mount_skill_id: = str(mount_skill.get("id", ""))
				_check(int(user_key.get("mount_skill_slot")) == slot, "第 %d 个人物技能槽未切换为坐骑覆盖" % (slot + 1))
				_check(str(user_key.get("SkillName")) == mount_skill_id, "第 %d 个人物技能槽坐骑图标 ID 错误" % (slot + 1))
				_check(str(user_key.get("action")) == SKILL_ACTIONS[slot], "第 %d 个人物技能槽按键动作被修改" % (slot + 1))
				if mount_skill_id != "":
					var icon_path: = MOUNT_CATALOG.get_icon_path(mount_skill_id)
					_check(str(user_key.get("res_")) == "frame:%s:0.8" % icon_path, "第 %d 个人物技能槽未显示坐骑技能图标" % (slot + 1))
			_check(key_list.size() > 10, "手机坐骑召唤按钮未创建")
			if key_list.size() > 10:
				var mount_button = key_list[10]
				_check(mount_button.visible, "出战坐骑存在时手机 Z 按钮未显示")
				_check(mount_button.position == Vector2(-215.0, -254.0), "手机 Z 按钮没有放在 P 按钮左侧")
				_check(str(mount_button.get("action")) == "MountToggle", "手机 Z 按钮没有绑定坐骑召唤")
	hero.PlayerDir = false
	runtime.call("_process", 0.0)
	if visual != null:
		_check(is_equal_approx(visual.scale.x, -1.0), "坐骑未以骨架原点向左翻转")
	hero.PlayerDir = true
	runtime.call("_process", 0.0)
	if visual != null:
		_check(is_equal_approx(visual.scale.x, 1.0), "坐骑未以骨架原点向右翻转")
	var mount_before: Dictionary = player_data_node.call("get_active_mount")
	var fatigue_before: = int(mount_before.get("疲劳", 0))
	runtime.call("_process", 10.0)
	var mount_after: Dictionary = player_data_node.call("get_active_mount")
	_check(int(mount_after.get("疲劳", 0)) == fatigue_before - int(mount_after.get("骑乘消耗", 40)), "骑乘疲劳未按原版规则消耗")
	player_data_node.call("set_active_mount", "1002200")
	runtime.call("_refresh_mount_visual")
	await process_frame
	if visual != null:
		_check(str(visual.get("mount_id")) == "1003100", "圣虎骑乘截图没有使用最终形态模型")
		_check(bool(visual.call("play", "idle", true)), "战斗截图无法恢复坐骑 idle")
		var tiger_rider: = visual.get_node("Rider") as Node2D
		var tiger_front: = visual.get_node_or_null("Front") as Sprite2D
		_check(tiger_front != null and tiger_front.visible and tiger_front.texture != null, "圣虎身上前景光效没有覆盖人物")
		RenderingServer.force_draw()
		await process_frame
		var idle_image: = root.get_texture().get_image()
		_check(idle_image != null and not idle_image.is_empty(), "圣虎骑乘待机截图为空")
		if idle_image != null and not idle_image.is_empty():
			var idle_output_path: = OS.get_environment("TEMP").path_join(IDLE_OUTPUT_FILE)
			_check(idle_image.save_png(idle_output_path) == OK, "圣虎骑乘待机截图保存失败")
			print("MOUNT_RUNTIME_IDLE_VISUAL:%s" % idle_output_path)
		visual.call("set_async_texture_loading", false)
		_check(bool(visual.call("play", "effect1", true)), "圣虎前景技能截图无法播放 effect1")
		visual.call("_process", 20.0 / 30.0)
		var tiger_animation: Dictionary = visual.get("_animation_data")
		var tiger_frames: Array = tiger_animation.get("frames", [])
		var tiger_frame_index: = int(visual.get("frame_index"))
		var tiger_frame: Dictionary = tiger_frames[tiger_frame_index] if tiger_frame_index < tiger_frames.size() else {}
		var tiger_ride: Dictionary = tiger_frame.get("ride", {})
		var tiger_origin: Dictionary = tiger_ride.get("origin", {})
		var expected_rider_transform: = Transform2D(
			Vector2(float(tiger_ride.get("a", 1.0)), float(tiger_ride.get("b", 0.0))), 
			Vector2(float(tiger_ride.get("c", 0.0)), float(tiger_ride.get("d", 1.0))), 
			Vector2(float(tiger_ride.get("tx", 0.0)), float(tiger_ride.get("ty", 0.0)))
		)
		if tiger_origin.is_empty():
			expected_rider_transform *= Transform2D(
				0.0, 
				MOUNT_VISUAL.RIDER_SLOT_ORIGINS.get("1003100", Vector2.ZERO)
			)
		else:
			expected_rider_transform *= Transform2D(
				Vector2(float(tiger_origin.get("a", 1.0)), float(tiger_origin.get("b", 0.0))), 
				Vector2(float(tiger_origin.get("c", 0.0)), float(tiger_origin.get("d", 1.0))), 
				Vector2(float(tiger_origin.get("tx", 0.0)), float(tiger_origin.get("ty", 0.0)))
			)
		_check(tiger_rider.transform.is_equal_approx(expected_rider_transform), "圣虎 ride 挂点没有合并原版槽位原点")
		_check(tiger_front != null and tiger_front.visible and tiger_front.texture != null, "圣虎技能前景特效没有覆盖人物")
		visual.set_process(false)
	var ground_line: = Line2D.new()
	ground_line.width = 2.0
	ground_line.default_color = Color(1.0, 0.2, 0.15, 1.0)
	ground_line.points = PackedVector2Array([Vector2(40.0, collision_ground_y), Vector2(900.0, collision_ground_y)])
	ground_line.z_index = 100
	root.add_child(ground_line)
	RenderingServer.force_draw()
	await process_frame
	var image: = root.get_texture().get_image()
	_check(image != null and not image.is_empty(), "战斗坐骑截图为空")
	if image != null and not image.is_empty():
		var output_path: = OS.get_environment("TEMP").path_join(OUTPUT_FILE)
		_check(image.save_png(output_path) == OK, "战斗坐骑截图保存失败")
		print("MOUNT_RUNTIME_VISUAL:%s" % output_path)
	runtime.call("toggle_riding")
	await process_frame
	await physics_frame
	_check(hero.action.visible, "解除坐骑后人物模型没有恢复")
	_check(hero.tx.position.is_equal_approx(original_title_position), "解除坐骑后称号位置没有恢复")
	_check( not bool(player_data_node.player_data.get(player_data_node.MOUNT_RIDING_KEY, false)), "解除坐骑后骑乘状态仍然存在")
	if controls != null:
		var restored_keys_value: Variant = controls.get("keyList")
		if restored_keys_value is Array:
			for slot in range(mini(5, restored_keys_value.size())):
				_check(int(restored_keys_value[slot].get("mount_skill_slot")) == -1, "解除坐骑后第 %d 个人物技能槽没有恢复" % (slot + 1))
	if role_hud != null:
		role_hud.call("_set_skill_pic")
		await physics_frame
		var desktop_keys: = ["Y", "U", "I", "O", "L"]
		var learned_skills: Variant = player_data_node.player_data.get("技能学习", {})
		var normal_bindings: Variant = learned_skills.get("技能键位", {}) if learned_skills is Dictionary else {}
		for slot in range(5):
			var normal_skill_name: = str(normal_bindings.get(desktop_keys[slot], "")) if normal_bindings is Dictionary else ""
			var icon = role_hud.get_node_or_null("role_menu/skil_%d/%s" % [slot + 1, desktop_keys[slot]])
			if normal_skill_name == "" or normal_skill_name == "Empty":
				_check(icon == null, "解除坐骑后桌面第 %d 个空技能槽仍残留坐骑图标" % (slot + 1))
			else:
				_check(icon != null, "解除坐骑后桌面第 %d 个人物技能图标未恢复" % (slot + 1))
				if icon != null:
					_check(int(icon.get("mount_skill_slot")) == -1, "解除坐骑后桌面第 %d 个技能槽仍标记为坐骑技能" % (slot + 1))
					_check(str(icon.get("SkillName")) == normal_skill_name, "解除坐骑后桌面第 %d 个人物技能 ID 未恢复" % (slot + 1))
	player_data_node.call("set_active_mount", "")
	await physics_frame
	if controls != null:
		var no_mount_keys_value: Variant = controls.get("keyList")
		if no_mount_keys_value is Array and no_mount_keys_value.size() > 10:
			_check( not no_mount_keys_value[10].visible, "没有出战坐骑时手机 Z 按钮仍然显示")
	player_data_node.player_data = original
	_finish(0 if failures.is_empty() else 1)

func _collision_bottom_y_in_hero(hero: Node2D, collision: CollisionShape2D) -> float:
	var half_extents: = Vector2.ZERO
	if collision.shape is CapsuleShape2D:
		var capsule: = collision.shape as CapsuleShape2D
		half_extents = Vector2(capsule.radius, capsule.height * 0.5)
	elif collision.shape is RectangleShape2D:
		half_extents = (collision.shape as RectangleShape2D).size * 0.5
	elif collision.shape is CircleShape2D:
		var radius: = (collision.shape as CircleShape2D).radius
		half_extents = Vector2(radius, radius)
	var collision_in_hero: = hero.global_transform.affine_inverse() * collision.global_transform
	return (
		collision_in_hero.origin.y
		+ absf(collision_in_hero.x.y) * half_extents.x
		+ absf(collision_in_hero.y.y) * half_extents.y
	)

func _finish(code: int) -> void :
	if failures.is_empty():
		print("MOUNT_RUNTIME_PROBE_OK")
	else:
		for failure in failures:
			push_error("MOUNT_RUNTIME_PROBE_FAIL: %s" % failure)
	quit(code)

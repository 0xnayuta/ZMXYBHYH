extends Node2D
const DataKeys := preload("res://Script/Base/DataKeys.gd")

const MOUSE_SCENE := "res://Scene/Pet/PetMouseSummon_%d.tscn"
const MOUSE_BULLET_SCENE := preload("res://Scene/Pet/PetMouseBullet.tscn")
const MOUSE_MODEL := "res://Art/Pet/PetMouse/model/pet_mouse_stage%d_frames.tres"
const EXPECTED_AOYI_ACTIONS := ["hit2", "hit3", "hit3", "hit2", "hit3", "hit3", "hit3"]


class MouseDamageProbe:
	extends BaseMonster

	var damage_calls := 0
	var damage_values: Array[int] = []

	func resolve_friendly_damage(base_damage: int, _attack_kind: String, _attacker: Node = null) -> int:
		return base_damage

	func reduce_pet_hp(value: int, _attack_kind: String) -> int:
		damage_calls += 1
		damage_values.append(value)
		Hp -= value
		return value

	func play_hit_effect(_attacker = null):
		pass


var failures: Array[String] = []
var visual_pets: Array[Node] = []


func _ready() -> void:
	var original_player_data: Dictionary = PlayerData.player_data
	PlayerData.player_data = original_player_data.duplicate(true)
	_verify_save_migration()
	_verify_pet_interface_fight()
	_verify_runtime_resources()
	_verify_hud_mapping()
	_verify_combat_level_up()
	await _verify_boomerang_damage()
	_verify_visual_stages_and_skills()
	PlayerData.player_data = original_player_data
	queue_redraw()
	await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		var screenshot_path := OS.get_temp_dir().path_join("pet_mouse_verification.png")
		var screenshot := get_viewport().get_texture().get_image()
		_check(screenshot != null and screenshot.save_png(screenshot_path) == OK, "子鼠验证截图应可生成")
		print("PET_MOUSE_SCREENSHOT=" + screenshot_path)
	_cleanup_verification_resources()
	if failures.is_empty():
		print("PET_MOUSE_VERIFICATION_PASSED")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	print("PET_MOUSE_VERIFICATION_FAILED=%d" % failures.size())
	get_tree().quit(1)


func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color("18222b"))
	draw_line(Vector2(0, 400), Vector2(viewport_size.x, 400), Color("d4d8dc"), 2.0)
	for center_x in [300.0, 760.0]:
		draw_rect(Rect2(Vector2(center_x - 17.5, 330), Vector2(35, 70)), Color(0.2, 0.8, 0.95, 0.18), true)
		draw_rect(Rect2(Vector2(center_x - 17.5, 330), Vector2(35, 70)), Color(0.2, 0.8, 0.95, 0.8), false, 1.0)
		draw_line(Vector2(center_x - 80, 365), Vector2(center_x + 80, 365), Color("ff6b6b"), 1.0)


func _verify_save_migration() -> void:
	var old_mouse := _mouse_data(49)
	old_mouse["阶段"] = 4
	old_mouse[DataKeys.ALT_NAME] = "子鼠大元帅"
	old_mouse[DataKeys.NAME] = "子鼠大元帅"
	old_mouse["技能"] = ["鼠窜", "回旋飞镖", "子鼠奥义"]
	old_mouse.erase("装备")
	PlayerData.player_data[PlayerData.PET_LIST_KEY] = [old_mouse]
	PlayerData.player_data[PlayerData.ACTIVE_PET_KEY] = "PetMouse"
	PlayerData.ensure_pet_mouse()
	_check(int(old_mouse.get("阶段", 0)) == 1, "49级旧档子鼠必须归一化为第一形态")
	_check(str(old_mouse.get(DataKeys.ALT_NAME, "")) == "子鼠元帅", "49级旧档子鼠名称必须恢复为子鼠元帅")
	_check(old_mouse.get("技能", []) == ["鼠窜", "回旋飞镖"], "49级第一形态必须保留30级领悟的回旋飞镖")
	_check(old_mouse.get("装备", {}) is Dictionary, "旧档子鼠必须补齐宠物装备字段")
	old_mouse[DataKeys.LEVEL] = 29
	PlayerData.ensure_pet_mouse()
	_check(int(old_mouse.get("阶段", 0)) == 1, "29级子鼠必须保持第一形态")
	_check(old_mouse.get("技能", []) == ["鼠窜"], "29级子鼠不能提前领悟回旋飞镖")
	old_mouse[DataKeys.LEVEL] = 30
	PlayerData.ensure_pet_mouse()
	_check(int(old_mouse.get("阶段", 0)) == 1, "30级子鼠领悟技能时不能提前进化")
	_check(old_mouse.get("技能", []) == ["鼠窜", "回旋飞镖"], "30级子鼠必须领悟回旋飞镖")
	old_mouse[DataKeys.LEVEL] = 50
	PlayerData.ensure_pet_mouse()
	_check(int(old_mouse.get("阶段", 0)) == 2, "50级旧档子鼠必须归一化为第二形态")
	_check(old_mouse.get("技能", []) == ["鼠窜", "回旋飞镖", "子鼠奥义"], "50级子鼠必须领悟子鼠奥义")


func _verify_pet_interface_fight() -> void:
	var mouse := _mouse_data(30)
	PlayerData.player_data[DataKeys.PLAYER_LEVEL] = 30
	PlayerData.player_data[PlayerData.PET_LIST_KEY] = [mouse]
	PlayerData.player_data[PlayerData.ACTIVE_PET_KEY] = ""
	var packed := load("res://Scene/Pet/PetInterface.tscn") as PackedScene
	_check(packed != null, "宠物界面场景必须可加载")
	if packed == null:
		return
	var pet_interface := packed.instantiate()
	pet_interface.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(pet_interface)
	var pets: Array = PlayerData.player_data.get(PlayerData.PET_LIST_KEY, [])
	var mouse_index := -1
	for index in pets.size():
		var pet_value: Variant = pets[index]
		if pet_value is Dictionary and str(pet_value.get(DataKeys.TYPE, "")) == "PetMouse":
			mouse_index = index
			break
	_check(mouse_index >= 0, "宠物界面必须列出子鼠")
	if mouse_index >= 0:
		pet_interface.set("current_pet_index", mouse_index)
		pet_interface.call("fightClick")
		var selected: Dictionary = pets[mouse_index]
		_check(bool(selected.get(DataKeys.DEPLOYED, false)), "子鼠点击出战后必须进入出战状态")
		_check(str(PlayerData.player_data.get(PlayerData.ACTIVE_PET_KEY, "")) == "PetMouse", "子鼠出战键必须写入PetMouse")
		_check(int(selected.get("阶段", 0)) == 1, "宠物页30级子鼠必须保持第一形态")
		_check(selected.get("技能", []) == ["鼠窜", "回旋飞镖"], "宠物页30级子鼠必须显示已领悟的回旋飞镖")
	pet_interface.free()


func _verify_runtime_resources() -> void:
	for stage in [1, 2]:
		_check(load(MOUSE_SCENE % stage) is PackedScene, "子鼠第%d形态场景必须存在" % stage)
		var frames := load(MOUSE_MODEL % stage) as SpriteFrames
		_check(frames != null, "子鼠第%d形态模型资源必须存在" % stage)
		if frames == null:
			continue
		var expected_counts := {"wait": 6, "walk": 4, "hurt": 1, "death": 5, "hit1": 3, "hit2": 4}
		if stage == 2:
			expected_counts["hit3"] = 3
		for action_name in expected_counts:
			_check(frames.has_animation(action_name), "子鼠第%d形态缺少%s动作" % [stage, action_name])
			if not frames.has_animation(action_name):
				continue
			_check(
				frames.get_frame_count(action_name) == int(expected_counts[action_name]),
				"子鼠第%d形态%s帧数不符" % [stage, action_name]
			)
			_check(is_equal_approx(frames.get_animation_speed(action_name), 24.0), "子鼠%s动作必须保持24 FPS" % action_name)
			for frame_index in frames.get_frame_count(action_name):
				var texture := frames.get_frame_texture(action_name, frame_index)
				_check(texture != null and texture.get_size() == Vector2(200, 200), "子鼠模型帧必须保持200x200固定画布")
		if stage == 1:
			_check(not frames.has_animation("hit3"), "第一形态源模型必须保持没有独立hit3动作")
	var effect_counts := {
		"PetMouse1Bullet1": 20,
		"PetMouse1Bullet2": 25,
		"PetMouse1Bullet2Layer": 25,
		"PetMouse1Bullet3": 12,
		"AoyiBuff": 14
	}
	for effect_name in effect_counts:
		var effect_frames := PetMouseBullet._get_frames(effect_name)
		_check(
			effect_frames.get_frame_count(effect_name) == int(effect_counts[effect_name]), "%s特效帧数必须与原版一致" % effect_name
		)
	var normal_frames := PetMouseBullet._get_frames("PetMouse1Bullet1")
	var blank_tail := normal_frames.get_frame_texture("PetMouse1Bullet1", 15).get_image().get_used_rect()
	_check(blank_tail.size == Vector2i.ZERO, "普攻特效原版第16帧起的空白尾帧必须保留")
	var dash_layer_frames := PetMouseBullet._get_frames("PetMouse1Bullet2Layer")
	_check(
		PetMouseBullet.EFFECT_REGISTRATION["PetMouse1Bullet2"] == Vector2(95.65, 76.2),
		"Dash registration must use the outer Symbol 63 origin"
	)
	for frame_index in range(10):
		var dash_layer_image := dash_layer_frames.get_frame_texture("PetMouse1Bullet2Layer", frame_index).get_image()
		var dash_layer_rect := dash_layer_image.get_used_rect()
		_check(
			dash_layer_image.get_size() == Vector2i(108, 101), "Dash layer frames must keep the padded source canvas"
		)
		_check(
			(
				dash_layer_rect.position.x > 0
				and dash_layer_rect.position.y > 0
				and dash_layer_rect.end.x < 108
				and dash_layer_rect.end.y < 101
			),
			"Dash layer alpha must not touch a texture edge"
		)
	PlayerData.player_data[PlayerData.PET_LIST_KEY] = [_mouse_data(30)]
	PlayerData.player_data[PlayerData.ACTIVE_PET_KEY] = "PetMouse"
	PlayerData.player_data[PlayerData.PET_LIST_KEY][0][DataKeys.DEPLOYED] = true
	var preload_paths := Global.get_active_pet_preload_paths()
	_check(MOUSE_SCENE % 1 in preload_paths and MOUSE_MODEL % 1 in preload_paths, "30级子鼠预热必须仍使用第一形态资源")
	_check("res://Art/Pet/skillicon/hxfb.png" in preload_paths, "30级子鼠预热必须包含回旋飞镖图标")
	_check("res://Art/Pet/skillicon/aoyi.png" not in preload_paths, "30级子鼠不能提前预热奥义图标")
	PlayerData.player_data[PlayerData.PET_LIST_KEY] = [_mouse_data(50)]
	PlayerData.player_data[PlayerData.PET_LIST_KEY][0][DataKeys.DEPLOYED] = true
	preload_paths = Global.get_active_pet_preload_paths()
	for required_path in [
		MOUSE_SCENE % 2,
		MOUSE_MODEL % 2,
		"res://Scene/Pet/PetMouseBullet.tscn",
		"res://Art/Pet/skillicon/sc.png",
		"res://Art/Pet/skillicon/hxfb.png",
		"res://Art/Pet/skillicon/aoyi.png",
	]:
		_check(required_path in preload_paths, "子鼠预热路径缺少%s" % required_path)


func _verify_hud_mapping() -> void:
	var hud := BaseRole.new()
	var level_29 := _mouse_data(29)
	var level_29_icons: Array[String] = hud._pet_skill_icon_names_for_pet(level_29, null, 1)
	_check(level_29_icons == ["sc"], "29级HUD只能显示鼠窜")
	var level_30 := _mouse_data(30)
	var level_30_icons: Array[String] = hud._pet_skill_icon_names_for_pet(level_30, null, 1)
	_check(level_30_icons == ["sc", "hxfb"], "30级第一形态HUD必须显示回旋飞镖")
	var stage_two := _mouse_data(50)
	var icons: Array[String] = hud._pet_skill_icon_names_for_pet(stage_two, null, 2)
	_check(icons == ["sc", "hxfb", "zsaoyi"], "50级HUD必须刷新三个子鼠技能图标")
	_check(str(hud.call("_pet_skill_cooldown_key", "sc")) == "Skill_1_CD", "鼠窜必须使用第一冷却槽")
	_check(str(hud.call("_pet_skill_cooldown_key", "hxfb")) == "Skill_2_CD", "回旋飞镖必须使用第二冷却槽")
	_check(str(hud.call("_pet_skill_cooldown_key", "zsaoyi")) == "Skill_3_CD", "子鼠奥义必须使用第三冷却槽")
	_check(
		hud.call("_pet_mouse_head_texture", 1) != null and hud.call("_pet_mouse_head_texture", 2) != null,
		"两个形态HUD头像必须可加载"
	)
	hud.free()
	var level := BaseLevel.new()
	_check(int(level.call("_pet_mouse_stage_for_level", 49)) == 1, "关卡生成49级子鼠必须使用第一形态")
	_check(int(level.call("_pet_mouse_stage_for_level", 50)) == 2, "关卡生成50级子鼠必须使用第二形态")
	_check(level.call("_pet_mouse_skills_for_level", 29) == ["鼠窜"], "关卡生成29级子鼠不能提前获得飞镖")
	_check(level.call("_pet_mouse_skills_for_level", 30) == ["鼠窜", "回旋飞镖"], "关卡生成30级子鼠必须获得飞镖")
	_check(level.call("_pet_mouse_skills_for_level", 50) == ["鼠窜", "回旋飞镖", "子鼠奥义"], "关卡生成50级子鼠必须获得奥义")
	_check(str(level.call("_pet_mouse_scene_path", 2)) == MOUSE_SCENE % 2, "关卡必须选择第二形态子鼠场景")
	level.free()


func _verify_combat_level_up() -> void:
	var source_scene := load("res://Scene/Monster/Monster_1.tscn") as PackedScene
	_check(source_scene != null, "经验验证怪物场景必须可加载")
	if source_scene == null:
		return
	var level_30_mouse := _mouse_data(29)
	level_30_mouse[DataKeys.DEPLOYED] = true
	level_30_mouse[DataKeys.EXP] = 0
	PlayerData.player_data[DataKeys.PLAYER_LEVEL] = 30
	PlayerData.player_data[PlayerData.PET_LIST_KEY] = [level_30_mouse]
	PlayerData.player_data[PlayerData.ACTIVE_PET_KEY] = "PetMouse"
	var first_form := _instantiate_mouse(1, level_30_mouse, Vector2(-1000, 400))
	if first_form == null:
		return
	var level_30_source := source_scene.instantiate()
	level_30_source.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(level_30_source)
	level_30_source.call("_cure_active_pet_exp", 1000000)
	_check(int(level_30_mouse.get(DataKeys.LEVEL, 0)) == 30, "战斗经验必须让29级子鼠升到30级")
	_check(int(level_30_mouse.get("阶段", 0)) == 1 and int(first_form.get("turtle_stage")) == 1, "30级领悟飞镖时必须保持第一形态")
	var first_form_sprite := first_form.get_node("MonsterDir/mr_ani") as AnimatedSprite2D
	_check(first_form_sprite.sprite_frames.resource_path == MOUSE_MODEL % 1, "30级领悟飞镖时不能替换第二形态模型")
	_check((first_form.get("pet_data") as Dictionary).get("技能", []) == ["鼠窜", "回旋飞镖"], "战斗升到30级必须即时刷新回旋飞镖")
	_check(is_zero_approx(float(first_form.get("Skill_2_CD"))), "战斗中新领悟的回旋飞镖必须立即可用")
	level_30_source.free()
	first_form.free()

	var active_mouse := _mouse_data(49)
	active_mouse[DataKeys.DEPLOYED] = true
	active_mouse[DataKeys.EXP] = 0
	PlayerData.player_data[DataKeys.PLAYER_LEVEL] = 50
	PlayerData.player_data[PlayerData.PET_LIST_KEY] = [active_mouse]
	PlayerData.player_data[PlayerData.ACTIVE_PET_KEY] = "PetMouse"
	var mouse := _instantiate_mouse(1, active_mouse, Vector2(-1000, 400))
	if mouse == null:
		return
	var source := source_scene.instantiate()
	source.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(source)
	source.call("_cure_active_pet_exp", 1000000)
	_check(int(active_mouse.get(DataKeys.LEVEL, 0)) == 50, "战斗经验必须让49级子鼠升到50级")
	_check(int(active_mouse.get("阶段", 0)) == 2, "战斗升级必须写入第二形态阶段")
	_check(int(mouse.get("turtle_stage")) == 2, "战斗升级必须即时刷新现有子鼠实例阶段")
	var sprite := mouse.get_node("MonsterDir/mr_ani") as AnimatedSprite2D
	_check(sprite.sprite_frames.resource_path == MOUSE_MODEL % 2, "战斗升级必须即时替换第二形态模型")
	_check(sprite.sprite_frames.has_animation("hit3"), "战斗升级后必须即时获得回旋飞镖动作")
	_check((mouse.get("pet_data") as Dictionary).get("技能", []) == ["鼠窜", "回旋飞镖", "子鼠奥义"], "战斗升级后技能必须即时刷新")
	source.free()
	mouse.free()


func _verify_boomerang_damage() -> void:
	var data := _mouse_data(50)
	data[DataKeys.ATTACK] = 100
	data["根骨"] = 25
	data["法术能量"] = 20
	var mouse := _instantiate_mouse(2, data, Vector2(-1000, 400))
	if mouse == null:
		return
	var attacks: Dictionary = mouse.get("objattackDic")
	var attack_data: Dictionary = (attacks["hit3"] as Dictionary).duplicate(true)
	_check(int(attack_data.get("power", 0)) == 1530, "回旋飞镖每段伤害必须使用(10A+M)*根骨倍率")
	_check(int(attack_data.get("damageHitCount", 0)) == 2, "回旋飞镖每次命中必须造成两段伤害")
	attack_data["hurtBack"] = []
	var bullet := MOUSE_BULLET_SCENE.instantiate()
	bullet.process_mode = Node.PROCESS_MODE_DISABLED
	bullet.set("AttList", attack_data)
	bullet.set("skill_name", "PetMouse1Bullet3")
	bullet.set_meta("summoner", mouse)
	add_child(bullet)
	mouse.set("Hp", 100)
	mouse.set("SHp", 1000)
	var target := MouseDamageProbe.new()
	target.Hp = 100000
	var damaged := bool(bullet.call("_damage_target", target))
	_check(damaged, "回旋飞镖命中必须返回成功伤害状态")
	_check(target.damage_calls == 1, "回旋飞镖第二段伤害不能与第一段同帧结算")
	_check(int(mouse.get("Hp")) == 100, "回旋飞镖必须等第二段结算后再按总伤害回血")
	await get_tree().create_timer(PetMouseBullet.BOOMERANG_DAMAGE_INTERVAL + 0.05, false).timeout
	_check(target.damage_calls == 2, "回旋飞镖一次命中必须执行两次扣血")
	_check(target.damage_values == [1530, 1530], "回旋飞镖两段伤害必须各自使用完整单段伤害")
	_check(is_equal_approx(PetMouseBullet.BOOMERANG_DAMAGE_INTERVAL, 2.0 / 24.0), "回旋飞镖第二段必须在4 tick命中周期的中点结算")
	_check(int(mouse.get("Hp")) == 253, "回旋飞镖必须按两段实际总伤害的5%给子鼠回血")

	var low_damage_data := attack_data.duplicate(true)
	low_damage_data["power"] = 15
	bullet.set("AttList", low_damage_data)
	mouse.set("Hp", 100)
	target.Hp = 1000
	bullet.call("_damage_target", target)
	await get_tree().create_timer(PetMouseBullet.BOOMERANG_DAMAGE_INTERVAL + 0.05, false).timeout
	_check(int(mouse.get("Hp")) == 101, "回旋飞镖必须先合并两段实际伤害再计算5%回血")

	var lethal_damage_data := attack_data.duplicate(true)
	lethal_damage_data["power"] = 100
	bullet.set("AttList", lethal_damage_data)
	mouse.set("Hp", 100)
	target.Hp = 20
	bullet.call("_damage_target", target)
	await get_tree().create_timer(PetMouseBullet.BOOMERANG_DAMAGE_INTERVAL + 0.05, false).timeout
	_check(int(mouse.get("Hp")) == 101, "回旋飞镖致死时只能按目标剩余生命计算回血")
	bullet.free()
	target.free()
	mouse.free()


func _verify_visual_stages_and_skills() -> void:
	var stage_one := _instantiate_mouse(1, _mouse_data(30), Vector2(300, 400))
	var stage_two := _instantiate_mouse(2, _mouse_data(50), Vector2(760, 400))
	if stage_one == null or stage_two == null:
		return
	visual_pets.assign([stage_one, stage_two])
	stage_one.call("_face_left")
	stage_two.call("_face_right")
	_verify_stage_layout(stage_one, 1, 6.0)
	_verify_stage_layout(stage_two, 2, 3.0)
	var stage_one_attacks: Dictionary = stage_one.get("objattackDic")
	var stage_two_attacks: Dictionary = stage_two.get("objattackDic")
	_check(str(stage_one_attacks["hit1"].get("attackKind", "")) == "magic", "子鼠普攻必须是魔法伤害")
	_check(str(stage_two_attacks["hit2"].get("attackKind", "")) == "physics", "鼠窜必须是物理伤害")
	_check(str(stage_two_attacks["hit3"].get("attackKind", "")) == "physics", "回旋飞镖必须是物理伤害")
	_check(int(stage_two.call("_skill_cost", "sc")) == 50, "鼠窜蓝耗必须为50")
	_check(int(stage_two.call("_skill_cost", "hxfb")) == 70, "回旋飞镖蓝耗必须为70")
	_check(int(stage_two.call("_skill_cost", "zsaoyi")) == 100, "子鼠奥义蓝耗必须为100")
	stage_one.call("_spawn_normal_attack")
	var stage_one_bullets := stage_one.get_node("Bullet").get_children()
	_check(stage_one_bullets.size() == 1, "子鼠普攻必须生成原版普攻特效")
	if not stage_one_bullets.is_empty():
		var normal_bullet := stage_one_bullets[0] as Node2D
		_check(str(normal_bullet.get("skill_name")) == "PetMouse1Bullet1", "子鼠普攻特效名称必须正确")
		_check(
			normal_bullet.global_position == (stage_one as Node2D).global_position + Vector2(-20, -25),
			"面左普攻必须使用原版x-20/y+10高度"
		)
	stage_one.set("Mp", 180)
	stage_one.call("do_mouse_boomerang")
	var stage_one_sprite := stage_one.get_node("MonsterDir/mr_ani") as AnimatedSprite2D
	_check(str(stage_one.get("_turtle_action")) == "hit3", "30级第一形态回旋飞镖必须进入逻辑hit3动作")
	_check(str(stage_one_sprite.animation) == "hit1", "第一形态回旋飞镖必须复用自身三帧攻击动作")
	stage_one.set("_turtle_action_tick", 5)
	stage_one.call("_process_turtle_action_triggers")
	stage_one_bullets = stage_one.get_node("Bullet").get_children()
	_check(stage_one_bullets.size() == 4, "30级第一形态必须在第5 tick生成三枚回旋飞镖")
	stage_one.call("_finish_turtle_action")
	stage_two.call("_spawn_dash_attack")
	stage_two.call("_spawn_boomerangs")
	var stage_two_bullets := stage_two.get_node("Bullet").get_children()
	_check(stage_two_bullets.size() == 4, "鼠窜加回旋飞镖必须生成1+3个特效")
	if stage_two_bullets.size() == 4:
		var dash := stage_two_bullets[0] as Node2D
		_check(
			dash.global_position == (stage_two as Node2D).global_position + Vector2(40, -25), "面右鼠窜必须使用原版x+40/y+10高度"
		)
		_check(
			dash.z_index > (stage_two as Node2D).z_index,
			"Dash effect must render above the pet like the original game-scene child"
		)
		_check(
			not (dash.get_node("middle/BulletANI") as AnimatedSprite2D).visible,
			"Flattened dash frames must only drive timing and hit bounds"
		)
		for layer_index in range(1, 4):
			_check(
				dash.has_node("middle/DashLayer%d" % layer_index),
				"Dash effect must preserve all three original Symbol 62 layers"
			)
		var expected_velocities := [Vector2(35, 0), Vector2(35, -4), Vector2(35, -8)]
		for index in range(3):
			var boomerang := stage_two_bullets[index + 1] as Node2D
			_check(
				(boomerang.get("_outbound_velocity") as Vector2) == expected_velocities[index], "回旋飞镖必须在_ready前获得原版初速度"
			)
			for _tick in range(6):
				boomerang.call("_process_effect_tick")
	var logic_pet := _instantiate_mouse(2, _mouse_data(50), Vector2(-1000, 400))
	if logic_pet == null:
		return
	logic_pet.set("Hp", 100)
	logic_pet.set("SHp", 200)
	logic_pet.call("on_mouse_dash_hit", 30)
	_check(int(logic_pet.get("Hp")) == 130, "鼠窜命中必须按原始技能伤害回复生命")
	logic_pet.set("Mp", 100)
	logic_pet.call("do_mouse_aoyi")
	var actions: Array[String] = []
	for _index in EXPECTED_AOYI_ACTIONS.size():
		actions.append(str(logic_pet.get("_turtle_action")))
		logic_pet.call("_finish_turtle_action")
	_check(actions == EXPECTED_AOYI_ACTIONS, "子鼠奥义必须按鼠窜、两轮飞镖、鼠窜、三轮飞镖连段")
	_check(int(logic_pet.get("_mouse_aoyi_step")) == 0, "子鼠奥义完整连段后必须退出奥义状态")
	logic_pet.free()


func _verify_stage_layout(pet: Node, stage: int, expected_visible_bottom: float) -> void:
	var sprite := pet.get_node("MonsterDir/mr_ani") as AnimatedSprite2D
	var ground := pet.get_node("pz") as CollisionShape2D
	_check(sprite.position == Vector2(0, -35), "子鼠第%d形态必须共用地面上35px逻辑原点" % stage)
	_check(sprite.offset == Vector2(20, -25), "子鼠第%d形态必须保留原版(-20,-25)注册偏移" % stage)
	_check(
		ground.shape is RectangleShape2D and (ground.shape as RectangleShape2D).size == Vector2(35, 70),
		"子鼠必须使用原版35x70碰撞体"
	)
	_check(is_equal_approx(ground.position.y + 35.0, 0.0), "子鼠碰撞体底边必须落在地面根节点")
	var texture := sprite.sprite_frames.get_frame_texture("wait", 0)
	var used_rect := texture.get_image().get_used_rect()
	var visible_bottom := sprite.position.y + sprite.offset.y - texture.get_height() * 0.5 + used_rect.end.y
	_check(is_equal_approx(visible_bottom, expected_visible_bottom), "子鼠第%d形态可见脚底高度必须保留原版差异" % stage)


func _instantiate_mouse(stage: int, data: Dictionary, at_position: Vector2) -> Node:
	var packed := load(MOUSE_SCENE % clampi(stage, 1, 2)) as PackedScene
	_check(packed != null, "无法实例化子鼠第%d形态" % stage)
	if packed == null:
		return null
	var pet := packed.instantiate()
	pet.process_mode = Node.PROCESS_MODE_DISABLED
	pet.set("pet_data", data)
	pet.set("position", at_position)
	add_child(pet)
	return pet


func _mouse_data(level: int) -> Dictionary:
	var data: Dictionary = PlayerData.PET_MOUSE_PET.duplicate(true)
	var stage := 2 if level >= 50 else 1
	data[DataKeys.LEVEL] = level
	data["阶段"] = stage
	data[DataKeys.ALT_NAME] = "子鼠大元帅" if stage == 2 else "子鼠元帅"
	data[DataKeys.NAME] = data[DataKeys.ALT_NAME]
	data["技能"] = ["鼠窜", "回旋飞镖", "子鼠奥义"] if level >= 50 else ["鼠窜", "回旋飞镖"] if level >= 30 else ["鼠窜"]
	data[DataKeys.HP] = int(data.get("生命上限", 620))
	data[DataKeys.MP] = int(data.get("魔法上限", 180))
	return data


func _cleanup_verification_resources() -> void:
	for pet in visual_pets:
		if is_instance_valid(pet):
			pet.free()
	visual_pets.clear()
	PetMouseBullet.clear_cached_frames()
	PetMouseSummonBase.clear_cached_mouse_scenes()


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

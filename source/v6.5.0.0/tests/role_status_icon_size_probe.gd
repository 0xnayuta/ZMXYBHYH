extends SceneTree

const EXPECTED_SIZE: = Vector2(32, 32)


func _init() -> void :
	call_deferred("_run")


func _run() -> void :
	var role_script: = load("res://Script/Base/BaseRole.gd")
	var buff_script: = load("res://Script/Base/BaseBuff.gd")
	if role_script == null or buff_script == null:
		push_error("人物状态栏或Buff脚本无法加载")
		quit(1)
		return
	var preview: = ColorRect.new()
	preview.color = Color(0.12, 0.12, 0.12, 1.0)
	preview.size = Vector2(160, 64)
	root.add_child(preview)
	var buff_box: = HBoxContainer.new()
	buff_box.position = Vector2(16, 16)
	preview.add_child(buff_box)
	var pet_skill_box: = HBoxContainer.new()
	pet_skill_box.position = Vector2(64, 16)
	preview.add_child(pet_skill_box)

	var role_ui: = role_script.new() as Control
	role_ui.set("buff_box", buff_box)
	role_ui.set("pet_skill_box", pet_skill_box)
	var global_node: = root.get_node_or_null("Global")
	if global_node == null:
		push_error("Global单例没有加载")
		quit(1)
		return
	var buff_icon: = global_node.call("AddBuffIcon", buff_box, {"Name": "PetLifeBonus", "value": 1, "AddTime": 30.0, "ReduceInterval": 1.0, "AttackKind": "", "CanAdd": false}) as TextureRect
	if buff_icon == null:
		push_error("全局路径没有创建状态图标")
		quit(1)
		return
	var adopted_icon: = role_ui.call("_ensure_buff_icon", "PetLifeBonus") as TextureRect
	var pet_skill_icon: = role_ui.call("_ensure_pet_skill_icon", 0) as TextureRect
	if adopted_icon != buff_icon or buff_box.get_child_count() != 1:
		push_error("HUD没有唯一接管已有状态图标")
		quit(1)
		return
	if pet_skill_icon == null:
		push_error("宠物技能状态图标没有创建")
		quit(1)
		return
	buff_icon.texture = load("res://Art/Pet/skillicon/smjc.png") as Texture2D
	if buff_icon.custom_minimum_size != EXPECTED_SIZE or buff_icon.get_combined_minimum_size() != EXPECTED_SIZE or buff_icon.size != EXPECTED_SIZE or buff_icon.scale != Vector2.ONE:
		push_error("人物状态图标不是32×32")
		quit(1)
		return
	if pet_skill_icon.size != EXPECTED_SIZE or buff_icon.size != pet_skill_icon.size:
		push_error("人物状态图标与宠物技能图标大小不一致")
		quit(1)
		return

	var learned_skills: = ["生命加成", "攻击加成", "防御加成", "魔法庇佑", "嗜血狂爆", "法术能量", "天生蛮力", "自然守护", "生命祝福", "魔法加成"]
	var visible_skills: Array = role_ui.call("_pet_visible_skill_icon_names", {"类型": "PetRabbit", "阶段": 4, "已学习技能": learned_skills}, null, 4)
	for hidden_skill_id in ["yg", "smjc", "gjjc", "fyjc", "mfby", "tsml", "zrsh", "smzf", "mfjc"]:
		if visible_skills.has(hidden_skill_id):
			push_error("宠物常驻技能仍显示在宠物状态栏：%s" % hidden_skill_id)
			quit(1)
			return
	for active_skill_id in ["jf", "bs", "ysaoyi", "sxkb", "fsnl"]:
		if not visible_skills.has(active_skill_id):
			push_error("宠物主动技能没有显示在宠物状态栏：%s" % active_skill_id)
			quit(1)
			return

	var pet_unit: = Node.new()
	preview.add_child(pet_unit)
	var learned_runtime_script: = load("res://Script/Pet/PetLifeBonusRuntime.gd")
	var learned_runtime: Node = learned_runtime_script.new()
	learned_runtime.name = "PetLearnedSkillRuntime"
	learned_runtime.call("setup", {"已学习技能": ["嗜血狂爆"], "技能等级": {"嗜血狂爆": 1}, "灵力": 10})
	pet_unit.add_child(learned_runtime)
	await process_frame
	await process_frame
	var learned_icon: = role_ui.call("_ensure_pet_skill_icon", 1) as TextureRect
	learned_icon.texture = load("res://Art/Pet/skillicon/sxkb.png") as Texture2D
	role_ui.call("_set_pet_skill_cooldown", learned_icon, "sxkb", pet_unit)
	var cooldown_mask: = learned_icon.get_node_or_null("PicBox") as TextureProgressBar
	var cooldown_text: = learned_icon.get_node_or_null("TimeText") as Label
	var learned_cooldown_left: = float(role_ui.call("_pet_skill_cooldown_left", "sxkb", pet_unit))
	var learned_cooldown_max: = float(role_ui.call("_pet_skill_cooldown_max", "sxkb", pet_unit))
	if learned_cooldown_left <= 0.0 or learned_cooldown_left > 24.0 or learned_cooldown_max != 24.0 or cooldown_mask == null or not cooldown_mask.visible or cooldown_text == null or not cooldown_text.visible:
		push_error("已学习主动技能没有显示灵力加成后的冷却")
		quit(1)
		return

	buff_icon.free()
	var rebuilt_icon: = role_ui.call("_ensure_buff_icon", "PetLifeBonus") as TextureRect
	if rebuilt_icon == null or not is_instance_valid(rebuilt_icon) or rebuilt_icon.size != EXPECTED_SIZE or rebuilt_icon.scale != Vector2.ONE:
		push_error("已释放的人物状态图标没有按32×32重新创建")
		quit(1)
		return

	print("ROLE_STATUS_ICON_SIZE_PROBE_OK")
	role_ui.free()
	preview.free()
	quit(0)

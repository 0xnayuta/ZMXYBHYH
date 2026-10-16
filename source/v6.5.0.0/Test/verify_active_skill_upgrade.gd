extends Node

const ACTIVE_SKILL_SCENE_PATH := "res://Scene/Skill/zd_skill.tscn"
const ACTIVE_SKILL_PROBE_PATH := "res://Test/ActiveSkillUpgradeProbe.gd"
const ROLE1_SCRIPT_PATH := "res://Script/Hero/Role1.gd"
const BASE_MONSTER_SCENE_PATH := "res://Scene/Base/BaseMonster.tscn"

var failures: Array[String] = []
var original_player_data: Dictionary


func _ready() -> void:
	original_player_data = PlayerData.player_data
	PlayerData.player_data = original_player_data.duplicate(true)
	PlayerData.player_data["Myself"] = 1
	AE.ensure_loaded()

	var item_data: Dictionary = AE.AllEquipment_.get("1_jns", {})
	_check(item_data.get("名字", "") == "一阶技能书", "技能书名称应正确")
	_check(item_data.get("品质", "") == "神器", "技能书品质应为神器")
	_check(item_data.get("描述", "") == "技能11-20级升级材料", "技能书描述应正确")
	_check(ResourceLoader.exists("res://Art/BackPack/AllItems/1_jns.png"), "技能书图标应可加载")

	var probe_script: GDScript = load(ACTIVE_SKILL_PROBE_PATH)
	var probe = probe_script.new()
	_check(probe.MAX_SKILL_LEVEL == 20, "主动技能上限应为20级")
	_check(probe.get_skill_max_level("slz") == 20, "主动技能应使用20级上限")
	_check(probe.get_skill_max_level("sx") == 10, "被动技能应保持10级上限")
	_check(probe.get_skill_book_need(10) == 1, "10升11级应消耗1本技能书")
	_check(probe.get_skill_book_need(19) == 10, "19升20级应消耗10本技能书")

	var role1_script: GDScript = load(ROLE1_SCRIPT_PATH)
	var role1_probe = role1_script.new()
	_check(is_equal_approx(role1_probe.get_gsrs_defense_reduction(12), 1.0), "11级棍式如山减防应封顶100%")
	var base_monster_scene: PackedScene = load(BASE_MONSTER_SCENE_PATH)
	var monster_probe = base_monster_scene.instantiate()
	monster_probe.set("DefeReduce", 1.068)
	_check(is_equal_approx(float(monster_probe.call("get_effective_defense_reduction")), 1.0), "怪物承伤公式应将超额减防封顶100%")
	monster_probe.free()
	base_monster_scene = null
	role1_probe.free()
	role1_script = null

	_remove_skill_books()
	_set_skill_level(1, 10)
	PlayerData.player_data["coin_num"] = 12345
	PlayerData.add_dj("1_jns", 1)
	probe.TargetSkill = 1
	probe.UpLevel()
	_check(_get_skill_level(1) == 11, "技能应能从10级升到11级")
	_check(PlayerData.get_item_data("1_jns") == 0, "10升11级应扣除1本技能书")
	_check(PlayerData.player_data["coin_num"] == 12345, "11-20级升级不应扣除灵魂")

	_set_skill_level(1, 19)
	PlayerData.add_dj("1_jns", 10)
	probe.UpLevel()
	_check(_get_skill_level(1) == 20, "技能应能从19级升到20级")
	_check(PlayerData.get_item_data("1_jns") == 0, "19升20级应扣除10本技能书")

	PlayerData.add_dj("1_jns", 5)
	var books_before := int(PlayerData.get_item_data("1_jns"))
	_check(not probe._consume_skill_book(15), "材料不足时升级材料检查应失败")
	_check(PlayerData.get_item_data("1_jns") == books_before, "材料不足时不应部分扣除技能书")

	_set_skill_level(1, 9)
	PlayerData.player_data["coin_num"] = 10000
	probe.UpLevel()
	_check(_get_skill_level(1) == 10, "原有1-10级升级应保持可用")
	_check(PlayerData.player_data["coin_num"] == 5400, "9升10级应沿用4600灵魂消耗")
	_check(PlayerData.get_item_data("1_jns") == books_before, "1-10级升级不应消耗技能书")

	_set_skill_level(1, 10)
	_set_skill_level(probe.get_level_storage_index(10), 10)
	var active_skill_scene: PackedScene = load(ACTIVE_SKILL_SCENE_PATH)
	var active_skill_table = active_skill_scene.instantiate()
	add_child(active_skill_table)
	await get_tree().process_frame
	await get_tree().process_frame
	var active_need := active_skill_table.get_node("ScrollContainer/HBoxContainer/sk_lv/Skill_1/Need") as Label
	var passive_need := active_skill_table.get_node("ScrollContainer/HBoxContainer/sk_lv/Skill_11/Need") as Label
	var upgrade_title := active_skill_table.get_node("ScrollContainer/HBoxContainer/sk_lv/skill_uplevel") as Label
	var level_title := active_skill_table.get_node("ScrollContainer/HBoxContainer/sk_le/skill_level") as Label
	_check(active_need.text == "需：一阶技能书x1", "10级主动技能应按名称x数量显示消耗")
	_check(passive_need.text == "已满级", "10级被动技能应显示已满级")
	_check(is_equal_approx(upgrade_title.size.x, 148.0), "技能升级列应从128像素加宽到148像素")
	_check(is_equal_approx(level_title.size.x, 106.0), "技能等级列应从126像素减少到106像素")

	if DisplayServer.get_name() != "headless":
		var screenshot_path := OS.get_temp_dir().path_join("active_skill_upgrade_verification.png")
		var screenshot := get_viewport().get_texture().get_image()
		_check(screenshot != null and screenshot.save_png(screenshot_path) == OK, "主动技能页截图应可生成")
		print("ACTIVE_SKILL_UPGRADE_SCREENSHOT=" + screenshot_path)

	active_skill_table.free()
	probe.free()
	active_skill_scene = null
	probe_script = null
	PlayerData.player_data = original_player_data
	call_deferred("_finish")


func _set_skill_level(index: int, level: int) -> void:
	PlayerData.player_data["技能学习"]["技能" + str(index)]["等级"] = level


func _get_skill_level(index: int) -> int:
	return int(PlayerData.player_data["技能学习"]["技能" + str(index)]["等级"])


func _remove_skill_books() -> void:
	for page_key in PlayerData.player_data["道具列表"]:
		var page: Array = PlayerData.player_data["道具列表"][page_key]
		for index in range(page.size() - 1, -1, -1):
			if page[index].get("名字", "") == "1_jns":
				page.remove_at(index)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	await get_tree().process_frame
	if failures.is_empty():
		print("ACTIVE_SKILL_UPGRADE_VERIFICATION_PASSED")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	print("ACTIVE_SKILL_UPGRADE_VERIFICATION_FAILED=%d" % failures.size())
	get_tree().quit(1)

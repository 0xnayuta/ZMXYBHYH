extends Node

var _failures: Array[String] = []
var _checks: = 0

func _ready() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("INVENTORY_LATE_PAGE_FAIL: " + message)

func _run() -> void :
	var original_items: Dictionary = PlayerData.player_data["道具列表"]
	var original_consumables: Dictionary = PlayerData.player_data["消耗品列表"]
	PlayerData.player_data["道具列表"] = {}
	PlayerData.player_data["消耗品列表"] = {}
	for page in range(1, 21):
		PlayerData.player_data["道具列表"]["页码%d" % page] = []
		PlayerData.player_data["消耗品列表"]["页码%d" % page] = []
	for page in range(1, 21):
		var key: = "页码%d" % page
		PlayerData.player_data["道具列表"][key] = [{"名字": "qhs_1", "数量": 7, "Data": {}}]
		PlayerData.player_data["消耗品列表"][key] = [{"名字": "qhsbx", "数量": 9}]
		_check(PlayerData.get_item_data("qhs_1") == 7, "道具第%d页数量未识别" % page)
		_check(PlayerData.get_xhp_data("qhsbx") == 9, "消耗品第%d页数量未识别" % page)
		_check(PlayerData.get_dj_page("qhs_1") == page, "道具页码查询错误")
		_check(PlayerData.get_xhp_page("qhsbx") == page, "消耗品页码查询错误")
		PlayerData.add_dj("qhs_1", 3)
		PlayerData.add_xhp("qhsbx", 3)
		_check(PlayerData.get_item_data("qhs_1") == 10, "道具叠加后数量错误")
		_check(PlayerData.get_xhp_data("qhsbx") == 12, "消耗品叠加后数量错误")
		PlayerData.remove_dj("qhs_1", page, 4)
		PlayerData.remove_xhp("qhsbx", page, 4)
		_check(PlayerData.get_item_data("qhs_1") == 6, "道具扣除后数量错误")
		_check(PlayerData.get_xhp_data("qhsbx") == 8, "消耗品扣除后数量错误")
		PlayerData.player_data["道具列表"][key] = []
		PlayerData.player_data["消耗品列表"][key] = []
	_check(PlayerData.get_item_data("qhs_1") == 0, "空背包道具数量错误")
	_check(PlayerData.get_xhp_data("qhsbx") == 0, "空背包消耗品数量错误")
	_check(PlayerData.get_item_data("empty") == 0 and PlayerData.get_xhp_data("empty") == 0, "空格哨兵行为变化")
	PlayerData.player_data["道具列表"]["页码10"] = [{"名字": "qhs_1", "数量": 23, "Data": {}}]
	PlayerData.player_data["消耗品列表"]["页码20"] = [{"名字": "qhsbx", "数量": 17}]
	var material: = (load("res://Scene/BackPack/dj_information.tscn") as PackedScene).instantiate()
	material.my_name = "qhs_1"
	material.position = Vector2(200, 150)
	add_child(material)
	var consumable: = (load("res://Scene/BackPack/dj_information.tscn") as PackedScene).instantiate()
	consumable.my_name = "qhsbx"
	consumable.position = Vector2(700, 150)
	add_child(consumable)
	await get_tree().create_timer(0.35).timeout
	_check(material.sl.text == "拥有：23 个", "第10页材料详情显示错误")
	_check(consumable.sl.text == "拥有：17 个", "第20页消耗品详情显示错误")
	await RenderingServer.frame_post_draw
	_check(get_viewport().get_texture().get_image().save_png("res://.codex_tmp/inventory_late_page.png") == OK, "详情截图失败")
	PlayerData.player_data["道具列表"] = original_items
	PlayerData.player_data["消耗品列表"] = original_consumables
	print("INVENTORY_LATE_PAGE_PROBE checks=%d failures=%d" % [_checks, _failures.size()])
	get_tree().quit(0 if _failures.is_empty() else 1)

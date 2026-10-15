extends SceneTree

var failures: Array[String] = []


func _init() -> void :
	call_deferred("_run")


func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)


func _clear_item(player_data: Node, item_id: String) -> void :
	var count: = int(player_data.call("get_item_data", item_id))
	if count > 0:
		player_data.call("remove_dj", item_id, player_data.call("get_dj_page", item_id), count)


func _run() -> void :
	var scene: = load("res://Scene/Pet/PetInterface.tscn") as PackedScene
	var player_data: = root.get_node_or_null("PlayerData")
	_check(scene != null and player_data != null, "宠物阵法依赖无法加载")
	if scene == null or player_data == null:
		_finish()
		return

	var interface: = scene.instantiate()
	root.add_child(interface)
	await process_frame
	interface.set("current_pet_index", 0)
	interface.call("_refresh_all")
	var popup: = interface.get_node_or_null("PetFormationPopup") as Control
	var window: = interface.get_node_or_null("PetFormationPopup/Window") as Control
	var list: = interface.get_node_or_null("PetFormationPopup/Window/FormationScroll/FormationList") as VBoxContainer
	interface.call("_on_pet_formation_pressed")
	await process_frame
	_check(popup != null and popup.visible, "宠物阵法按钮没有打开阵法页面")
	if popup != null and window != null:
		_check(window.position + window.size * 0.5 == popup.size * 0.5, "宠物阵法窗口没有居中")
	_check(list != null and list.get_child_count() == 10, "宠物阵法页面没有显示九项属性")

	var levels: Dictionary = player_data.call("get_pet_formation_levels")
	for stat_name in levels:
		levels[stat_name] = 0
	for item_id in ["zqjs", "zqjh", "xwjs", "xwjh"]:
		_clear_item(player_data, item_id)

	_check(interface.call("_pet_formation_cost", 0) == Vector2i(2, 1), "阵法初始升级消耗错误")
	_check(interface.call("_pet_formation_cost", 1) == Vector2i(3, 2), "奇数晶石对应的晶核没有向上取半")
	player_data.call("add_dj", "zqjs", 5)
	player_data.call("add_dj", "zqjh", 3)
	interface.call("_upgrade_pet_formation", "生命")
	interface.call("_upgrade_pet_formation", "生命")
	_check(int(levels.get("生命", 0)) == 2, "生命阵法没有升到2级")
	_check(int(player_data.call("get_item_data", "zqjs")) == 0 and int(player_data.call("get_item_data", "zqjh")) == 0, "生命阵法材料扣除错误")

	player_data.call("add_dj", "xwjs", 2)
	player_data.call("add_dj", "xwjh", 1)
	interface.call("_upgrade_pet_formation", "物防")
	_check(int(levels.get("物防", 0)) == 1, "物防阵法没有使用玄武材料升级")
	_check(int(player_data.call("get_item_data", "xwjs")) == 0 and int(player_data.call("get_item_data", "xwjh")) == 0, "物防阵法材料扣除错误")

	var first_pet: = {"装备": {}}
	var second_pet: = {"装备": {}}
	var first_bonuses: Dictionary = player_data.call("get_pet_equipment_bonuses", first_pet)
	var second_bonuses: Dictionary = player_data.call("get_pet_equipment_bonuses", second_pet)
	_check(int(first_bonuses.get("生命", 0)) == 800 and int(second_bonuses.get("生命", 0)) == 800, "生命阵法没有被所有宠物共享")
	_check(int(first_bonuses.get("物防", 0)) == 25 and int(second_bonuses.get("防御", 0)) == 25, "物防阵法没有被所有宠物共享")

	levels["攻击"] = 9
	_check(int(player_data.call("get_pet_formation_bonuses").get("攻击", 0)) == 450, "阵法10级前错误获得里程碑加成")
	levels["攻击"] = 10
	_check(int(player_data.call("get_pet_formation_bonuses").get("攻击", 0)) == 550, "阵法达到10级没有增加10%属性")
	interface.call("_refresh_pet_formation_popup")
	var attack_row: = interface.get("pet_formation_rows").get("攻击") as PanelContainer
	var attack_effect: Label = attack_row.get_node_or_null("Content/Effect") as Label if attack_row != null else null
	_check(attack_effect != null and attack_effect.text.contains("当前 +550"), "阵法页面没有显示10级里程碑属性")

	levels["攻击"] = 100
	interface.call("_upgrade_pet_formation", "攻击")
	_check(int(levels.get("攻击", 0)) == 100, "宠物阵法突破了100级上限")
	interface.queue_free()
	await process_frame
	_finish()


func _finish() -> void :
	if failures.is_empty():
		print("PET_FORMATION_PROBE_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)

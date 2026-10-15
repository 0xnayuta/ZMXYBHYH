extends Node

const MAP_SCENE: = preload("res://Scene/Main_menu/Map_7.tscn")

func _ready() -> void :
	var old_page: int = int(MainSet.set_data.get("CurrentLevelPage", 0))
	var old_path: String = Global.cd_path
	var old_cloud: Variant = PlayerData.player_data.get("云川", null)
	var old_progress: Dictionary = {}
	for level_number in range(63, 76):
		var key: = "东胜神州通关_%d" % level_number
		old_progress[key] = PlayerData.player_data.get(key, null)
		PlayerData.player_data.erase(key)
	MainSet.set_data["CurrentLevelPage"] = 7
	Global.cd_path = ""

	var map: = MAP_SCENE.instantiate() as Map7
	add_child(map)
	_check(map.get_node("Level_63").disabled == false, "金沙村应默认解锁")
	_check(map.get_node("Level_63").material is ShaderMaterial, "首个未通关关卡未高亮")
	_check(map.get_node("Level_64").disabled, "百仙园未被锁定")

	var level: = Game4ImportedLevel.new()
	level.add_tg(63)
	_check(bool(PlayerData.player_data.get("东胜神州通关_63", false)), "通关未记录东胜神州独立进度")
	map._update_level_progression()
	_check( not map.get_node("Level_64").disabled, "金沙村通关后百仙园未解锁")
	_check(map.get_node("Level_64").material is ShaderMaterial, "百仙园未高亮")
	_check(map.get_node("Level_65").disabled, "未通关百仙园时傲来国未锁定")

	for cleared_level in range(64, Map7.LAST_OPEN_LEVEL):
		level.add_tg(cleared_level)
		map._update_level_progression()
		var next_level: = cleared_level + 1
		_check(
			not map.get_node("Level_%d" % next_level).disabled, 
			"%d通关后%d未解锁" % [cleared_level, next_level]
		)
		_check(
			map.get_node("Level_%d" % next_level).material is ShaderMaterial, 
			"下一关%d未高亮" % next_level
		)
		if next_level < Map7.LAST_OPEN_LEVEL:
			_check(
				map.get_node("Level_%d" % (next_level + 1)).disabled, 
				"未通关%d时%d未锁定" % [next_level, next_level + 1]
			)
	level.add_tg(Map7.LAST_OPEN_LEVEL)
	map._update_level_progression()
	for closed_level in range(Map7.LAST_OPEN_LEVEL + 1, 76):
		_check(
			map.get_node("Level_%d" % closed_level).disabled, 
			"暂未开放关卡%d仍可进入" % closed_level
		)
	level.free()

	for opened_level in [72, 73, 74, 75]:
		if opened_level > Map7.LAST_OPEN_LEVEL:
			continue
		map.get_node("Level_%d" % opened_level).pressed.emit()
		await get_tree().process_frame
		await get_tree().process_frame
		var info: Node = null
		for child in get_children():
			if child.scene_file_path == "res://Scene/OtherScene/LevelInfo.tscn":
				info = child
				break
		_check(info != null, "点击新开放关卡%d未打开挑战入口" % opened_level)
		if info != null:
			_check(str(info.get("TargetStagePath")) == "res://Scene/Level/Level_%d.tscn" % opened_level, 
				"新开放关卡%d场景路径错误" % opened_level)
			info.queue_free()
			await get_tree().process_frame
	for closed_level in range(Map7.LAST_OPEN_LEVEL + 1, 76):
		map.get_node("Level_%d" % closed_level).pressed.emit()
		await get_tree().process_frame
		for child in get_children():
			_check(child.scene_file_path != "res://Scene/OtherScene/LevelInfo.tscn", "关闭关卡仍打开挑战入口")
	await RenderingServer.frame_post_draw
	_check(get_viewport().get_texture().get_image().save_png("res://.codex_tmp/east_three_levels_open.png") == OK, 
		"地图开放验证截图失败")

	for key in old_progress:
		if old_progress[key] == null:
			PlayerData.player_data.erase(key)
		else:
			PlayerData.player_data[key] = old_progress[key]
	MainSet.set_data["CurrentLevelPage"] = old_page
	if old_cloud == null:
		PlayerData.player_data.erase("云川")
	else:
		PlayerData.player_data["云川"] = old_cloud
	Global.cd_path = old_path
	print("EAST_CONTINENT_PROGRESSION_PROBE_OK")
	get_tree().quit()

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	get_tree().quit(1)

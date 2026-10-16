class_name OldMemoryFacade
extends RefCounted

signal Main_Init(index: int)

var isInit: bool = true


func CheckOutTime() -> bool:
	return false


func readData(index: int) -> void:
	if index == 0:
		MemoryClass.main_dq()
		Main_Init.emit(int(MainSet.set_data.get("MainMenuBG", 1)))
		return

	Global.cd_path = _archive_path(index)
	MemoryClass.读取游戏(Global.cd_path)
	Global.userGlobal.gotoMap()


func initData(data: Dictionary) -> void:
	if data == null:
		return

	for key in data:
		PlayerData.player_data[key] = data[key]

	if not PlayerData.player_data.has("Myself"):
		PlayerData.player_data["Myself"] = 1
	if int(PlayerData.player_data["Myself"]) <= 0:
		PlayerData.player_data["Myself"] = 1
	if PlayerData.has_method("ensure_special_dungeon_progress"):
		PlayerData.ensure_special_dungeon_progress()

	保存游戏(Global.cd_path)
	Global.userGlobal.gotoMap()


func 保存游戏(index) -> void:
	var path := str(index)
	if path == "" or path == "0":
		MemoryClass.main_bc()
		return

	if path.is_valid_int():
		path = _archive_path(int(path))

	if path.begins_with("user://"):
		Global.cd_path = path
		_ensure_archive_meta(path)
		MemoryClass.保存游戏(path)
	else:
		MemoryClass.main_bc()


func RemoveMainData(num: int) -> void:
	MemoryClass.RemoveMainData(num)


func _archive_path(index) -> String:
	return "user://MyAr_%s.json" % str(index)


func _archive_num(path: String) -> int:
	if path.find("Ar_") == -1:
		return 0
	return int(path.split("Ar_")[1].split(".")[0])


func _ensure_archive_meta(path: String) -> void:
	var num := _archive_num(path)
	if num <= 0:
		return

	var time_text: String = MemoryClass.get_time()
	if num <= 6:
		MainSet.set_data["time" + str(num)] = time_text
		if not MainSet.set_data.has("name" + str(num)):
			MainSet.set_data["name" + str(num)] = ""
	else:
		var key := str(num)
		if not MainSet.set_data["其他存档"].has(key):
			MainSet.set_data["其他存档"][key] = {"name": "", "time": ""}
		MainSet.set_data["其他存档"][key]["time"] = time_text
	MemoryClass.main_bc()

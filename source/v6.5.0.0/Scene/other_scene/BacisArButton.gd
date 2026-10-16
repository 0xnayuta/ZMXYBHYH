extends TextureButton

@onready var my_num: Label = $MyNum
@onready var Name: Label = $InfoBox/Name
@onready var level_and_role: Label = $InfoBox/LevelAndRole
@onready var time: Label = $InfoBox/Time

var MyNum: int


func _physics_process(_delta: float) -> void:
	SetNormalInfo()
	set_physics_process(false)


func SetNormalInfo() -> void:
	my_num.text = str(MyNum)
	var archive_data: Dictionary = MemoryClass.提前数据(_archive_path(MyNum))
	var role_id: int = int(archive_data.get("Myself", 0))
	if role_id < 1 or role_id > 6:
		Name.text = ""
		time.text = ""
		level_and_role.text = "空存档"
		return

	var metadata: Dictionary = _archive_metadata(MyNum)
	var archive_time: String = str(metadata.get("time", ""))
	if archive_time.strip_edges() == "":
		archive_time = MemoryClass.读取存档时间(_archive_path(MyNum))
		if archive_time != "":
			MemoryClass.repair_archive_time(MyNum, archive_time)
	var archive_name: String = str(metadata.get("name", ""))
	time.text = archive_time
	Name.text = "名字：" + archive_name if archive_name != "" else ""
	level_and_role.text = "Lv：" + str(MemoryClass.得到数据(_archive_path(MyNum))) + "    " + _role_name(role_id)


func _archive_path(archive_number: int) -> String:
	return "user://MyAr_" + str(archive_number) + ".json"


func _archive_metadata(archive_number: int) -> Dictionary:
	if archive_number <= 6:
		return {
			"name": MainSet.set_data.get("name" + str(archive_number), ""),
			"time": MainSet.set_data.get("time" + str(archive_number), ""),
		}
	var other_archives_value: Variant = MainSet.set_data.get("其他存档", {})
	if not other_archives_value is Dictionary:
		return {}
	var other_archives: Dictionary = other_archives_value as Dictionary
	var metadata_value: Variant = other_archives.get(str(archive_number), {})
	return metadata_value as Dictionary if metadata_value is Dictionary else {}


func GeTroleNmae(cd_num) -> String:
	return _role_name(int(MemoryClass.提前数据(_archive_path(int(cd_num))).get("Myself", 0)))


func _role_name(role_id: int) -> String:
	match role_id:
		1:
			return "悟空"
		2:
			return "唐僧"
		3:
			return "八戒"
		4:
			return "沙僧"
		5:
			return "白龙"
		6:
			return "哪吒"
	return "空存档"


func _on_pressed() -> void:
	Global.cd_path = "user://MyAr_" + str(MyNum) + ".json"
	if not MemoryClass.读取游戏(Global.cd_path):
		return
	if PlayerData.player_data.has("FileValue"):
		if float(PlayerData.player_data["FileValue"]) <= float(Global.FileNum):
			PlayerData.player_data["FileValue"] = Global.FileNum
		else:
			Global.add_message_show(get_parent(), "当前游戏不是最新版本，请使用最新版本游戏！！！", 1.5, Vector2(470, 340))
			return
	if level_and_role.text == "空存档":
		Global.change_scene("res://Scene/main_menu/ChoosePlayer.tscn")
	else:
		await Global.begin_archive_session()
		change_to_map()


func change_to_map():
	Global.change_scene("res://Scene/main_menu/Map_0.tscn")


func get_time():
	var date = Time.get_date_string_from_system()
	var time_ = Time.get_time_string_from_system()
	var last_time = date + " " + time_
	return last_time

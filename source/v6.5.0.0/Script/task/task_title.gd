extends TextureButton
var TaskName: String
var TaskType: String
var my_father: BasicTask

@onready var tilte: Label = $Tilte
@onready var label: Label = $Label

var TaskInfo: String
var reward_list = []
var nb_name: String
var finish: bool


func _physics_process(delta: float) -> void:
	tilte.text = TaskName
	if TaskType != "DailyTask" and PlayerData.player_data.get(TaskName, false):
		label.text = "已领取"
		my_father.activity_finish_num += 1
		label.add_theme_color_override("font_color", "00ffff")
		label.add_theme_color_override("font_outline_color", "00ffff")
		set_physics_process(false)
		return
	if check_task_finish():
		finish = true
		if TaskType == "DailyTask":
			my_father.daily_finish_num += 1
		label.text = "已完成"
		label.add_theme_color_override("font_color", "00ff00")
		label.add_theme_color_override("font_outline_color", "00ff00")
	else:
		finish = false
		label.text = "未完成"
		label.add_theme_color_override("font_color", "ff0000")
		label.add_theme_color_override("font_outline_color", "ff0000")
	set_physics_process(false)


func check_task_finish():
	match TaskType:
		"ActivityTask":
			match my_father.all_activity_list[TaskName]["FinishType"]:
				1:
					var target = my_father.all_activity_list[TaskName]["TaskTarget"]
					for i in target:
						if PlayerData.player_data[i] < target[i]:
							return false
					return true
				2:
					var target = my_father.all_activity_list[TaskName]["TaskTarget"]
					for i in target:
						if PlayerData.player_data[DataKeys.PLAYER_LEVEL] < target[i]:
							return false
					return true
				3:
					var target = my_father.all_activity_list[TaskName]["TaskTarget"]
					match int(PlayerData.player_data["Myself"]):
						1:
							if PlayerData.check_have_zb("wkttzssz")[0]:
								return true
						2:
							if PlayerData.check_have_zb("tsttzssz")[0]:
								return true
						3:
							if PlayerData.check_have_zb("bjttzssz")[0]:
								return true
						4:
							if PlayerData.check_have_zb("ssttzssz")[0]:
								return true
					return false
				4:
					var target = my_father.all_activity_list[TaskName]["TaskTarget"]
					if PlayerData.player_data["幻化拥有列表"].size() >= int(target["收集进度"]):
						return true
					return false
				5:
					var target = my_father.all_activity_list[TaskName]["TaskTarget"]
					if not PlayerData.player_data["ieho"] and PlayerData.player_data["截教天镜"]:
						return true
					return false
				6:
					var target = my_father.all_activity_list[TaskName]["TaskTarget"]
					for key in target.keys():
						if PlayerData.player_data.get(key, -1) < target[key]:
							return false
					return true
					return true

		"DailyTask":
			pass
	return true


func _on_pressed() -> void:
	my_father.task_is_finish = finish
	my_father.current_task_type = 2 if TaskType == "DailyTask" else 1
	my_father.current_task_name = TaskName
	my_father.add_reward()

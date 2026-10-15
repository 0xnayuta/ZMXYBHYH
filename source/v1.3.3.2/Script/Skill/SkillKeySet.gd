extends Node2D
var need_name: String

func _on_y_pressed() -> void :

	PlayerData.player_data["技能学习"]["技能键位"]["Y"] = str(need_name)
	MemoryClass.保存游戏(Global.cd_path)
	queue_free()

func _on_u_pressed() -> void :
	PlayerData.player_data["技能学习"]["技能键位"]["U"] = str(need_name)
	MemoryClass.保存游戏(Global.cd_path)
	queue_free()

func _on_i_pressed() -> void :
	PlayerData.player_data["技能学习"]["技能键位"]["I"] = str(need_name)
	MemoryClass.保存游戏(Global.cd_path)
	queue_free()

func _on_o_pressed() -> void :
	PlayerData.player_data["技能学习"]["技能键位"]["O"] = str(need_name)
	MemoryClass.保存游戏(Global.cd_path)
	queue_free()

func _on_l_pressed() -> void :
	PlayerData.player_data["技能学习"]["技能键位"]["L"] = str(need_name)
	MemoryClass.保存游戏(Global.cd_path)
	queue_free()

func _on_close_pressed() -> void :
	queue_free()

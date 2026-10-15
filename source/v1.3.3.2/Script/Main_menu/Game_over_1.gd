extends Node2D
@onready var Over_text: Label = $OVERTEXT
@onready var Over_Player = $Over
var Text_1 = "第一系列----《七魔王篇》终了\n\n\n\n\n\n\n浩劫之际，决战牛魔谷\n\n经七日七夜，与平天魔王不分胜负\n\n昏黑之晨，魔露本态\n\n张牙舞爪，撕牙咧嘴\n\n三藏颂九环真经封其魂魄\n\n悟空以如意金箍棒直破魔心\n\n微风徐徐，乌黑散尽\n\n只见朝霞映天，大地初醒\n\n\n游戏制作：早春樱花\n\n布景：原版造梦\n\n造型：原版造梦\n\n道具：原版造梦\n\n特效：原版造梦，改版造梦\n\n程序：早春樱花\n\n请多多支持原版造梦，此版本纯属娱乐！！"




































var Text_2 = "第二系列----《十殿阎罗篇》终了\n\n\n\n\n\n\n浩劫之际，决战牛魔谷\n\n经七日七夜，与平天魔王不分胜负\n\n昏黑之晨，魔露本态\n\n张牙舞爪，撕牙咧嘴\n\n三藏颂九环真经封其魂魄\n\n悟空以如意金箍棒直破魔心\n\n微风徐徐，乌黑散尽\n\n只见朝霞映天，大地初醒\n\n请多多支持原版造梦，此版本纯属娱乐！！"























func _ready() -> void :
	if Global.GameOver == 1:
		Over_text.text = Text_1
		Global.addBGM_(self, "res://Music/level/10_bg4.mp3")
		Over_Player.play("first_")
		await get_tree().create_timer(3, false).timeout
		Over_Player.play("second_")
		await get_tree().create_timer(3, false).timeout
		Over_Player.play("third")
		await get_tree().create_timer(3, false).timeout
		Over_Player.play("XY_1OVER")
		await Over_Player.animation_finished
		get_tree().change_scene_to_file("res://Scene/Level/victory.tscn")
	elif Global.GameOver == 2:
		Global.addBGM_(self, "res://Music/level/2_bg4.mp3")
		Over_Player.play("Over_1")

func _on_tiaoguo_pressed() -> void :
	get_tree().change_scene_to_file("res://Scene/Level/victory.tscn")


func _on_beisu_pressed() -> void :
	if int($beisu / beisu_l.text) > 0:
		Over_Player.speed_scale = int($beisu / beisu_l.text)
	else:
		Global.add_moment_text(self, Vector2(470, 300), "请正确输入速度！！", 2)


func _on_bg_1_pressed() -> void :
	Over_Player.play("Over_2")

func ChangeTomap():
	get_tree().change_scene_to_file("res://Scene/Level/victory.tscn")

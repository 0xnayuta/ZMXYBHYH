extends Button

@onready var pd: Label = $pd
var RealName
var zhenfaName: String
var Father
var _last_icon_name: String = ""


func _physics_process(delta: float) -> void:
	if zhenfaName != _last_icon_name:
		_last_icon_name = zhenfaName
		self.set_button_icon(
			Global.get_cached_texture("res://Art/TwentyEightConstellations/" + str(zhenfaName) + ".png")
		)


func _on_pressed() -> void:
	match zhenfaName:
		"slz":
			RealName = "森罗阵"
		"lpz":
			RealName = "落魄阵"
		"tsz":
			RealName = "腾蛇阵"
		"tqz":
			RealName = "太清阵"
	var List = PlayerData.player_data[RealName]
	var Num: int = 0
	for i in List:
		if typeof(List[i]) == TYPE_DICTIONARY:
			Num += 1
	if Father != null:
		Father.CurrentZhenFaName = zhenfaName
		if Father.CurrentNum > Num:
			Father.CurrentNum = 1
		Father.on_change_name()
		Father.add_zhenyan_button()

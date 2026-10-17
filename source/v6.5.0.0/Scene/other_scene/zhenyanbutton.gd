extends TextureRect
@onready var locandlevel: Label = $locandlevel
@onready var pic: Button = $Pic
@onready var jt: Sprite2D = $jt

var not_show: bool
var loc_num: int
var zhen_fa_type: String
var real_name: String
var father


func _physics_process(delta: float) -> void:
	if father != null:
		zhen_fa_type = father.current_zhen_fa_name
		match zhen_fa_type:
			"slz":
				real_name = "森罗阵"
			"lpz":
				real_name = "落魄阵"
			"tsz":
				real_name = "腾蛇阵"
			"tqz":
				real_name = "太清阵"
		var item_name = PlayerData.player_data[real_name][str(loc_num)]["InName"]
		pic.set_button_icon(load_(item_name))
		pic.qh_level = 0
		pic.wx = []
		pic.eq_prop = AE.all_equipment[item_name]
		var cur_level = PlayerData.player_data[real_name][str(loc_num)]["Level"]
		locandlevel.text = str(loc_num) + "号位 Lv:" + str(cur_level)
		if not not_show:
			if father.current_num == loc_num:
				jt.visible = true
			else:
				jt.visible = false
		else:
			jt.visible = false


func load_(name_):
	var abc = load("res://Art/BackPack/AllItems/" + str(name_) + ".png")
	return abc


func _on_button_pressed() -> void:
	father.current_num = int(loc_num)

extends Node2D

@onready var HaveOrNot: Label = $BG/HaveOrNot
@onready var cdorxx: Label = $BG/change/cdorxx
@onready var cdinfor: Sprite2D = $cdinfor
@onready var show_box: Button = $BG/ShowBox
@onready var Eq_name: Label = $BG/Eq_name

var SelfName_: String
var Transmogrified_: Transmogrified


func _physics_process(_delta: float) -> void:
	Eq_name.text = str(AE.AllEquipment_[SelfName_][DataKeys.NAME])
	show_box.is_in_ldl_gz = true
	show_box.is_in_hhgz = true
	show_box.set_button_icon(load_(SelfName_))
	show_box.qh_level = 0
	show_box.wx = []
	show_box.EQ_prop = AE.AllEquipment_[SelfName_]
	var List = PlayerData.player_data[DataKeys.TRANSMOG_LIST]
	if List[DataKeys.WEAPON] == SelfName_ or List[DataKeys.ARMOR] == SelfName_ or List[DataKeys.WINGS] == SelfName_:
		cdinfor.visible = true
		cdorxx.text = str("卸下")
	else:
		cdinfor.visible = false
		cdorxx.text = str("穿戴")
	if PlayerData.has_acquired_equipment(SelfName_):
		HaveOrNot.text = "已解锁"
		HaveOrNot.add_theme_color_override("font_color", "00ff00")
	else:
		HaveOrNot.add_theme_color_override("font_color", "ff0000")
		HaveOrNot.text = "未解锁"

	set_physics_process(false)


func load_(name_):
	var abc = load("res://Art/BackPack/AllItems/" + str(name_) + ".png")
	return abc


func _on_change_pressed() -> void:
	var Lx = AE.AllEquipment_[SelfName_][DataKeys.TYPE]
	var item_name = AE.AllEquipment_[SelfName_][DataKeys.NAME]

	if cdorxx.text == "穿戴":
		if PlayerData.has_acquired_equipment(SelfName_):
			if Lx == "武器":
				PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON] = SelfName_
				Global.add_message_show(Global.Windows_, "武器幻化为：" + str(item_name) + "！！", 1.5, Vector2(470, 295))
			elif Lx == "防具":
				PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR] = SelfName_
				Global.add_message_show(Global.Windows_, "防具幻化为：" + str(item_name) + "！！", 1.5, Vector2(470, 295))
			elif Lx == "时装":
				PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR] = SelfName_
				Global.add_message_show(Global.Windows_, "时装幻化为：" + str(item_name) + "！！", 1.5, Vector2(470, 295))
			elif Lx == "翅膀":
				PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS] = SelfName_
				Global.add_message_show(Global.Windows_, "翅膀幻化为：" + str(item_name) + "！！", 1.5, Vector2(470, 295))
		else:
			Global.add_message_show(Global.Windows_, "您还未获得过" + str(item_name) + "！！", 1.5, Vector2(470, 295))
	elif cdorxx.text == "卸下":
		if Lx == "武器":
			PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON] = ""
			Global.add_message_show(Global.Windows_, "取消武器：" + str(item_name) + "的幻化！！", 1.5, Vector2(470, 295))
		elif Lx == "防具":
			PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR] = ""
			Global.add_message_show(Global.Windows_, "取消防具：" + str(item_name) + "的幻化！！", 1.5, Vector2(470, 295))
		elif Lx == "时装":
			PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR] = ""
			Global.add_message_show(Global.Windows_, "取消时装：" + str(item_name) + "的幻化！！", 1.5, Vector2(470, 295))
		elif Lx == "翅膀":
			PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS] = ""
			Global.add_message_show(Global.Windows_, "取消翅膀：" + str(item_name) + "的幻化！！", 1.5, Vector2(470, 295))
	Transmogrified_.onEqchange()
	if is_instance_valid(RoleProp.SourcePlayer) and RoleProp.SourcePlayer.has_method("onEqchange"):
		RoleProp.SourcePlayer.onEqchange()
	for i in Transmogrified_.List:
		if i != null:
			i.set_physics_process(true)
	MemoryClass.save_game(Global.cd_path)
	set_physics_process(true)

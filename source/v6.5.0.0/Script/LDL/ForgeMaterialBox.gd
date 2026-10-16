extends TextureRect

@onready var NeedAndHave: Label = $NeedAndHave
@onready var box: VBoxContainer = $Box

var ItemName: String
var NeedNum: int


func _physics_process(delta: float) -> void:
	if NeedNum == 0:
		NeedAndHave.text = ""
	else:
		set_box()
		set_text()
	set_physics_process(false)


func set_text():
	if NeedNum != 0:
		if PlayerData.get_item_data(ItemName) >= NeedNum:
			NeedAndHave.add_theme_color_override("font_color", "00ff00")
		else:
			NeedAndHave.add_theme_color_override("font_color", "ff0000")
		NeedAndHave.text = str(PlayerData.get_item_data(ItemName)) + "/" + str(NeedNum)


func set_box():
	var ItemBox = Global.add_item_box(box, true, true, ItemName, 0, 1, [], AE.AllEquipment_[ItemName])
	if ItemBox == null or not is_instance_valid(ItemBox):
		return
	var icon_path := "res://Art/BackPack/AllItems/%s.png" % str(ItemName)
	ItemBox.set("icon", ResourceLoader.load(icon_path) as Texture2D if ResourceLoader.exists(icon_path) else null)


func load_(name_):
	var abc = load("res://Art/BackPack/AllItems/" + str(name_) + ".png")
	return abc

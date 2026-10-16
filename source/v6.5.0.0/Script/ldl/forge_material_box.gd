extends TextureRect

@onready var need_and_have: Label = $NeedAndHave
@onready var box: VBoxContainer = $Box

var ItemName: String
var NeedNum: int


func _physics_process(delta: float) -> void:
	if NeedNum == 0:
		need_and_have.text = ""
	else:
		set_box()
		set_text()
	set_physics_process(false)


func set_text():
	if NeedNum != 0:
		if PlayerData.get_item_data(ItemName) >= NeedNum:
			need_and_have.add_theme_color_override("font_color", "00ff00")
		else:
			need_and_have.add_theme_color_override("font_color", "ff0000")
		need_and_have.text = str(PlayerData.get_item_data(ItemName)) + "/" + str(NeedNum)


func set_box():
	var item_box = Global.add_item_box(box, true, true, ItemName, 0, 1, [], AE.all_equipment[ItemName])
	if item_box == null or not is_instance_valid(item_box):
		return
	var icon_path := "res://Art/BackPack/AllItems/%s.png" % str(ItemName)
	item_box.set("icon", ResourceLoader.load(icon_path) as Texture2D if ResourceLoader.exists(icon_path) else null)


func load_(name_):
	var abc = load("res://Art/BackPack/AllItems/" + str(name_) + ".png")
	return abc

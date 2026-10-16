extends TextureRect
@onready var items: Button = $Items
@onready var name_: Label = $Name

var item_id
var Num

var Name:
	get:
		return item_id
	set(v):
		item_id = v


func _ready() -> void:
	items.HideProp = true


func _physics_process(delta: float) -> void:
	items.set_button_icon(load_(item_id))
	if Num == null:
		items.total_number = 1
	else:
		items.total_number = Num
	name_.text = AE.AllEquipment_[item_id][DataKeys.NAME]
	var color = AE.AllEquipment_[item_id]["颜色"]
	name_.add_theme_color_override("font_color", color)
	name_.add_theme_color_override("font_outline_color", color)
	set_physics_process(false)


func load_(name_):
	var abc = load("res://Art/BackPack/AllItems/" + str(name_) + ".png")
	return abc

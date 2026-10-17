extends TextureRect
@onready var items: Button = $Items
@onready var name_: Label = $Name

var item_id
var num = 1


func _ready() -> void:
	items.hide_prop = true


func _physics_process(delta: float) -> void:
	items.set_button_icon(load_(item_id))
	items.total_number = num if num != null else 1
	name_.text = AE.all_equipment[item_id][DataKeys.NAME]
	var color = AE.all_equipment[item_id]["颜色"]
	name_.add_theme_color_override("font_color", color)
	name_.add_theme_color_override("font_outline_color", color)
	set_physics_process(false)


func load_(name_):
	var abc = load("res://Art/backpack/AllItems/" + str(name_) + ".png")
	return abc

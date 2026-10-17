extends TextureRect

var combo_num: int


func _ready() -> void:
	refresh()


func setup(value) -> void:
	combo_num = int(value)
	visible = true
	refresh()


func refresh() -> void:
	texture = Global.get_cached_texture("res://Art/all_number/lj/lj_" + str(combo_num) + ".png")

extends TextureRect

var ComboNum: int


func _ready() -> void:
	refresh()


func setup(value) -> void:
	ComboNum = int(value)
	visible = true
	refresh()


func refresh() -> void:
	texture = Global.get_cached_texture("res://Art/all_number/LJ/lj_" + str(ComboNum) + ".png")

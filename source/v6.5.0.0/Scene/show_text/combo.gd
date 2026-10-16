extends Node2D

@onready var combo_box: HBoxContainer = $ComBoxFather/ComboBoxText
@onready var combo_player: AnimationPlayer = $ComboPlayer

var ComboNum: int
var _last_combo_num: int = -1
var _digit_nodes: Array[Node] = []


func _ready() -> void:
	set_physics_process(false)
	_refresh_combo()


func set_combo_num(value: int) -> void:
	ComboNum = value
	_refresh_combo()


func _refresh_combo() -> void:
	if not is_inside_tree():
		return
	if ComboNum < 2:
		visible = false
		return
	visible = true
	if ComboNum == _last_combo_num:
		return
	_last_combo_num = ComboNum
	var digits = str(ComboNum).split("")
	while _digit_nodes.size() < digits.size():
		var node = Global.addComboNum(combo_box, 0)
		if node == null:
			return
		_digit_nodes.append(node)
	for i in range(_digit_nodes.size()):
		var node = _digit_nodes[i]
		if i < digits.size():
			if node.has_method("setup"):
				node.setup(digits[i])
			else:
				node.ComboNum = int(digits[i])
			node.visible = true
		else:
			node.visible = false
	if combo_player != null and combo_player.has_animation("combo"):
		combo_player.play("combo")

class_name SetList extends HBoxContainer

@onready var backpack: TextureButton = $"../ButtonGroup/backpack"
@onready var set_: TextureButton = $"../ButtonGroup/set"
@onready var skill: TextureButton = $"../ButtonGroup/skill"
@onready var magic_weapon: TextureButton = $"../ButtonGroup/magic_weapon"
@onready var pet: TextureButton = $"../ButtonGroup/pet"
var setCd: float = 0


func _physics_process(delta):
	if !backpack.visible:
		setCd = 0
	else:
		setCd += delta
		if setCd >= 5:
			setCd = 0
			_on_menu_pressed()


func _on_menu_pressed():
	var isHidden: bool = !backpack.visible
	backpack.visible = isHidden
	set_.visible = isHidden
	skill.visible = isHidden
	magic_weapon.visible = isHidden
	pet.visible = isHidden

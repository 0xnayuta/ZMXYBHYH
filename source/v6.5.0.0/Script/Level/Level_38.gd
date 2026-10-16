extends BaseLevel

@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3
@onready var stop_5: CollisionShape2D = $wall/stop5

@onready var check: Area2D = $Check
@onready var tp: Area2D = $Tp
@onready var ycgk: Sprite2D = $BackGround/floor_2/ycgk

var HurtCount: int = 0
var IsPlay: bool = false
var animation_played: bool = false
var can_through: bool = false

var normal_hp_multiplier: float = 2.0


func level_create_monster(stage: int):
	super.level_create_monster(stage)

	if self.mr and not self.mr.is_boss:
		call_deferred("_apply_hp_multiplier", self.mr)


func _apply_hp_multiplier(monster: BaseMonster):
	if monster and not monster.is_boss:
		monster.SHp = int(monster.SHp * normal_hp_multiplier)
		monster.Hp = monster.SHp


func _ready() -> void:
	load("res://Scene/Monster/Monster_119.tscn")
	load("res://Scene/Monster/Monster_118.tscn")
	load("res://Scene/Monster/Monster_120.tscn")
	load("res://Scene/Monster/Monster_122.tscn")

	Global.CurrentLevel = "蓬莱岛"
	Global.addBGM_(self, "res://Music/level/34_bg5.mp3")
	self.level_stage = 43
	super._ready()

	$Check/check.disabled = false
	$Tp/tp.disabled = true

	if not check.is_connected("area_entered", Callable(self, "_on_check_area_entered")):
		check.connect("area_entered", Callable(self, "_on_check_area_entered"))
	if not tp.is_connected("body_entered", Callable(self, "_on_tp_body_entered")):
		tp.connect("body_entered", Callable(self, "_on_tp_body_entered"))
	if not tp.is_connected("body_exited", Callable(self, "_on_tp_body_exited")):
		tp.connect("body_exited", Callable(self, "_on_tp_body_exited"))

	Monster_group = {
		"stage_1":
		[
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
		],
		"stage_2":
		[
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
		],
		"stage_3":
		[
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
			118,
			119,
			120,
			122,
		],
		"stage_4": [1408],
	}
	Monster_position_x = {
		"stage_1":
		[
			100,
			400,
			700,
			1000,
			100,
			400,
			700,
			1000,
			100,
			400,
			700,
			1000,
			100,
			400,
			700,
			1000,
			100,
			400,
			700,
			1000,
		],
		"stage_2":
		[
			1350,
			1750,
			2150,
			1350,
			1750,
			2150,
			1350,
			1750,
			2150,
			1650,
			1420,
			1650,
			1400,
			1650,
			1420,
			1550,
			2000,
			1550,
			2000,
			1550,
			2000,
			1550,
			2000,
			1550,
			2000,
			1400,
			2000,
			1400,
			2000,
			1400,
			2000,
			1400,
			2000
		],
		"stage_3":
		[
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250
		],
		"stage_4": [4500, 4500, 4500, 4500, 4500, 4500, 4500, 4500, 4500, 4500, 4500, 4500],
	}
	Monster_position_y = {
		"stage_1":
		[
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420
		],
		"stage_2":
		[
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420
		],
		"stage_3":
		[
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			220,
			420,
			420,
			220,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420
		],
		"stage_4": [450, 450, 450, 450, 450, 450, 450, 450, 450, 450],
	}


func _physics_process(delta: float) -> void:
	if HurtCount >= 5 and not animation_played:
		if not IsPlay:
			_trigger_hidden_animation()
			IsPlay = true

	super._physics_process(delta)

	if can_through and Input.is_action_pressed("Exit"):
		_transport_to_hidden_level()

	if current_stage >= 1:
		if check_can_pass() and current_stage < 4:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false


func set_through():
	if current_stage == 1:
		if check_can_pass():
			stop_1.disabled = true
	elif current_stage == 2:
		if check_can_pass():
			stop_2.disabled = true
	elif current_stage == 3:
		if check_can_pass():
			stop_3.disabled = true
	elif current_stage == 4:
		my_camera.max_left = 3500
		stop_5.disabled = false


func _trigger_hidden_animation():
	$Check/check.disabled = true

	var tween = create_tween()
	tween.tween_property(ycgk, "position:x", ycgk.position.x + 300, 1.0)

	tween.tween_callback(
		func():
			animation_played = true
			$Tp/tp.disabled = false
	)


func _on_check_area_entered(area: Area2D) -> void:
	if not $Check/check.disabled:
		HurtCount += 1
		Global.add_mr_hurt($Check, Vector2(0, 0))


func _on_tp_body_entered(body: Node2D) -> void:
	if body is BaseHero:
		can_through = true
		Global.AddMessageShow(Global.get_player, "按 W 键传送", 1.5, Vector2(0, -200))


func _on_tp_body_exited(body: Node2D) -> void:
	if body is BaseHero:
		can_through = false


func _transport_to_hidden_level():
	Global.change_scene("res://Scene/Level/Level_38_1.tscn")

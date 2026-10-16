extends BaseLevel

const MONSTER_130_SCENE := preload("res://Scene/Monster/Monster_130.tscn")

@onready var left_wall: CollisionShape2D = $wall/left_wall
@onready var right_wall: CollisionShape2D = $wall/right_wall


func _ready() -> void:
	Monster_group = {
		"stage_1": [130],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	Monster_position_x = {
		"stage_1": [500],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	Monster_position_y = {
		"stage_1": [200],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	Global.CurrentLevel = "广寒宫"
	Global.GameOver = 1
	level_stage = 0
	is_two_scene = false
	Global.addBGM_(self, "res://Music/level/BGM_Normal.mp3")
	super._ready()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if my_camera != null:
		my_camera.max_left = 0
		my_camera.max_right = 1703
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = one_check_can_exit()


func set_through() -> void:
	if left_wall != null:
		left_wall.disabled = false
	if right_wall != null:
		right_wall.disabled = false


func one_check_can_exit() -> bool:
	if not Monster_group.has("stage_1") or not Monster_group["stage_1"].is_empty():
		return false
	return _get_alive_stage_monster_count() == 0


func check_can_exit() -> bool:
	return one_check_can_exit()

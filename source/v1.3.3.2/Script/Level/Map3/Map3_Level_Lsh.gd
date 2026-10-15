class_name Map3_Level_Lsh extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall / stop1
var is_cc = false
func _ready() -> void :
	Global.addBGM_(self, "res://Music/level/2_bg4.mp3")
	preload("res://Scene/Monster/Monster_500.tscn")
	preload("res://Scene/Monster/Monster_501.tscn")
	preload("res://Scene/Monster/Monster_502.tscn")


	change_boss_type(Global.get_lsh_boss_index())


	Global.GameFrame.level_mgr_component.curr_Level_Info = self
	self.level_stage = 1
	super._ready()






	Monster_position_x = {
		"stage_1": [850], 
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

func change_boss_type(type: Enums.Enum_LiuShaHe_Boss_State) -> void :
	match type:
		Enums.Enum_LiuShaHe_Boss_State.邪沙僧:

			Monster_group["stage_1"] = [500]


		Enums.Enum_LiuShaHe_Boss_State.邪八戒:

			Monster_group["stage_1"] = [501]

		Enums.Enum_LiuShaHe_Boss_State.邪唐僧:

			Monster_group["stage_1"] = [502]









		_:
			Global.AddMessageShow(get_parent(), "暂未开放，敬请期待！！！！", 1.5, Vector2(470, 300))
	pass

func _physics_process(delta: float) -> void :
	if not is_cc:
		if Role_.position.x >= 600:
			create_control.wait_time = 3
			create_control.start()
			is_cc = true
			role_information.gogo.visible = false
		else:
			create_control.wait_time = 3
			create_control.start()
	super._physics_process(delta)
	my_camera.max_right = 940
	if current_stage >= 1:
		if check_can_pass() and current_stage < 1:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false

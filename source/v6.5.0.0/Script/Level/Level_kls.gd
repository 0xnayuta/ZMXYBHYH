extends BaseLevel
var is_cc = false
var WangWang: Monster144


func _ready() -> void:
	Global.addBGM_(self, "res://Music/level/BGM_Normal.mp3")
	Global.CurrentLevel = ""
	self.level_stage = 0
	super._ready()
	Monster_group = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	Monster_position_x = {
		"stage_1": [100],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	Monster_position_y = {
		"stage_1": [100],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	my_camera.max_right = 2800
	my_camera.max_top = -930
	role_information.gogo.visible = false

extends BaseLevel
class_name Level22
@onready var floor: Node2D = $Floor
var Is_set: bool
var CallCount: int = 0
func _ready() -> void :

	Global.CurrentLevel = "九重天"
	Global.addBGM_(self, "res://Music/level/Floor1_3.mp3")
	self.level_stage = 1
	super._ready()
	Monster_group = {
		"stage_1": [], 
		"stage_2": [], 
		"stage_3": [], 
		"stage_4": [], 
	}
	Monster_position_x = {
		"stage_1": [700], 
		"stage_2": [], 
		"stage_3": [], 
		"stage_4": [], 
	}
	Monster_position_y = {
		"stage_1": [-5100], 
		"stage_2": [], 
		"stage_3": [], 
		"stage_4": [], 
	}
func _physics_process(delta: float) -> void :
	CallCount += 1
	if CallCount % 240 == 0:
		for i in range(randi_range(3, 5)):

			pass
	if not Is_set:
		AddStage()
		Is_set = true
	my_camera.max_top = -5426
	my_camera.max_right = 940
	if Role_.position.y <= -4900:
		my_camera.max_bottom = -4835
	role_information.gogo.visible = false
	super._physics_process(delta)
func set_through():
	return


func _on_area_2d_body_entered(body: Node2D) -> void :
	return


func _on_area_2d_body_exited(body: Node2D) -> void :
	pass
func AddStage():
	randomize()
	var StageInfo = [
		{"Type": "an_" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 395), 190)}, 
		{"Type": "an_4" + str(randi_range(1, 5)), "Position": Vector2(randi_range(600, 695), -110)}, 
		{"Type": "an_4" + str(randi_range(1, 5)), "Position": Vector2(randi_range(305, 340), -410)}, 
		{"Type": "an_1" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 540), -710)}, 
		{"Type": "an_3" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 395), -910)}, 
		{"Type": "an_4" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 395), -1210)}, 
		{"Type": "an_3" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 395), -1410)}, 
		{"Type": "an_3" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 395), -1610)}, 
		{"Type": "an_1" + str(randi_range(1, 5)), "Position": Vector2(randi_range(335, 395), -1910)}, 
		{"Type": "an_1" + str(randi_range(1, 5)), "Position": Vector2(randi_range(535, 795), -2210)}, 
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(105, 395), -2510)}, 
		{"Type": "an_1" + str(randi_range(1, 5)), "Position": Vector2(randi_range(115, 275), -2810)}, 
		{"Type": "an_1" + str(randi_range(1, 5)), "Position": Vector2(randi_range(465, 595), -3110)}, 
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(165, 395), -3410)}, 
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(465, 625), -3710)}, 
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(165, 295), -4010)}, 
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(265, 495), -4310)}, 
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(565, 795), -4610)}, 
		{"Type": "an_5" + str(randi_range(1, 5)), "Position": Vector2(randi_range(365, 395), -4810)}, 

	]
	var Stage
	for i in StageInfo:
		var ta = "an_" + str(randi_range(1, 5))
		Stage = Global.AddStage(floor, "an_" + str(randi_range(1, 5)), i["Position"])
		if randi_range(0, 50) > 25:
			Stage.scale.x = -1
		await get_tree().create_timer(randf_range(0.5, 1))

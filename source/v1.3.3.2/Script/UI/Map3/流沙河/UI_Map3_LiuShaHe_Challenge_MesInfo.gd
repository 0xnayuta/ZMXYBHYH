class_name UI_Map3_LiuShaHe_Challenge_MesInfo extends Control

@onready var boss_dark_img: TextureRect = $Boss_Dark_Img
@onready var challenge_btn: TextureButton = $Challenge_Btn

@export var enum_LiuShaHe_Boss_State: Enums.Enum_LiuShaHe_Boss_State = Enums.Enum_LiuShaHe_Boss_State.邪沙僧

const MAP_3_LEVEL_LSH = preload("res://Scene/Level/Map3/Map3_Level_Lsh.tscn")

func _ready() -> void :
	challenge_btn.pressed.connect(challenge_btn_pressed)
	pass


func challenge_btn_pressed() -> void :



	if not enum_LiuShaHe_Boss_State == Enums.Enum_LiuShaHe_Boss_State.邪沙僧:
		Global.AddMessageShow(UI_Map3_Lsh_Challenge_Panel.GetUI("UI_Map3_Lsh_Challenge_Panel"), "暂未开放，敬请期待！！！！", 1.5, Vector2(470, 300))
		return


	UI_Map3_Lsh_Challenge_Panel.GetUI("UI_Map3_Lsh_Challenge_Panel").Close()

	Global.set_lsh_boss_index(enum_LiuShaHe_Boss_State)











	Global.change_secen("res://Scene/Level/Map3/Map3_Level_Lsh.tscn")





func _deferred_replace_scene(new_level):
	print("正在替换场景...")

	var mgr: LevelMgr_Component = Global.GameFrame.level_mgr_component as LevelMgr_Component
	if not mgr:
		push_error("LevelMgrComponent 未找到！")
		return


	if is_instance_valid(mgr.curr_Level_Info):
		mgr.remove_child(mgr.curr_Level_Info)
		mgr.curr_Level_Info.queue_free()


	mgr.curr_Level_Info = new_level
	Global.target_scene = "res://Scene/Level/Map3/Map3_Level_Lsh.tscn"
	get_tree().root.add_child(new_level)
	mgr.curr_Level_Info.change_boss_type(enum_LiuShaHe_Boss_State)

	if is_instance_valid(new_level):
		new_level.visible = true

	print("场景切换完成！")

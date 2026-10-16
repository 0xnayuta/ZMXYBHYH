extends Node2D
const FULLSCREEN_DESIGN_SIZE := Vector2(940, 590)
@onready var bg: Sprite2D = $bg
@onready var bg_2: Sprite2D = $bg/bg2
@onready var main_backpack: Control = $Main_Backpack
@onready var lh: Label = $bg/bg2/lh

var Synthesis_: Synthesis
var Strength_: Strength
var Mosaic_: Mosaic
var Decompose_: Decompose
var Forge_: Forge
var OneKeySyn_: OneKeySynthesis
var DivineForge_: DivineForge
var BoneForge_: Node


func _physics_process(_delta: float) -> void:
	lh.text = str(PlayerData.get_soul())


func _fit_to_fullscreen() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(viewport_size.x / FULLSCREEN_DESIGN_SIZE.x, viewport_size.y / FULLSCREEN_DESIGN_SIZE.y)
	scale = Vector2(fit_scale, fit_scale)
	position = (viewport_size - FULLSCREEN_DESIGN_SIZE * fit_scale) * 0.5


func _ready() -> void:
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)
	Global.is_in_ldl = true
	add_qh_jm()


func _on_hc_pressed() -> void:
	MLdl.loc_ = "合成"
	remove_xq_jm()
	remove_qh_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_cg_jm()
	remove_onekey_jm()
	add_hc_jm()


func _on_qh_pressed() -> void:
	MLdl.loc_ = "强化"
	remove_xq_jm()
	remove_hc_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_cg_jm()
	remove_onekey_jm()
	add_qh_jm()


func _on_xq_pressed() -> void:
	if PlayerData.player_data["南天王殿"] == 1:
		MLdl.loc_ = "镶嵌"
		remove_qh_jm()
		remove_hc_jm()
		remove_fj_jm()
		remove_dz_jm()
		remove_sz_jm()
		remove_cg_jm()
		remove_onekey_jm()
		add_xq_jm()
	else:
		Global.add_message_show(Global.Windows_, "通关南天门后开启镶嵌功能！", 1.5, Vector2(470, 285))


func _on_return_pressed() -> void:
	MLdl.loc_ = "强化"
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_cg_jm()
	remove_onekey_jm()
	Global.is_in_ldl = false
	queue_free()


func add_qh_jm():
	MLdl.loc_ = "强化"
	if Strength_ == null:
		Strength_ = Global.add_strength(bg_2, Vector2(-315, -205))
		MemoryClass.save_game(Global.cd_path)
		Strength_.remove_infomation()


func remove_qh_jm():
	if Strength_ != null:
		Strength_.remove_infomation()
		MemoryClass.save_game(Global.cd_path)
		Strength_.queue_free()


func add_hc_jm():
	MLdl.loc_ = "合成"
	if Synthesis_ == null:
		Synthesis_ = Global.add_synthesis(bg_2, Vector2(-315, -205))


func remove_hc_jm():
	if Synthesis_ != null:
		Synthesis_.remove_infomation()
		MemoryClass.save_game(Global.cd_path)
		Synthesis_.queue_free()


func add_xq_jm():
	MLdl.loc_ = "镶嵌"
	if Mosaic_ == null:
		Mosaic_ = Global.add_mosaic_(bg_2, Vector2(-315, -205))


func remove_xq_jm():
	if Mosaic_ != null:
		Mosaic_.remove_infomation()
		MemoryClass.save_game(Global.cd_path)
		Mosaic_.queue_free()


func _on_hh_pressed() -> void:
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_cg_jm()
	remove_onekey_jm()
	Global.add_h_hjm(self, Vector2(0, 0))


func _on_fj_pressed() -> void:
	MLdl.loc_ = "分解"
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_cg_jm()
	remove_onekey_jm()
	add_fj_jm()


func add_fj_jm():
	MLdl.loc_ = "分解"
	if Decompose_ == null:
		Decompose_ = Global.add_decompose_(bg_2, Vector2(-305, -200))


func remove_fj_jm():
	if Decompose_ != null:
		Decompose_.remove_infomation()
		MemoryClass.save_game(Global.cd_path)
		Decompose_.queue_free()


func _on_dz_pressed() -> void:
	MLdl.loc_ = "打造"
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_fj_jm()
	remove_sz_jm()
	remove_cg_jm()
	remove_onekey_jm()
	add_dz_jm()


func add_dz_jm():
	MLdl.loc_ = "打造"
	if Forge_ == null:
		Forge_ = Global.add_forges(bg_2, Vector2(-340, -200))


func remove_dz_jm():
	if Forge_ != null:
		Forge_.remove_infomation()
		MemoryClass.save_game(Global.cd_path)
		Forge_.queue_free()


func _on_yjdy_pressed() -> void:
	MLdl.loc_ = "一键合成"
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_cg_jm()
	add_onekey_jm()


func _on_sz_pressed() -> void:
	MLdl.loc_ = "神铸"
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_onekey_jm()
	remove_cg_jm()
	add_sz_jm()


func add_sz_jm() -> void:
	MLdl.loc_ = "神铸"
	if DivineForge_ == null:
		var scene := preload("res://Scene/ldl/divine_forge.tscn")
		DivineForge_ = scene.instantiate()
		bg_2.add_child(DivineForge_)
		DivineForge_.position = Vector2(-315, -205)
		DivineForge_.remove_infomation()


func _on_cg_pressed() -> void:
	MLdl.loc_ = "淬骨"
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_onekey_jm()
	main_backpack.current_fl = 0
	main_backpack.current_page = 1
	main_backpack.set_box_data()
	add_cg_jm()


func add_cg_jm() -> void:
	if BoneForge_ != null:
		return
	var scene := preload("res://Scene/ldl/bone_forge.tscn")
	BoneForge_ = scene.instantiate()
	bg_2.add_child(BoneForge_)
	BoneForge_.position = Vector2(-315, -205)
	BoneForge_.remove_infomation()


func remove_cg_jm() -> void:
	if is_instance_valid(BoneForge_):
		BoneForge_.remove_infomation()
		BoneForge_.queue_free()
	BoneForge_ = null


func remove_sz_jm() -> void:
	if is_instance_valid(DivineForge_):
		DivineForge_.remove_infomation()
		MemoryClass.save_game(Global.cd_path)
		DivineForge_.queue_free()
	DivineForge_ = null


func add_onekey_jm():
	if OneKeySyn_ == null:
		var scene = preload("res://Scene/ldl/one_key_synthesis.tscn")
		OneKeySyn_ = scene.instantiate()
		bg_2.add_child(OneKeySyn_)
		OneKeySyn_.position = Vector2(-315, -205)


func remove_onekey_jm():
	if OneKeySyn_ != null:
		OneKeySyn_.queue_free()
		OneKeySyn_ = null

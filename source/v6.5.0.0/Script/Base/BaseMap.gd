extends CanvasLayer

var playerData = PlayerData
var MaxPage: int = 1
var tree: SceneTree
var userGlobal = Global.userGlobal


func _ready() -> void:
	tree = get_tree()
	userGlobal = Global.userGlobal
	playerData = PlayerData

	if userGlobal.CurLevel != null:
		userGlobal.CurLevel.queue_free()
		userGlobal.CurLevel = null

	Global.LLBTLevel = 1
	Global.LLBTBOSSMS = false
	Global.LLBTCGMS = false
	Global.LLBTWXMS = false
	Global.CurrentLevel = ""
	Global.PlayerBeHitCount = 0
	Global.LastLevelPath = ""
	Global.FB_CD = 0
	tree.paused = false
	PlayerData.player_data["Map_num"] = MaxPage

	if int(MainSet.set_data.get("CurrentLevelPage", 0)) <= MaxPage:
		MainSet.set_data["CurrentLevelPage"] = MaxPage
		MemoryClass.main_bc()

	if MainMusic.MyMainMusic == null:
		MainMusic.ADDMusic()

	for i in range(11):
		PlayAn(i)
	check_pass_level()
	_set_transition_overlay_visible(not OS.has_feature("windows"))


func PlayAn(_level: int) -> void:
	pass


func check_pass_level() -> void:
	pass


func _set_transition_overlay_visible(visible_state: bool) -> void:
	var color_rect := get_node_or_null("ColorRect")
	if color_rect != null:
		color_rect.visible = visible_state
	var color_rect_2 := get_node_or_null("ColorRect2")
	if color_rect_2 != null:
		color_rect_2.visible = visible_state

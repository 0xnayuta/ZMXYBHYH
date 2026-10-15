extends Node2D

const MONSTER_SCENE: = preload("res://Scene/Monster/EastContinentMonster.tscn")
const BACKGROUND: = preload("res://Art/Level/Game4Level/Imported/maps/aolaiguo_bossV1/background/bg10.png")
const ATLAS_MANIFEST: = "res://Art/Monster/SwfPng/3136/atlas/manifest.json"
const SCREENSHOT_PATH: = "user://aolaiguo_boss_visual_probe.png"
const ROOM_CENTER_X: = 576.0
const FLOOR_Y: = 448.0

var _failed: = false

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	MainSet.set_data["MonsterBloodSHow"] = false
	var background: = Sprite2D.new()
	background.texture = BACKGROUND
	background.position = Vector2(ROOM_CENTER_X, 300.0)
	add_child(background)

	var boss: = MONSTER_SCENE.instantiate() as EastContinentMonster
	boss.monster_kind = 3136
	boss._runtime_config = Level65.LEVEL_65_MONSTER_DATA[3136].duplicate(true)
	boss.position = Vector2(ROOM_CENTER_X, FLOOR_Y)
	add_child(boss)
	boss.set_physics_process(false)
	await get_tree().process_frame

	var visual_center_y: = boss.position.y + boss.mr_ani.position.y
	_check(absf(visual_center_y - 177.0) <= 0.51, "阵眼未对齐壁画中央")
	var body_bottom: = boss.position.y + boss.pz.position.y + 45.0
	_check(absf(body_bottom - FLOOR_Y) <= 0.51, "阵眼战斗碰撞未落地")

	var effect: = WutaiMinghaiProjectile.new()
	var pillar_anchor: = MonsterAtlasSequence.sequence_registration_anchor(
		ATLAS_MANIFEST, "effect1_1"
	)
	effect.configure({
		"owner": boss, 
		"position": Vector2(300.0, FLOOR_Y - pillar_anchor.y), 
		"right": true, 
		"hit_name": "hit1", 
		"attack_data": boss._attack_entry(&"hit1"), 
		"skill_name": "AolaiguoArrayPillar", 
		"atlas_manifest": ATLAS_MANIFEST, 
		"atlas_sequence": "effect1_1", 
		"frame_fps": 30.0, 
		"loop_visual": false, 
		"lifetime": 2.0, 
		"damage_enabled": false, 
	})
	boss.bullet.add_child(effect)
	await get_tree().create_timer(0.28, false).timeout
	await RenderingServer.frame_post_draw

	var image: = get_viewport().get_texture().get_image()
	var screenshot_path: = ProjectSettings.globalize_path(SCREENSHOT_PATH)
	_check(image != null and image.save_png(screenshot_path) == OK, "无法保存傲来国 Boss 截图")
	if not _failed:
		print("AOLAIGUO_BOSS_VISUAL_PROBE_OK center=177 body_floor=448 screenshot=" + screenshot_path)
	get_tree().quit(1 if _failed else 0)

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("AOLAIGUO_BOSS_VISUAL_PROBE_FAIL " + message)

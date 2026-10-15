extends Node2D

const MONSTER_SCENE: = preload("res://Scene/Monster/EastContinentMonster.tscn")
const SCREENSHOT_PATH: = "user://east_continent_3121_visual_probe.png"
const FLOOR_Y: = 430.0

var _failed: = false

func _ready() -> void :
	RenderingServer.set_default_clear_color(Color("172331"))
	queue_redraw()
	call_deferred("_run")

func _draw() -> void :
	draw_rect(Rect2(0, 0, 1152, 648), Color("172331"))
	draw_line(Vector2(0, FLOOR_Y), Vector2(1152, FLOOR_Y), Color("f3c969"), 2.0)

func _run() -> void :
	MainSet.set_data["MonsterBloodSHow"] = false
	var flower: = _spawn_monster(3121, Vector2(800, FLOOR_Y))
	var caterpillar: = _spawn_monster(3122, Vector2(240, FLOOR_Y))
	var boss: = _spawn_monster(3123, Vector2(520, FLOOR_Y))
	await get_tree().process_frame

	_check_foot(caterpillar, 3122)
	_check_foot(boss, 3123)
	flower.attack_target()
	await get_tree().create_timer(0.82, false).timeout

	var projectiles: Array[WutaiMinghaiProjectile] = []
	for child: Node in flower.bullet.get_children():
		if child is WutaiMinghaiProjectile and child.skill_name == "FlowerArrow1":
			projectiles.append(child as WutaiMinghaiProjectile)
	_check(projectiles.size() == 4, "3121 should spawn four arrow1 projectiles")
	var expected: Array[Vector2] = [
		Vector2(240.0 / sqrt(2.0), -240.0 / sqrt(2.0)), 
		Vector2(0.0, -240.0), 
		Vector2(-240.0 / sqrt(2.0), -240.0 / sqrt(2.0)), 
		Vector2(-240.0, 0.0), 
	]
	for velocity: Vector2 in expected:
		_check(_contains_velocity(projectiles, velocity), "missing arrow velocity %s" % velocity)

	await RenderingServer.frame_post_draw
	var image: = get_viewport().get_texture().get_image()
	var screenshot_path: = ProjectSettings.globalize_path(SCREENSHOT_PATH)
	_check(image != null and image.save_png(screenshot_path) == OK, "cannot save screenshot")
	if not _failed:
		print("EAST_3121_VISUAL_PROBE_OK arrows=4 feet=3122,3123 screenshot=" + screenshot_path)
	get_tree().quit(1 if _failed else 0)

func _spawn_monster(kind: int, spawn_position: Vector2) -> EastContinentMonster:
	var monster: = MONSTER_SCENE.instantiate() as EastContinentMonster
	monster.monster_kind = kind
	monster.position = spawn_position
	add_child(monster)
	monster.set_physics_process(false)
	return monster

func _check_foot(monster: EastContinentMonster, kind: int) -> void :
	var anchor: = MonsterAtlasSequence.sequence_registration_anchor(
		MonsterAtlasSequence.manifest_for_model(kind), "wait"
	)
	var visible_bottom: = monster.position.y + monster.mr_ani.position.y + anchor.y
	_check(absf(visible_bottom - FLOOR_Y) <= 0.51, "%d visible bottom is %s" % [kind, visible_bottom])

func _contains_velocity(projectiles: Array[WutaiMinghaiProjectile], expected: Vector2) -> bool:
	for projectile: WutaiMinghaiProjectile in projectiles:
		if projectile.motion_velocity.is_equal_approx(expected):
			return true
	return false

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("EAST_3121_VISUAL_PROBE_FAIL " + message)

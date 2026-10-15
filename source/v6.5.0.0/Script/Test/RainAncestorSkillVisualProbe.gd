extends Node2D

const MONSTER_SCENE: = preload("res://Scene/Monster/EastContinentMonster.tscn")
const FLOOR_Y: = 563.0
const OUTPUT_PREFIX: = "user://rain_ancestor_skill_"

var _boss: EastContinentMonster
var _failed: = false
var _old_source_player: Variant

func _ready() -> void :
	RenderingServer.set_default_clear_color(Color("10201d"))
	_old_source_player = RoleProp.SourcePlayer
	queue_redraw()
	call_deferred("_run")

func _draw() -> void :
	draw_rect(Rect2(0, 0, 1152, 648), Color("10201d"))
	draw_rect(Rect2(0, FLOOR_Y, 1152, 85), Color("25372f"))
	draw_line(Vector2(0, FLOOR_Y), Vector2(1152, FLOOR_Y), Color("7da47f"), 2.0)

func _run() -> void :
	MainSet.set_data["MonsterBloodSHow"] = false
	RoleProp.set_physics_process(false)
	var target: = Node2D.new()
	target.position = Vector2(260.0, 520.0)
	add_child(target)
	RoleProp.SourcePlayer = target

	_boss = MONSTER_SCENE.instantiate() as EastContinentMonster
	_boss.monster_kind = 3182
	_boss._runtime_config = Level68.LEVEL_68_MONSTER_DATA[3182].duplicate(true)
	_boss.position = Vector2(850.0, FLOOR_Y)
	add_child(_boss)
	_boss.set_physics_process(false)
	await get_tree().process_frame

	await _show_action(&"hit1", 1.1, "hit1")

	_begin_skill(&"hit2")
	await get_tree().create_timer(0.75, false).timeout
	_check(_count_skill("RainAncestorRainNeedle") == 1, "first tracking needle did not spawn")
	var rain_needle: = _first_skill("RainAncestorRainNeedle")
	_check(rain_needle != null and not rain_needle.track_target, "rain needle still sticks to its target")
	await _capture("hit2")
	await get_tree().create_timer(0.7, false).timeout
	_check(_count_skill("RainAncestorRainNeedle") == 2, "second tracking needle did not spawn")
	await _clear_skill_nodes()

	_begin_skill(&"hit3")
	await get_tree().create_timer(1.36, false).timeout
	_check(_count_skill("RainAncestorBoneCharge") == 4, "four bone charge points did not spawn")
	await _capture("hit3_charge")
	await get_tree().create_timer(0.72, false).timeout
	_check(_count_skill("RainAncestorBoneNeedle") >= 2, "bone needles did not launch")
	var bone_needle: = _first_skill("RainAncestorBoneNeedle")
	if bone_needle != null:
		var expected_rotation: = bone_needle.motion_velocity.angle() + PI
		_check(is_equal_approx(bone_needle.middle.rotation, expected_rotation), "bone needle visual direction is reversed")
	await _capture("hit3_fire")
	await _clear_skill_nodes()

	_begin_skill(&"hit5")
	await get_tree().create_timer(0.8, false).timeout
	await _capture("hit5")
	await get_tree().create_timer(1.3, false).timeout
	_check(_boss.mr_player.current_animation == &"hit4", "black mist did not chain into rain")
	_check(_count_weather() == 1, "rain weather did not spawn")
	await _capture("hit4_rain")

	RoleProp.SourcePlayer = _old_source_player
	if not _failed:
		print("RAIN_ANCESTOR_VISUAL_PROBE_OK needles=2 bones=4 rain=50 output=" + ProjectSettings.globalize_path(OUTPUT_PREFIX))
	get_tree().quit(1 if _failed else 0)

func _show_action(action: StringName, wait_time: float, output_name: String) -> void :
	_begin_skill(action)
	await get_tree().create_timer(wait_time, false).timeout
	await _capture(output_name)
	await _clear_skill_nodes()

func _begin_skill(action: StringName) -> void :
	_boss._attack_serial += 1
	_boss._disable_attack_box()
	_boss._play_frames(action)
	_boss.mr_player.play(action)
	_boss._start_3182_attack(action, _boss._attack_serial)

func _count_skill(skill_name: String) -> int:
	var count: = 0
	for child: Node in _boss.bullet.get_children():
		if child is WutaiMinghaiProjectile and child.skill_name == skill_name:
			count += 1
	return count

func _first_skill(skill_name: String) -> WutaiMinghaiProjectile:
	for child: Node in _boss.bullet.get_children():
		if child is WutaiMinghaiProjectile and child.skill_name == skill_name:
			return child as WutaiMinghaiProjectile
	return null

func _count_weather() -> int:
	var count: = 0
	for child: Node in get_children():
		if child is RainAncestorWeather:
			count += 1
	for child: Node in _boss.bullet.get_children():
		if child is RainAncestorWeather:
			count += 1
	return count

func _clear_skill_nodes() -> void :
	_boss._attack_serial += 1
	_boss._special_attack_active = false
	for child: Node in _boss.bullet.get_children():
		child.queue_free()
	await get_tree().process_frame

func _capture(output_name: String) -> void :
	await RenderingServer.frame_post_draw
	var image: = get_viewport().get_texture().get_image()
	var path: = ProjectSettings.globalize_path(OUTPUT_PREFIX + output_name + ".png")
	_check(image != null and image.save_png(path) == OK, "cannot save " + output_name)

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("RAIN_ANCESTOR_VISUAL_PROBE_FAIL " + message)

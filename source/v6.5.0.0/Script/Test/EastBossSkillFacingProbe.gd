extends Node2D

const MONSTER_SCENE: = preload("res://Scene/Monster/EastContinentMonster.tscn")
const MONSTER_IDS: = [3223, 3277]
const OUTPUT_PATH: = "res://.tmp/east_boss_skill_facing.png"

var _failed: = false


func _ready() -> void :
	call_deferred("_run")


func _run() -> void :
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	MainSet.set_data["NoShowMonsterBody"] = true
	var background: = ColorRect.new()
	background.color = Color("17212b")
	background.size = Vector2(1152.0, 648.0)
	background.z_index = -100
	add_child(background)

	for monster_index in MONSTER_IDS.size():
		var monster_id: int = MONSTER_IDS[monster_index]
		var monster: = MONSTER_SCENE.instantiate() as EastContinentMonster
		monster.monster_kind = monster_id
		add_child(monster)
		await get_tree().process_frame
		monster.set_process(false)
		monster.set_physics_process(false)
		_check_collision_geometry(monster)
		_check_action_registration(monster)
		_check_skill_artwork(monster)
		_add_action_previews(monster, monster_index)
		monster.queue_free()
		await get_tree().process_frame

	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tmp"))
	var image: = get_viewport().get_texture().get_image()
	var screenshot_path: = ProjectSettings.globalize_path(OUTPUT_PATH)
	_check(
		image != null and image.save_png(screenshot_path) == OK, 
		"cannot save facing screenshot"
	)
	if not _failed:
		print("EAST_BOSS_SKILL_FACING_PROBE_OK bosses=3223,3277 screenshot=" + screenshot_path)
	get_tree().quit(1 if _failed else 0)


func _check_collision_geometry(monster: EastContinentMonster) -> void :
	var expected: Dictionary = EastContinentMonster.ENTITY_COLLISION_BOXES[monster.monster_kind]
	var hurt_shape: = monster.hurt_box.shape as RectangleShape2D
	var body_shape: = monster.pz.shape as RectangleShape2D
	_check(hurt_shape != null, "monster %d hurt shape" % monster.monster_kind)
	_check(body_shape != null, "monster %d body shape" % monster.monster_kind)
	if hurt_shape != null:
		_check(
			hurt_shape.size.is_equal_approx(expected["hurt_size"] as Vector2), 
			"monster %d hurt size" % monster.monster_kind
		)
	if body_shape != null:
		_check(
			body_shape.size.is_equal_approx(expected["body_size"] as Vector2), 
			"monster %d body size" % monster.monster_kind
		)
	_check(
		monster.hurt_box.position.is_equal_approx(expected["hurt_position"] as Vector2), 
		"monster %d hurt point" % monster.monster_kind
	)
	_check(
		monster.pz.position.is_equal_approx(expected["body_position"] as Vector2), 
		"monster %d hit flash point" % monster.monster_kind
	)


func _check_action_registration(monster: EastContinentMonster) -> void :
	var manifest: = monster._manifest_path()
	var wait_anchor: = MonsterAtlasSequence.sequence_registration_anchor(manifest, "wait")
	for attack_name: StringName in [&"hit1", &"hit2", &"hit3"]:
		var action_anchor: = MonsterAtlasSequence.sequence_registration_anchor(
			manifest, str(attack_name)
		)
		var raw_delta: = action_anchor - wait_anchor
		monster._play_frames(attack_name)
		var expected_x: = raw_delta.x
		_check(
			is_equal_approx(monster.mr_ani.position.x, expected_x), 
			"monster %d %s mirrored registration" % [monster.monster_kind, attack_name]
		)
		for facing_scale: float in [-1.0, 1.0]:
			monster.monster_dir.scale.x = facing_scale
			var world_offset: = monster.monster_dir.to_global(monster.mr_ani.position)\
			- monster.monster_dir.global_position
			_check(
				signf(world_offset.x) == signf(expected_x * facing_scale)\
				or is_zero_approx(expected_x), 
				"monster %d %s facing %s" % [
					monster.monster_kind, attack_name, facing_scale, 
				]
			)


func _check_skill_artwork(monster: EastContinentMonster) -> void :
	var manifest: = monster._manifest_path()
	var wait_geometry: = MonsterAtlasSequence.frame_geometry(manifest, "wait", 0)
	var wait_area: float = (wait_geometry["size"] as Vector2).x\
	* (wait_geometry["size"] as Vector2).y
	for attack_name: StringName in [&"hit1", &"hit2", &"hit3"]:
		var frame_count: = MonsterAtlasSequence.sequence_frame_count(manifest, str(attack_name))
		var max_area: = 0.0
		for frame_index in range(frame_count):
			var geometry: = MonsterAtlasSequence.frame_geometry(
				manifest, str(attack_name), frame_index
			)
			if not bool(geometry.get("has_visual", false)):
				continue
			var size: = geometry["size"] as Vector2
			max_area = maxf(max_area, size.x * size.y)
		_check(
			max_area > wait_area * 1.05, 
			"monster %d %s has no visible attack effect" % [
				monster.monster_kind, attack_name, 
			]
		)
	if monster.monster_kind == 3277:
		_check(
			MonsterAtlasSequence.frame_geometry(manifest, "effect2_1", 0).get(
				"has_visual", false
			), 
			"monster 3277 lightning visual"
		)


func _add_action_previews(monster: EastContinentMonster, row: int) -> void :
	var manifest: = monster._manifest_path()
	for attack_index in range(3):
		var attack_name: = StringName("hit%d" % (attack_index + 1))
		var frame_index: = _largest_visual_frame(manifest, str(attack_name))
		monster._play_frames(attack_name)
		monster.mr_ani.frame = frame_index
		var texture: = monster.mr_ani.sprite_frames.get_frame_texture(attack_name, frame_index)
		for facing_index in range(2):
			var column: = attack_index * 2 + facing_index
			var cell_origin: = Vector2(float(column) * 192.0, float(row) * 315.0)
			var baseline_y: = cell_origin.y + 287.0
			var line: = Line2D.new()
			line.width = 1.0
			line.default_color = Color("64778a")
			line.points = PackedVector2Array([
				Vector2(cell_origin.x + 8.0, baseline_y), 
				Vector2(cell_origin.x + 184.0, baseline_y), 
			])
			add_child(line)

			var preview_root: = Node2D.new()
			preview_root.position = Vector2(cell_origin.x + 96.0, baseline_y)
			var texture_size: = texture.get_size()
			var fit_scale: = minf(1.0, minf(176.0 / texture_size.x, 250.0 / texture_size.y))
			preview_root.scale = Vector2(
				fit_scale * (-1.0 if facing_index == 1 else 1.0), fit_scale
			)
			add_child(preview_root)
			var sprite: = Sprite2D.new()
			sprite.texture = texture
			sprite.centered = true
			sprite.flip_h = monster.mr_ani.flip_h
			sprite.position = monster.mr_ani.position
			preview_root.add_child(sprite)

			var label: = Label.new()
			label.text = "%d %s %s" % [
				monster.monster_kind, attack_name, 
				"R" if facing_index == 1 else "L", 
			]
			label.position = cell_origin + Vector2(8.0, 5.0)
			label.add_theme_color_override("font_color", Color("e7edf3"))
			label.add_theme_font_size_override("font_size", 14)
			add_child(label)


func _largest_visual_frame(manifest: String, sequence: String) -> int:
	var result: = 0
	var max_area: = 0.0
	var frame_count: = MonsterAtlasSequence.sequence_frame_count(manifest, sequence)
	for frame_index in range(frame_count):
		var geometry: = MonsterAtlasSequence.frame_geometry(manifest, sequence, frame_index)
		if not bool(geometry.get("has_visual", false)):
			continue
		var size: = geometry["size"] as Vector2
		var area: = size.x * size.y
		if area > max_area:
			max_area = area
			result = frame_index
	return result


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("EAST_BOSS_SKILL_FACING_PROBE_FAIL " + message)

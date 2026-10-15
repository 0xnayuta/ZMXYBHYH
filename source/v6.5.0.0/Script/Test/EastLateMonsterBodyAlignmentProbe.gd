extends Node

const MonsterAtlasSequence = preload("res://Script/Monster/MonsterAtlasSequence.gd")
const OUTPUT_PATH: = "res://.tmp/east_late_monster_body_alignment.png"
const CELL_SIZE: = Vector2(230.0, 210.0)
const PREVIEW_SIZE: = Vector2(190.0, 155.0)
const MONSTER_IDS: = [
	3198, 3199, 3200, 3201, 3222, 3223, 3276, 3277, 
	3308, 3309, 3310, 3320, 3323, 3343, 3352, 
]
const EXPECTED_WAIT_OFFSETS: = {
	3198: -41.5, 3199: -50.0, 3200: -55.0, 3201: -49.5, 
	3222: -46.0, 3223: -69.5, 3276: -48.0, 3277: -223.5, 
	3308: -46.0, 3309: -45.0, 3310: -69.0, 3320: -62.5, 
	3323: -76.5, 3343: -273.0, 3352: -160.0, 
}


func _init() -> void :
	call_deferred("_run")


func _run() -> void :
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	MainSet.set_data["NoShowMonsterBody"] = true

	var background: = ColorRect.new()
	background.color = Color("17212b")
	background.position = Vector2.ZERO
	background.size = Vector2(1152.0, 648.0)
	add_child(background)

	for monster_index in MONSTER_IDS.size():
		var monster_id: int = MONSTER_IDS[monster_index]
		var manifest: = MonsterAtlasSequence.manifest_for_model(monster_id)
		if manifest.is_empty():
			_fail("monster %d manifest" % monster_id)
			return
		var wait_anchor: = MonsterAtlasSequence.sequence_registration_anchor(manifest, "wait")
		var expected_offset: = float(EXPECTED_WAIT_OFFSETS[monster_id])
		if not is_equal_approx( - wait_anchor.y, expected_offset):
			_fail("monster %d source offset %.2f" % [monster_id, - wait_anchor.y])
			return

		var packed: = load("res://Scene/Monster/Monster_%d.tscn" % monster_id) as PackedScene
		var monster: = packed.instantiate() as EastContinentMonster if packed != null else null
		if monster == null:
			_fail("monster %d scene" % monster_id)
			return
		add_child(monster)
		await get_tree().process_frame
		var sprite: = monster.get_node_or_null("MonsterDir/mr_ani") as AnimatedSprite2D
		if sprite == null:
			monster.queue_free()
			_fail("monster %d sprite" % monster_id)
			return
		if not is_equal_approx(sprite.position.y, expected_offset):
			var actual_offset: = sprite.position.y
			monster.queue_free()
			_fail("monster %d runtime offset %.2f" % [monster_id, actual_offset])
			return
		if absf(sprite.position.y + wait_anchor.y) > 0.01:
			monster.queue_free()
			_fail("monster %d wait baseline" % monster_id)
			return
		_add_preview(monster_index, monster_id, sprite)
		monster.queue_free()
		await get_tree().process_frame

	await get_tree().process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tmp"))
	var image: = get_viewport().get_texture().get_image()
	var output_path: = ProjectSettings.globalize_path(OUTPUT_PATH)
	if image == null or image.save_png(output_path) != OK:
		_fail("screenshot")
		return
	print("EAST_LATE_MONSTER_BODY_ALIGNMENT_OK monsters=%d yellow_brow_offset=%.1f screenshot=%s" % [
		MONSTER_IDS.size(), float(EXPECTED_WAIT_OFFSETS[3223]), output_path, 
	])
	get_tree().quit(0)


func _add_preview(index: int, monster_id: int, source: AnimatedSprite2D) -> void :
	var texture: = source.sprite_frames.get_frame_texture(&"wait", 0)
	if texture == null:
		return
	var column: = index % 5
	var row: = index / 5
	var cell_origin: = Vector2(float(column) * CELL_SIZE.x, float(row) * CELL_SIZE.y)
	var baseline_y: = cell_origin.y + CELL_SIZE.y - 28.0

	var baseline: = Line2D.new()
	baseline.width = 1.0
	baseline.default_color = Color("64778a")
	baseline.points = PackedVector2Array([
		Vector2(cell_origin.x + 12.0, baseline_y), 
		Vector2(cell_origin.x + CELL_SIZE.x - 12.0, baseline_y), 
	])
	add_child(baseline)

	var visual_root: = Node2D.new()
	visual_root.position = Vector2(cell_origin.x + CELL_SIZE.x * 0.5, baseline_y)
	var texture_size: = texture.get_size()
	var preview_scale: = minf(
		1.0, 
		minf(PREVIEW_SIZE.x / maxf(texture_size.x, 1.0), PREVIEW_SIZE.y / maxf(texture_size.y, 1.0))
	)
	visual_root.scale = Vector2(preview_scale, preview_scale)
	add_child(visual_root)

	var preview: = Sprite2D.new()
	preview.texture = texture
	preview.centered = true
	preview.flip_h = source.flip_h
	preview.position = source.position
	visual_root.add_child(preview)

	var label: = Label.new()
	label.text = "%d  offset %.1f" % [monster_id, float(EXPECTED_WAIT_OFFSETS[monster_id])]
	label.position = cell_origin + Vector2(12.0, 5.0)
	label.add_theme_color_override("font_color", Color("e7edf3"))
	label.add_theme_font_size_override("font_size", 15)
	add_child(label)


func _fail(reason: String) -> void :
	push_error("EAST_LATE_MONSTER_BODY_ALIGNMENT_FAIL " + reason)
	get_tree().quit(1)

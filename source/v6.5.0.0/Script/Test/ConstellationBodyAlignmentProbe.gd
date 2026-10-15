extends SceneTree

const MonsterAtlasSequence = preload("res://Script/Monster/MonsterAtlasSequence.gd")
const BodyStreamScript = preload("res://Script/Monster/ConstellationBodyStream.gd")
const SOURCE_IDS: = [140, 142, 144, 146, 147, 149, 150, 151, 152, 156, 157, 158, 159, 162]
const CANVAS_SIZES: = {
	140: Vector2i(250, 250), 142: Vector2i(250, 250), 144: Vector2i(300, 300), 
	146: Vector2i(250, 250), 147: Vector2i(250, 250), 149: Vector2i(300, 300), 
	150: Vector2i(250, 250), 151: Vector2i(250, 250), 152: Vector2i(250, 250), 
	156: Vector2i(250, 250), 157: Vector2i(220, 220), 158: Vector2i(250, 250), 
	159: Vector2i(250, 250), 162: Vector2i(250, 250), 
}
const BODY_OFFSETS: = {
	140: Vector2(10, -15), 142: Vector2(10, -10), 144: Vector2(10, -35), 
	146: Vector2(10, -15), 147: Vector2(5, -22), 149: Vector2(5, -22), 
	150: Vector2(15, -12), 151: Vector2(10, -15), 152: Vector2(10, -8), 
	156: Vector2(0, -5), 157: Vector2.ZERO, 158: Vector2.ZERO, 
	159: Vector2(0, -20), 162: Vector2(0, -10), 
}


func _init() -> void :
	call_deferred("_run")


func _run() -> void :
	var boss_scene: = load("res://Scene/Monster/ConstellationBossBase.tscn") as PackedScene
	if boss_scene == null:
		_fail("scene load")
		return
	var boss: = boss_scene.instantiate()
	var pz: = boss.get_node_or_null("pz") as CollisionShape2D
	var hurt_box: = boss.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if not _is_official_collision(pz) or not _is_official_collision(hurt_box):
		boss.free()
		_fail("collision geometry")
		return
	if pz.position != Vector2.ZERO or hurt_box.position != Vector2.ZERO:
		var registration_error: = "collision registration pz=%s hurt=%s" % [
			pz.position, hurt_box.position, 
		]
		boss.free()
		_fail(registration_error)
		return
	boss.free()

	var stream: = BodyStreamScript.new() as StreamedPngEffect
	var source_paths: Array[String] = [
		"res://Art/Constellations/Boss/140/body/1/1.png", 
		"res://Art/Constellations/Boss/140/body/1/2.png", 
	]
	if not MonsterAtlasSequence.configure_stream_for_paths(stream, source_paths):
		stream.free()
		_fail("body stream atlas mapping")
		return
	stream.manual_frame_control = true
	stream.auto_free = false
	root.add_child(stream)
	await process_frame
	var sprite: = stream.get("_sprite") as Sprite2D
	var first_texture: = sprite.texture as AtlasTexture if sprite != null else null
	if first_texture == null:
		stream.queue_free()
		_fail("body stream atlas texture")
		return
	var first_region: = first_texture.region
	stream.call("_show_frame", 1)
	var second_texture: = sprite.texture as AtlasTexture
	if second_texture == null or second_texture.region == first_region:
		stream.queue_free()
		_fail("body stream same-page frame advance")
		return
	stream.queue_free()
	await process_frame

	var minimum_delta: = INF
	var maximum_delta: = - INF
	for source_id: int in SOURCE_IDS:
		var path: = "res://Art/Constellations/Boss/%d/body/1/1.png" % source_id
		var geometry: = MonsterAtlasSequence.frame_geometry_for_source_path(path)
		if not bool(geometry.get("has_visual", false)):
			_fail("body frame %d" % source_id)
			return
		var frame_texture: = MonsterAtlasSequence.texture_for_source_path(path) as AtlasTexture
		if frame_texture == null:
			_fail("body atlas frame %d" % source_id)
			return
		var canvas: Vector2i = CANVAS_SIZES[source_id]
		var offset: Vector2 = BODY_OFFSETS[source_id]
		var used_bottom: = frame_texture.margin.position.y + frame_texture.region.size.y
		var clipped_bottom: = minf(used_bottom, float(canvas.y)) - 1.0
		var foot_y: = - float(canvas.y) * 0.5 + offset.y + clipped_bottom
		var delta_from_collision: = foot_y - 65.0
		minimum_delta = minf(minimum_delta, delta_from_collision)
		maximum_delta = maxf(maximum_delta, delta_from_collision)
		if delta_from_collision < -2.0 or delta_from_collision > 12.0:
			_fail("body registration %d delta=%s" % [source_id, delta_from_collision])
			return

	print(
		"CONSTELLATION_BODY_ALIGNMENT_OK bosses=%d foot_delta=%.1f..%.1f" % [
			SOURCE_IDS.size(), minimum_delta, maximum_delta, 
		]
	)
	quit(0)


func _is_official_collision(collision: CollisionShape2D) -> bool:
	if collision == null or not (collision.shape is RectangleShape2D):
		return false
	return (collision.shape as RectangleShape2D).size == Vector2(60, 130)


func _fail(reason: String) -> void :
	push_error("CONSTELLATION_BODY_ALIGNMENT_FAIL %s" % reason)
	quit(1)

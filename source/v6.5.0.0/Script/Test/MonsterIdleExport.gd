extends Node

const OUTPUT_DIR: = "C:/Users/Administrator/Desktop/造梦西游3/怪物立绘"
const VIEWPORT_SIZE: = Vector2i(2048, 2048)
const CROP_PADDING: = 16
const FALLBACK_IMAGES: = {
	"1460": "res://Art/Monster/Tongtian3057/preview.png", 
	"3006": "res://Art/Monster/SwfPng/3006/preview.png", 
	"3007": "res://Art/Monster/SwfPng/3007/preview.png", 
	"3012": "res://Art/Monster/SwfPng/3012/DefineSprite_21_idle/1.png", 
	"3021": "res://Art/Monster/SwfPng/3021/preview.png", 
	"3033": "res://Art/Monster/SwfPng/3033/preview.png", 
	"3034": "res://Art/Monster/SwfPng/3034/preview.png", 
	"3035": "res://Art/Monster/SwfPng/3035/preview.png", 
	"3040": "res://Art/Monster/SwfPng/3040/preview.png", 
	"3041": "res://Art/Monster/SwfPng/3041/preview.png", 
	"3042": "res://Art/Monster/SwfPng/3042/preview.png", 
	"3069": "res://Art/Monster/SwfPng/3069/preview.png", 
	"3070": "res://Art/Monster/SwfPng/3070/preview.png", 
}

var _failed: Array[String] = []

func _ready() -> void :
	call_deferred("_run_export")

func _run_export() -> void :
	var make_dir_error: = DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
	if make_dir_error != OK and not DirAccess.dir_exists_absolute(OUTPUT_DIR):
		push_error("无法创建输出目录：" + OUTPUT_DIR)
		get_tree().quit(1)
		return

	var scene_map: = _collect_monster_scenes("res://Scene/Monster")
	var ids: Array = scene_map.keys()
	ids.sort_custom( func(left, right): return int(left) < int(right))
	print("MONSTER_IDLE_EXPORT_TOTAL=" + str(ids.size()))

	var viewport: = SubViewport.new()
	viewport.size = VIEWPORT_SIZE
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.handle_input_locally = false
	add_child(viewport)
	var holder: = Node2D.new()
	viewport.add_child(holder)

	var exported: = 0
	for id in ids:
		var scene_path: = str(scene_map[id])
		if FALLBACK_IMAGES.has(str(id)) and _export_image(str(id), str(FALLBACK_IMAGES[str(id)])):
			exported += 1
			continue
		if await _export_scene(viewport, holder, str(id), scene_path):
			exported += 1

	print("MONSTER_IDLE_EXPORT_OK=" + str(exported))
	print("MONSTER_IDLE_EXPORT_FAILED=" + str(_failed.size()))
	for failure in _failed:
		print("MONSTER_IDLE_EXPORT_ERROR=" + failure)
	get_tree().quit(0 if _failed.is_empty() else 2)

func _collect_monster_scenes(root_path: String) -> Dictionary:
	var result: = {}
	_collect_monster_scenes_recursive(root_path, result)
	return result

func _collect_monster_scenes_recursive(directory_path: String, result: Dictionary) -> void :
	var directory: = DirAccess.open(directory_path)
	if directory == null:
		return
	directory.list_dir_begin()
	while true:
		var entry: = directory.get_next()
		if entry == "":
			break
		if entry.begins_with("."):
			continue
		var entry_path: = directory_path.path_join(entry)
		if directory.current_is_dir():
			_collect_monster_scenes_recursive(entry_path, result)
			continue
		if not entry.ends_with(".tscn"):
			continue
		var match : = RegEx.create_from_string("^Monster_(\\d+)(?:_[^.]+)?\\.tscn$").search(entry)
		if match == null:
			continue
		var monster_id: = match .get_string(1)
		var is_exact: = entry == "Monster_" + monster_id + ".tscn"
		if not result.has(monster_id) or is_exact:
			result[monster_id] = entry_path
	directory.list_dir_end()

func _export_image(monster_id: String, source_path: String) -> bool:
	var image: = Image.load_from_file(source_path)
	if image == null or image.is_empty():
		return false
	var used_rect: = image.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return false
	used_rect = used_rect.grow(CROP_PADDING).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var cropped: = image.get_region(used_rect)
	return cropped.save_png(OUTPUT_DIR.path_join(monster_id + ".png")) == OK

func _export_scene(viewport: SubViewport, holder: Node2D, monster_id: String, scene_path: String) -> bool:
	var packed: = load(scene_path) as PackedScene
	if packed == null:
		_failed.append(monster_id + "|场景加载失败|" + scene_path)
		return false
	var monster: = packed.instantiate()
	if monster == null:
		_failed.append(monster_id + "|场景实例化失败|" + scene_path)
		return false

	holder.add_child(monster)
	monster.position = Vector2(VIEWPORT_SIZE) * 0.5
	monster.process_mode = Node.PROCESS_MODE_DISABLED
	_prepare_visual_nodes(monster)
	var idle_animation: = _set_idle_animation(monster)
	if idle_animation == "" and monster.get_node_or_null("MonsterDir/SpineVisual") == null:
		holder.remove_child(monster)
		monster.free()
		_failed.append(monster_id + "|没有可用待机立绘|" + scene_path)
		return false

	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: = viewport.get_texture().get_image()
	if image == null:
		holder.remove_child(monster)
		monster.free()
		_failed.append(monster_id + "|视口截图失败|" + scene_path)
		return false
	var used_rect: = image.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		holder.remove_child(monster)
		monster.free()
		_failed.append(monster_id + "|待机帧为空|" + scene_path)
		return false
	used_rect = used_rect.grow(CROP_PADDING).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var cropped: = image.get_region(used_rect)
	var output_path: = OUTPUT_DIR.path_join(monster_id + ".png")
	var save_error: = cropped.save_png(output_path)
	holder.remove_child(monster)
	monster.free()
	await get_tree().process_frame
	if save_error != OK:
		_failed.append(monster_id + "|PNG保存失败|" + output_path)
		return false
	return true

func _prepare_visual_nodes(monster: Node) -> void :
	var monster_dir: = monster.get_node_or_null("MonsterDir")
	if monster_dir == null:
		return
	for child in monster_dir.get_children():
		if child.name not in ["mr_ani", "SpineVisual"] and child is CanvasItem:
			(child as CanvasItem).visible = false

func _set_idle_animation(monster: Node) -> String:
	var sprite: = monster.get_node_or_null("MonsterDir/mr_ani") as AnimatedSprite2D
	if sprite == null or sprite.sprite_frames == null:
		return ""
	var names: = sprite.sprite_frames.get_animation_names()
	var preferred: = ["wait", "Fly_wait", "idle", "fly_wait", "wait_1", "idle_1", "mc_idle", "mc_none"]
	for candidate in preferred:
		if candidate in names:
			sprite.stop()
			sprite.animation = candidate
			sprite.frame = 0
			sprite.frame_progress = 0.0
			sprite.visible = true
			return candidate
	for animation_name in names:
		var lower_name: = str(animation_name).to_lower()
		if lower_name.contains("death") or lower_name.contains("hit") or lower_name.contains("attack"):
			continue
		sprite.stop()
		sprite.animation = animation_name
		sprite.frame = 0
		sprite.frame_progress = 0.0
		sprite.visible = true
		return str(animation_name)
	return ""

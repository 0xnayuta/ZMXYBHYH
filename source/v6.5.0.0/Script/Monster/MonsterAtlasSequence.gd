extends RefCounted
class_name MonsterAtlasSequence

static var _manifest_cache: Dictionary = {}
static var _sprite_frames_cache: Dictionary = {}
static var _registry_cache: Dictionary = {}
static var _source_location_cache: Dictionary = {}
static var _entry_visual_cache: Dictionary = {}
static var _frame_geometry_cache: Dictionary = {}

static var _animation_bundle_cache: Dictionary = {}

static func get_animation_bundle(cache_key: String) -> Dictionary:
	var bundle: Dictionary = _animation_bundle_cache.get(cache_key, {})
	if not bundle.is_empty():
		_animation_bundle_cache.erase(cache_key)
		_animation_bundle_cache[cache_key] = bundle
	return bundle

static func store_animation_bundle(cache_key: String, bundle: Dictionary) -> void :
	var limit: = 8 if OS.has_feature("mobile") else 16
	_animation_bundle_cache.erase(cache_key)
	while _animation_bundle_cache.size() >= limit:
		_animation_bundle_cache.erase(_animation_bundle_cache.keys()[0])
	_animation_bundle_cache[cache_key] = bundle

const BULK_REGISTRY_PATH: = "res://Art/atlas_manifest_registry.json"
const MONSTER_ROOT: = "res://Art/Monster/SwfPng"
const MONSTER_RESOURCE_ALIASES: = {
	3178: 3159, 
	3183: 3177, 
	3126: 3119, 
	3145: 3121, 
	3146: 3122, 
}
const MONSTER_LOCATIONS: = {
	3019: "res://Art/Monster/SwfPng/3019", 
	3035: "res://Art/Monster/SwfPng/3035", 
	3037: "res://Art/Monster/SwfPng/3037", 
	3040: "res://Art/Monster/SwfPng/3040", 
	3041: "res://Art/Monster/SwfPng/3041", 
}

static func manifest_data(manifest_path: String) -> Dictionary:
	return _get_manifest(manifest_path)

static func has_sequence(manifest_path: String, sequence_name: String) -> bool:
	if manifest_path.is_empty() or not FileAccess.file_exists(manifest_path):
		return false
	var sequences: Dictionary = _get_manifest(manifest_path).get("sequences", {})
	return not _resolve_sequence_name(sequences, sequence_name).is_empty()

static func manifest_for_model(model_id: int) -> String:
	var resource_id: = int(MONSTER_RESOURCE_ALIASES.get(model_id, model_id))
	var model_root: = str(MONSTER_LOCATIONS.get(resource_id, "%s/%d" % [MONSTER_ROOT, resource_id]))
	var path: = model_root.path_join("atlas/manifest.json")
	return path if FileAccess.file_exists(path) else ""

static func model_root_for_model(model_id: int) -> String:
	var manifest_path: = manifest_for_model(model_id)
	return "" if manifest_path.is_empty() else manifest_path.get_base_dir().get_base_dir()

static func manifest_for_source_root(source_root: String) -> String:
	var match : = RegEx.create_from_string("/(?:Monster_|SwfPng/)(\\d+)(?:/|$)").search(source_root)
	if match == null:
		return ""
	return manifest_for_model(int(match .get_string(1)))

static func configure_stream(stream: StreamedPngEffect, manifest_path: String, sequence_name: String) -> bool:
	if manifest_path.is_empty() or not FileAccess.file_exists(manifest_path):
		return false
	var manifest: = _get_manifest(manifest_path)
	var sequences: Dictionary = manifest.get("sequences", {})
	var resolved_sequence_name: = _resolve_sequence_name(sequences, sequence_name)
	var sequence: Dictionary = sequences.get(resolved_sequence_name, {})
	var pages: Array = manifest.get("pages", [])
	var paths: Array[String] = []
	var regions: Array[Rect2] = []
	var margins: Array[Rect2] = []
	var visual_flags: Array[bool] = []
	for entry_value in sequence.get("frames", []):
		if not entry_value is Array:
			continue
		var entry: Array = entry_value
		if entry.size() < 10:
			continue
		var page_index: = int(entry[1])
		if page_index < 0 or page_index >= pages.size():
			continue
		var page: Dictionary = pages[page_index]
		paths.append(str(page.get("path", "")))
		regions.append(Rect2(float(entry[2]), float(entry[3]), float(entry[4]), float(entry[5])))
		margins.append(Rect2(float(entry[6]), float(entry[7]), float(entry[8]), float(entry[9])))
		visual_flags.append(_entry_has_visual(str(page.get("path", "")), entry))
	if paths.is_empty():
		push_error("Monster atlas sequence is missing: %s in %s" % [sequence_name, manifest_path])
		return false
	stream.frame_paths = paths
	stream.frame_regions = regions
	stream.frame_margins = margins
	stream.frame_has_visual = visual_flags
	return true

static func prewarm(manifest_path: String, page_count: int = 2) -> void :
	if manifest_path.is_empty() or not FileAccess.file_exists(manifest_path):
		return
	var manifest: = _get_manifest(manifest_path)
	var pages: Array = manifest.get("pages", [])
	var tree: = Engine.get_main_loop() as SceneTree
	for page_index in range(mini(maxi(page_count, 1), pages.size())):
		var page: Dictionary = pages[page_index]
		ResourceLoader.load(str(page.get("path", "")), "Texture2D", ResourceLoader.CACHE_MODE_REUSE)
		if tree != null:
			await tree.process_frame

static func sequence_frame_count(manifest_path: String, sequence_name: String) -> int:
	var manifest: = _get_manifest(manifest_path)
	var sequences: Dictionary = manifest.get("sequences", {})
	var resolved_sequence_name: = _resolve_sequence_name(sequences, sequence_name)
	var sequence: Dictionary = sequences.get(resolved_sequence_name, {})
	return Array(sequence.get("frames", [])).size()

static func sequence_registration_center(manifest_path: String, sequence_name: String) -> Vector2:
	var geometry: = frame_geometry(manifest_path, sequence_name, 0)
	return Vector2(geometry.get("center", Vector2.ZERO))

static func sequence_registration_anchor(manifest_path: String, sequence_name: String) -> Vector2:
	return frame_registration_anchor(manifest_path, sequence_name, 0)

static func frame_registration_anchor(
	manifest_path: String, sequence_name: String, frame_index: int
) -> Vector2:
	var manifest: = _get_manifest(manifest_path)
	var sequences: Dictionary = manifest.get("sequences", {})
	var resolved_sequence_name: = _resolve_sequence_name(sequences, sequence_name)
	var sequence: Dictionary = sequences.get(resolved_sequence_name, {})
	var frames: Array = sequence.get("frames", [])
	if frame_index < 0 or frame_index >= frames.size() or not frames[frame_index] is Array:
		return Vector2.ZERO
	var entry: Array = frames[frame_index]
	if entry.size() < 10:
		return Vector2.ZERO
	var used_size: = Vector2(float(entry[4]), float(entry[5]))
	var margin: = Rect2(float(entry[6]), float(entry[7]), float(entry[8]), float(entry[9]))



	var canvas_size: = used_size + margin.size
	var center_x: = margin.position.x + used_size.x * 0.5 - canvas_size.x * 0.5
	var bottom_y: = margin.position.y + used_size.y - canvas_size.y * 0.5
	return Vector2(center_x, bottom_y)

static func source_file_paths(source_root: String) -> Array[String]:
	var location: = _find_bundle(source_root)
	if location.is_empty():
		return []
	var bundle_root: = str(location.get("root", ""))
	var manifest_path: = str(location.get("manifest", ""))
	var sequence_name: = "." if source_root == bundle_root else source_root.trim_prefix(bundle_root + "/")
	var manifest: = _get_manifest(manifest_path)
	var sequences: Dictionary = manifest.get("sequences", {})
	var resolved_sequence_name: = _resolve_sequence_name(sequences, sequence_name)
	var sequence: Dictionary = sequences.get(resolved_sequence_name, {})
	var result: Array[String] = []
	for path_value in sequence.get("paths", []):
		result.append(str(path_value))
	return result

static func source_frame_count(source_root: String) -> int:
	return source_file_paths(source_root).size()

static func has_source_path(source_path: String) -> bool:
	return not _source_location(source_path).is_empty()

static func page_path_for_source_path(source_path: String) -> String:
	var location: = _source_location(source_path)
	return str(location.get("page_path", ""))

static func configure_stream_for_paths(stream: StreamedPngEffect, source_paths: Array[String]) -> bool:
	var paths: Array[String] = []
	var regions: Array[Rect2] = []
	var margins: Array[Rect2] = []
	for source_path in source_paths:
		var location: = _source_location(source_path)
		if location.is_empty():
			return false
		var entry: Array = location.get("entry", [])
		if entry.size() < 10:
			return false
		paths.append(str(location.get("page_path", "")))
		regions.append(Rect2(float(entry[2]), float(entry[3]), float(entry[4]), float(entry[5])))
		margins.append(Rect2(float(entry[6]), float(entry[7]), float(entry[8]), float(entry[9])))
	if paths.is_empty():
		return false
	stream.frame_paths = paths
	stream.frame_regions = regions
	stream.frame_margins = margins
	return true

static func configure_stream_from_source_root(stream: StreamedPngEffect, source_root: String) -> bool:
	return configure_stream_for_paths(stream, source_file_paths(source_root))

static func texture_for_source_path(source_path: String) -> Texture2D:
	var location: = _source_location(source_path)
	if location.is_empty():
		return null
	var page_texture: = ResourceLoader.load(
		str(location.get("page_path", "")), 
		"Texture2D", 
		ResourceLoader.CACHE_MODE_REUSE
	) as Texture2D
	if page_texture == null:
		return null
	var entry: Array = location.get("entry", [])
	var texture: = AtlasTexture.new()
	texture.atlas = page_texture
	texture.region = Rect2(float(entry[2]), float(entry[3]), float(entry[4]), float(entry[5]))
	texture.margin = Rect2(float(entry[6]), float(entry[7]), float(entry[8]), float(entry[9]))
	texture.filter_clip = true
	return texture

static func frame_geometry_for_source_path(source_path: String) -> Dictionary:
	var location: = _source_location(source_path)
	if location.is_empty():
		return {"size": Vector2.ONE, "center": Vector2.ZERO, "has_visual": false}
	var entry: Array = location.get("entry", [])
	var page_path: = str(location.get("page_path", ""))
	var used_size: = Vector2(float(entry[4]), float(entry[5]))
	var original_size: = Vector2(float(entry[8]) + used_size.x, float(entry[9]) + used_size.y)
	return {
		"size": used_size, 
		"center": Vector2(float(entry[6]), float(entry[7])) + used_size * 0.5 - original_size * 0.5, 
		"has_visual": _entry_has_visual(page_path, entry), 
	}

static func build_sprite_frames(
	manifest_path: String, 
	sequence_name: String, 
	animation_name: StringName, 
	fps: float, 
	looped: bool
) -> SpriteFrames:
	var cache_key: = "%s|%s|%s|%.3f|%s" % [
		manifest_path, sequence_name, animation_name, fps, str(looped)
	]
	if _sprite_frames_cache.has(cache_key):
		return _sprite_frames_cache[cache_key] as SpriteFrames
	var frames: = SpriteFrames.new()
	frames.remove_animation(&"default")
	add_animation(frames, manifest_path, sequence_name, animation_name, fps, looped)
	_sprite_frames_cache[cache_key] = frames
	return frames

static func add_animation(
	frames: SpriteFrames, 
	manifest_path: String, 
	sequence_name: String, 
	animation_name: StringName, 
	fps: float, 
	looped: bool, 
	registration_anchor: Variant = null
) -> bool:
	if frames.has_animation(animation_name):
		frames.remove_animation(animation_name)
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, fps)
	frames.set_animation_loop(animation_name, looped)
	var stream: = StreamedPngEffect.new()
	if configure_stream(stream, manifest_path, sequence_name):
		for frame_index in range(stream.frame_paths.size()):
			var page_texture: = ResourceLoader.load(
				stream.frame_paths[frame_index], 
				"Texture2D", 
				ResourceLoader.CACHE_MODE_REUSE
			) as Texture2D
			if page_texture == null:
				continue
			var atlas_texture: = AtlasTexture.new()
			atlas_texture.atlas = page_texture
			atlas_texture.region = stream.frame_regions[frame_index]
			var margin: = stream.frame_margins[frame_index]
			if registration_anchor is Vector2:






				var frame_size: = stream.frame_regions[frame_index].size
				var canvas_size: = frame_size + margin.size
				var current_anchor: = Vector2(
					margin.position.x + frame_size.x * 0.5 - canvas_size.x * 0.5, 
					margin.position.y + frame_size.y - canvas_size.y * 0.5
				)
				var delta: = Vector2(registration_anchor) - current_anchor
				margin.position += delta
			atlas_texture.margin = margin
			atlas_texture.filter_clip = true
			frames.add_frame(animation_name, atlas_texture)
	stream.free()
	if frames.get_frame_count(animation_name) == 0:
		return false
	return true

static func _resolve_sequence_name(sequences: Dictionary, requested_name: String) -> String:
	if sequences.has(requested_name):
		return requested_name





	var aliases: = {
		"wait": ["mc_idle", "idle"], 
		"hurt": ["hurtStand"], 
		"death": ["dead", "mc_dead"], 
		"appear": ["mc_appear"], 
		"skill1": ["effect1", "mc_effect1"], 
		"skill2": ["effect2", "mc_effect2"], 
		"skill3": ["effect3", "mc_effect3"], 
		"skill4": ["effect4", "mc_effect4"], 



		"dash": ["effect2_1"], 
		"skill2_impact": ["effect2_2"], 
		"effect1": ["mc_effect1", "effect1_1"], 
		"effect2": ["mc_effect2", "effect2_1"], 
		"effect3": ["mc_effect3", "effect3_1"], 
		"effect4": ["mc_effect4", "effect4_1"], 
		"wing_left": ["mc_effect1"], 
		"wing_right": ["mc_effect1"], 
		"feather": ["effect1_1"], 
		"poison": ["effect4_1"], 
		"claw": ["effect2_1"], 
		"DefineShape_31": ["idle"], 
		"DefineSprite_12_arrow1": ["arrow1"], 
		"DefineSprite_21_arrow2": ["arrow2"], 
		"DefineSprite_24_hurtStand": ["hurtStand"], 
		"DefineSprite_28__1_fla.effect1_1_9": ["_1_fla.effect1_1_9"], 
		"DefineSprite_34_idle": ["idle"], 
		"DefineSprite_36_mc_dead": ["mc_dead"], 
		"DefineSprite_69_mc_none": ["mc_none"], 
		"DefineSprite_70_mc_appear": ["mc_appear"], 
		"DefineSprite_4_ab_arrow1": ["ab_arrow1"], 
		"DefineSprite_7_ab_arrow2": ["ab_arrow2"], 
	}
	for alias_value in aliases.get(requested_name, []):
		var alias_name: = str(alias_value)
		if sequences.has(alias_name):
			return alias_name




	var suffix: = "_" + requested_name
	var suffix_matches: Array[String] = []
	for sequence_key in sequences.keys():
		var sequence_key_text: = str(sequence_key)
		if sequence_key_text.ends_with(suffix):
			suffix_matches.append(sequence_key_text)
	if suffix_matches.size() == 1:
		return suffix_matches[0]

	var last_separator: = requested_name.rfind("_")
	if last_separator >= 0:
		var tail_name: = requested_name.substr(last_separator + 1)
		if sequences.has(tail_name):
			return tail_name
	return ""

static func frame_geometry(manifest_path: String, sequence_name: String, frame_index: int) -> Dictionary:
	var cache_key: = "%s|%s|%d" % [manifest_path, sequence_name, frame_index]
	if _frame_geometry_cache.has(cache_key):
		return _frame_geometry_cache[cache_key] as Dictionary
	var manifest: = _get_manifest(manifest_path)
	var sequences: Dictionary = manifest.get("sequences", {})
	var resolved_sequence_name: = _resolve_sequence_name(sequences, sequence_name)
	var sequence: Dictionary = sequences.get(resolved_sequence_name, {})
	var frames: Array = sequence.get("frames", [])
	if frame_index < 0 or frame_index >= frames.size() or not frames[frame_index] is Array:
		var missing_frame: = {"size": Vector2.ONE, "center": Vector2.ZERO, "has_visual": false}
		_frame_geometry_cache[cache_key] = missing_frame
		return missing_frame
	var entry: Array = frames[frame_index]
	if entry.size() < 10:
		var invalid_entry: = {"size": Vector2.ONE, "center": Vector2.ZERO, "has_visual": false}
		_frame_geometry_cache[cache_key] = invalid_entry
		return invalid_entry
	var pages: Array = manifest.get("pages", [])
	var page_index: = int(entry[1])
	if page_index < 0 or page_index >= pages.size():
		var missing_page: = {"size": Vector2.ONE, "center": Vector2.ZERO, "has_visual": false}
		_frame_geometry_cache[cache_key] = missing_page
		return missing_page
	var page: Dictionary = pages[page_index]
	var page_path: = str(page.get("path", ""))
	var used_size: = Vector2(float(entry[4]), float(entry[5]))
	var original_size: = used_size + Vector2(float(entry[8]), float(entry[9]))
	var geometry: = {
		"size": used_size, 
		"center": Vector2(float(entry[6]), float(entry[7])) + used_size * 0.5 - original_size * 0.5, 
		"has_visual": _entry_has_visual(page_path, entry), 
	}
	_frame_geometry_cache[cache_key] = geometry
	return geometry

static func _entry_has_visual(page_path: String, entry: Array) -> bool:
	var width: = int(entry[4])
	var height: = int(entry[5])
	if width <= 0 or height <= 0:
		return false
	if width != 1 or height != 1:
		return true
	var cache_key: = "%s|%d|%d" % [page_path, int(entry[2]), int(entry[3])]
	if _entry_visual_cache.has(cache_key):
		return bool(_entry_visual_cache[cache_key])
	var page_texture: = ResourceLoader.load(
		page_path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE
	) as Texture2D
	var has_visual: = false
	if page_texture != null:
		var image: = page_texture.get_image()
		var x: = int(entry[2])
		var y: = int(entry[3])
		if image != null and x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
			has_visual = image.get_pixel(x, y).a > 0.0
	_entry_visual_cache[cache_key] = has_visual
	return has_visual

static func clear_cache() -> void :
	_animation_bundle_cache.clear()
	_manifest_cache.clear()
	_sprite_frames_cache.clear()
	_registry_cache.clear()
	_source_location_cache.clear()
	_entry_visual_cache.clear()
	_frame_geometry_cache.clear()

static func _source_location(source_path: String) -> Dictionary:
	if _source_location_cache.has(source_path):
		return _source_location_cache[source_path] as Dictionary
	var bundle: = _find_bundle(source_path)
	if bundle.is_empty():
		_source_location_cache[source_path] = {}
		return {}
	var manifest_path: = str(bundle.get("manifest", ""))
	var manifest: = _get_manifest(manifest_path)
	var files: Dictionary = manifest.get("files", {})
	var lookup_path: = _canonicalize_source_path(source_path)
	var entry_value: Variant = files.get(lookup_path, [])
	var entry: Array = []
	if files.has(lookup_path) and entry_value is Array:
		entry = entry_value
	else:



		var bundle_root: = str(bundle.get("root", ""))
		var relative_path: = lookup_path.trim_prefix(bundle_root + "/")
		var path_parts: = relative_path.split("/")
		if path_parts.size() < 2:
			_source_location_cache[source_path] = {}
			return {}
		var frame_name: = str(path_parts[-1])
		if not frame_name.ends_with(".png"):
			_source_location_cache[source_path] = {}
			return {}
		var frame_index: = frame_name.get_basename().to_int()
		if frame_index <= 0:
			_source_location_cache[source_path] = {}
			return {}
		path_parts.remove_at(path_parts.size() - 1)
		var requested_sequence: = "/".join(path_parts)
		var sequences: Dictionary = manifest.get("sequences", {})
		var resolved_sequence: = _resolve_sequence_name(sequences, requested_sequence)
		if resolved_sequence.is_empty():
			_source_location_cache[source_path] = {}
			return {}
		var sequence: Dictionary = sequences.get(resolved_sequence, {})
		var sequence_frames: Array = sequence.get("frames", [])
		if frame_index > sequence_frames.size() or not sequence_frames[frame_index - 1] is Array:
			_source_location_cache[source_path] = {}
			return {}
		entry = sequence_frames[frame_index - 1]
	if entry.size() < 10:
		_source_location_cache[source_path] = {}
		return {}
	var pages: Array = manifest.get("pages", [])
	var page_index: = int(entry[1]) if entry.size() > 1 else -1
	if page_index < 0 or page_index >= pages.size():
		_source_location_cache[source_path] = {}
		return {}
	var page: Dictionary = pages[page_index]
	var location: = {"entry": entry, "page_path": str(page.get("path", ""))}
	_source_location_cache[source_path] = location
	return location

static func _canonicalize_source_path(source_path: String) -> String:



	var match : = RegEx.create_from_string("/Game4Monster/[^/]+/(\\d+)(/.*)?$").search(source_path)
	if match == null:
		return source_path
	var suffix: = str(match .get_string(2))
	return "%s/%s%s" % [MONSTER_ROOT, match .get_string(1), suffix]

static func _find_bundle(source_path: String) -> Dictionary:
	var current_manifest: = manifest_for_source_root(source_path)
	if not current_manifest.is_empty():
		var current_match: = RegEx.create_from_string("/(?:Monster_|SwfPng/)(\\d+)(?:/|$)").search(source_path)
		if current_match != null:
			var current_root: = model_root_for_model(int(current_match.get_string(1)))
			return {"root": current_root, "manifest": current_manifest}
	var legacy_match: = RegEx.create_from_string("/Game4Monster/[^/]+/(\\d+)(?:/|$)").search(source_path)
	if legacy_match != null:
		var legacy_manifest: = manifest_for_model(int(legacy_match.get_string(1)))
		if not legacy_manifest.is_empty():
			return {
				"root": model_root_for_model(int(legacy_match.get_string(1))), 
				"manifest": legacy_manifest, 
			}
	var registry: = _get_registry()
	for bundle_value in registry.get("bundles", []):
		if not bundle_value is Dictionary:
			continue
		var bundle: Dictionary = bundle_value
		var root: = str(bundle.get("root", ""))
		if source_path == root or source_path.begins_with(root + "/"):
			return bundle
	return {}

static func _get_registry() -> Dictionary:
	if not _registry_cache.is_empty():
		return _registry_cache
	var file: = FileAccess.open(BULK_REGISTRY_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		_registry_cache = parsed
	return _registry_cache

static func _get_manifest(manifest_path: String) -> Dictionary:
	if not FileAccess.file_exists(manifest_path):
		var model_match: = RegEx.create_from_string("/(?:Monster_|(?:[^/]+/))(\\d+)/atlas/manifest\\.json$").search(manifest_path)
		if model_match != null:
			var resolved_manifest: = manifest_for_model(int(model_match.get_string(1)))
			if not resolved_manifest.is_empty():
				manifest_path = resolved_manifest
	if _manifest_cache.has(manifest_path):
		return _manifest_cache[manifest_path] as Dictionary
	var file: = FileAccess.open(manifest_path, FileAccess.READ)
	if file == null:
		push_error("Monster atlas manifest is missing: " + manifest_path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		push_error("Monster atlas manifest is invalid: " + manifest_path)
		return {}
	var manifest: = parsed as Dictionary
	_normalize_manifest_paths(manifest_path, manifest)
	_manifest_cache[manifest_path] = manifest
	return manifest

static func _normalize_manifest_paths(manifest_path: String, manifest: Dictionary) -> void :
	var atlas_root: = manifest_path.get_base_dir()
	var model_root: = atlas_root.get_base_dir()
	var old_root: = str(manifest.get("root", ""))
	manifest["root"] = model_root
	var pages: Array = manifest.get("pages", [])
	for page_value in pages:
		if not page_value is Dictionary:
			continue
		var page: = page_value as Dictionary
		var page_path: = str(page.get("path", ""))
		if not FileAccess.file_exists(page_path):
			var local_page: = atlas_root.path_join("pages").path_join(page_path.get_file())
			if FileAccess.file_exists(local_page):
				page["path"] = local_page
	var sequences: Dictionary = manifest.get("sequences", {})
	for property in sequences:
		var sequence_value: Variant = sequences[property]
		if not sequence_value is Dictionary:
			continue
		var sequence: = sequence_value as Dictionary
		var source_paths: Array = sequence.get("paths", [])
		for index in range(source_paths.size()):
			source_paths[index] = _normalize_source_path(str(source_paths[index]), old_root, model_root)
		sequence["paths"] = source_paths
	var files: Dictionary = manifest.get("files", {})
	if not files.is_empty():
		var normalized_files: = {}
		for key in files:
			normalized_files[_normalize_source_path(str(key), old_root, model_root)] = files[key]
		manifest["files"] = normalized_files

static func _normalize_source_path(source_path: String, old_root: String, model_root: String) -> String:
	if old_root != "" and (source_path == old_root or source_path.begins_with(old_root + "/")):
		return model_root + source_path.trim_prefix(old_root)
	return source_path

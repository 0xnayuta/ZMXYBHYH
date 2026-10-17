extends RefCounted
class_name NeZhaEquipmentVisuals

const CATALOG_SCRIPT := preload("res://Art/hero_picture/Role6/equipment_atlas/NeZhaEquipmentCatalog.gd")
const ATLAS_ROOT := "res://Art/hero_picture/Role6/equipment_atlas"
const DEFAULT_PATHS := {
	"body": "res://Art/hero_picture/Role6/equipment_atlas/default_body/default_body.tres",
	"body_front": "res://Art/hero_picture/Role6/equipment_atlas/default_body_front/default_body_front.tres",
	"weapon": "res://Art/hero_picture/Role6/equipment_atlas/default_weapon/default_weapon.tres",
}
const LEGACY_NAME_ALIASES := {
	"莲衣": "nzly",
	"火尖枪": "nzhjq",
	"zqfjnz": "341071501",
	"zqwqnz": "342071501",
	"ygfjnz": "341071601",
	"ygwqnz": "342071601",
	"仙域防具哪吒": "341071301",
	"仙域武器哪吒": "342071301",
	"仙域时装": "341071301",
	"仙域幻兵": "342071301",
}

static var _frames_cache: Dictionary = {}


static func clear_cached_frames() -> void:
	_frames_cache.clear()


static func get_body_frames(equipment_id: String) -> SpriteFrames:
	return _get_frames(equipment_id, "body", _get_default_frames("body"))


static func get_body_front_frames(equipment_id: String) -> SpriteFrames:
	return _get_frames(equipment_id, "body_front", _get_default_frames("body_front"))


static func get_weapon_frames(equipment_id: String) -> SpriteFrames:
	return _get_frames(equipment_id, "weapon", _get_default_frames("weapon"))


static func _get_default_frames(layer: String) -> SpriteFrames:
	var resource_path := str(DEFAULT_PATHS.get(layer, ""))
	if resource_path == "":
		return null
	if _frames_cache.has(resource_path):
		return _frames_cache[resource_path] as SpriteFrames
	var frames := ResourceLoader.load(resource_path, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE) as SpriteFrames
	if frames != null:
		_frames_cache[resource_path] = frames
	return frames


static func available_item_ids() -> Array[String]:
	var result: Array[String] = []
	for item_id in CATALOG_SCRIPT.DATA["items"]:
		var item: Dictionary = CATALOG_SCRIPT.DATA["items"][item_id]
		if bool(item.get("available", false)):
			result.append(str(item_id))
	return result


static func _get_frames(equipment_id: String, layer: String, fallback: SpriteFrames) -> SpriteFrames:
	var item := _get_item(equipment_id)
	var item_layer := "body" if layer == "body_front" else layer
	if item.is_empty() or str(item.get("layer", "")) != item_layer or not bool(item.get("available", false)):
		return fallback
	var set_name := str(item.get("set", ""))
	var resource_name := set_name + "_" + layer
	var resource_path := "%s/%s/%s.tres" % [ATLAS_ROOT, resource_name, resource_name]
	if _frames_cache.has(resource_path):
		return _frames_cache[resource_path]
	if not ResourceLoader.exists(resource_path):
		return fallback
	var frames := load(resource_path) as SpriteFrames
	if frames == null:
		return fallback
	_frames_cache[resource_path] = frames
	return frames


static func _get_item(equipment_id: String) -> Dictionary:
	var aliases: Dictionary = CATALOG_SCRIPT.DATA["aliases"]
	if aliases.has(equipment_id):
		var alias: Dictionary = aliases[equipment_id].duplicate(true)
		alias["available"] = CATALOG_SCRIPT.DATA["available_sets"].has(alias["set"])
		return alias
	var items: Dictionary = CATALOG_SCRIPT.DATA["items"]
	if items.has(equipment_id):
		return items[equipment_id]
	if LEGACY_NAME_ALIASES.has(equipment_id):
		var legacy_id: String = LEGACY_NAME_ALIASES[equipment_id]
		if items.has(legacy_id):
			return items[legacy_id]
		var legacy_alias: Dictionary = aliases[legacy_id].duplicate(true)
		legacy_alias["available"] = CATALOG_SCRIPT.DATA["available_sets"].has(legacy_alias["set"])
		return legacy_alias
	for item_id: String in items:
		var item: Dictionary = items[item_id]
		if str(item.get("name", "")) == equipment_id:
			return item
	return {}

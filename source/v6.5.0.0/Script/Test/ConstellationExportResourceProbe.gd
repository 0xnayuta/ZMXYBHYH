extends SceneTree

const MonsterAtlasSequence = preload("res://Script/Monster/MonsterAtlasSequence.gd")
const CASES: = {
	"res://Art/Constellations/Boss/140/skill2": 2, 
	"res://Art/Constellations/Boss/149/skill3": 2, 
	"res://Art/Constellations/Boss/162/skill3": 2, 
}


func _init() -> void :
	for root_path: String in CASES:
		var minimum_count: = int(CASES[root_path])
		var count: = _numbered_resource_count(root_path)
		if count < minimum_count:
			push_error("CONSTELLATION_EXPORT_RESOURCE_FAIL %s frames=%d" % [root_path, count])
			quit(1)
			return
		print("CONSTELLATION_EXPORT_RESOURCE_OK %s frames=%d" % [root_path, count])
	quit(0)


func _numbered_resource_count(root_path: String) -> int:
	var atlas_count: = MonsterAtlasSequence.source_frame_count(root_path)
	if atlas_count > 0:
		return atlas_count
	var count: = 0
	var missing_streak: = 0
	for frame_index in range(1, 601):
		var frame_path: = root_path.path_join("%d.png" % frame_index)
		if ResourceLoader.exists(frame_path, "Texture2D"):
			count = frame_index
			missing_streak = 0
		elif count > 0:
			missing_streak += 1
			if missing_streak >= 30:
				break
	return count

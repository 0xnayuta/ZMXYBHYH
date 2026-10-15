extends SceneTree

func _init() -> void :
	var failures: Array[String] = []
	for stage in range(1, 5):
		var scene_path: = "res://Scene/Pet/PetNeatSummon_%d.tscn" % stage
		var frames_path: = "res://Art/Pet/PetNeat/model/pet_neat_stage%d_frames.tres" % stage
		if ResourceLoader.load(scene_path, "PackedScene") == null:
			failures.append(scene_path)
		var frames: = ResourceLoader.load(frames_path, "SpriteFrames") as SpriteFrames
		if frames == null or not frames.has_animation("wait") or not frames.has_animation("hit1"):
			failures.append(frames_path)
	for path in [
		"res://Art/Pet/PetNeat/effects/PetNeat1Bullet1/1.png", 
		"res://Art/Pet/PetNeat/effects/PetNeat1Bullet2/1.png", 
		"res://Art/Pet/PetNeat/effects/PetNeat4Bullet3/1.png", 
		"res://Art/Pet/skillicon/mncz.png", 
		"res://Art/Pet/skillicon/mljt.png", 
		"res://Art/Pet/skillicon/cnaoyi.png", 
	]:
		if not FileAccess.file_exists(path):
			failures.append(path)
	if failures.is_empty():
		print("PET_NEAT_VERIFY_OK")
		quit(0)
		return
	print("PET_NEAT_VERIFY_FAILED: " + ", ".join(failures))
	quit(1)

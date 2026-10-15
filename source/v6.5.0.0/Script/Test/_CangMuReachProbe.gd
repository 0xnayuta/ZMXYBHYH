extends SceneTree
const EFFECT: = preload("res://Script/Hero/CangMuLongYunEffect.gd")
func _init() -> void :
	call_deferred("_run")
func _run() -> void :
	var atlas = load("res://Art/HeroPicture/Role4/CangMuLongYun/runtime/HeroF_6009_skill.atlas")
	var sf = load("res://Art/HeroPicture/Role4/CangMuLongYun/runtime/HeroF_6009_skill01_2.spine-json")
	var data = ClassDB.instantiate("SpineSkeletonDataResource");data.set_atlas_res(atlas);data.set_skeleton_file_res(sf);data.update_skeleton_data()
	var spine = ClassDB.instantiate("SpineSprite");spine.set_skeleton_data_res(data);root.add_child(spine); await process_frame;spine.get_animation_state().set_animation("skill01_2", false, 0)
	var e = EFFECT.new();e.global_position = Vector2.ZERO;e.set("_spine", spine);root.add_child(e)
	for i in range(60):
		await process_frame
		var reach = e.call("_get_head_forward_reach", spine.get_skeleton())
		if i % 10 == 0: print("REACH frame=%d dir=%s reach=%s" % [i, e.get("_head_sweep_direction"), reach])
	quit(0)

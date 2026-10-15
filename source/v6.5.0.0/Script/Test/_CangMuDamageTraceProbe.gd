extends Node

class TraceEffect:
	extends CangMuLongYunEffect

	var calls: = 0

	func _apply_hit(target: BaseMonster) -> void :
		calls += 1
		var source_ok: = owner_player != null and is_instance_valid(owner_player)
		var source_class: = owner_player.get_class() if source_ok else "<invalid>"
		var before: = int(target.Hp) if target != null and is_instance_valid(target) else -1
		var source_player: Variant = RoleProp.SourcePlayer
		var source_player_ok: = source_player != null and is_instance_valid(source_player)
		var raw: = -1
		if source_ok and target != null and is_instance_valid(target):
			var old_data: Variant = owner_player.HitDic
			owner_player.HitDic = hit_data
			raw = int(target.get_Role_last_hurt(owner_player))
			owner_player.HitDic = old_data
		print("CMLY_DAMAGE_TRACE_CALL n=%d before=%d raw=%d source_ok=%s source_class=%s global_source=%s global_source_ok=%s hit_data=%s target_miss=%s target_def=%s target_mdef=%s target_llrdzs=%s" % [calls, before, raw, source_ok, source_class, str(source_player), source_player_ok, str(hit_data), str(target.miss), str(target.def), str(target.mdef), str(target.llrdzs)])
		super._apply_hit(target)
		var after: = int(target.Hp) if target != null and is_instance_valid(target) else -1
		print("CMLY_DAMAGE_TRACE_AFTER n=%d before=%d after=%d delta=%d gethurt=%s is_miss=%s" % [calls, before, after, before - after, str(target.GetHurt), str(target.is_miss)])

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	var pd: Dictionary = get_node("/root/PlayerData").get("player_data") as Dictionary
	pd["Myself"] = 4
	pd["玩家等级"] = 90
	pd["技能学习"]["技能11"]["等级"] = 1
	pd["技能学习"]["技能12"]["等级"] = 1
	var level: = (load("res://Scene/Level/Level_1.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(level)
	for _i in range(20):
		await get_tree().process_frame
	var hero: role4 = null
	var hero_root: Node = level.get_node_or_null("Hero")
	if hero_root != null:
		for child in hero_root.get_children():
			if child is role4:
				hero = child
				break
	var monster_root: Node = level.get_node_or_null("Monster")
	var timer: = level.get_node_or_null("create_control") as Timer
	if timer != null:
		timer.stop()
	if hero == null or monster_root == null:
		push_error("trace setup failed")
		get_tree().quit(1)
		return
	for child in monster_root.get_children():
		if child is BaseMonster:
			child.queue_free()
	await get_tree().process_frame
	hero.set_process(false)
	hero.set_physics_process(false)
	hero.velocity = Vector2.ZERO
	hero.global_position = Vector2(500, 350)
	hero.PlayerDir = true
	var target: = (load("res://Scene/Monster/Monster_3008.tscn") as PackedScene).instantiate() as BaseMonster
	monster_root.add_child(target)
	target.global_position = hero.global_position + Vector2(120, 0)
	await get_tree().process_frame
	target.set_process(false)
	target.set_physics_process(false)
	target.miss = 0
	target.def = 0
	target.mdef = 0
	target.level = 90
	target.Hp = 1000000
	target.SHp = 1000000
	target.is_death = false
	target.NoTarget = false
	target.is_boss = false
	target.boss_protect_active = false
	target.IsIndestructible = false
	target.llrdzs = 1.0
	RoleProp.SourcePlayer = hero
	Global.get_player = hero
	print("CMLY_DAMAGE_TRACE_SETUP hero=%s target=%s data=%s source=%s" % [str(hero.global_position), str(target.global_position), str(hero.objattackDic.get("cmly", {})), str(RoleProp.SourcePlayer)])
	var effect: = TraceEffect.new()
	effect.setup(hero, true, hero.objattackDic.get("cmly", {}))
	level.add_child(effect)
	for frame in range(130):
		await get_tree().process_frame
		if frame % 10 == 0 and is_instance_valid(effect):
			var reach: = -1.0
			var spine: Variant = effect.get("_spine")
			if spine != null and is_instance_valid(spine) and spine.get_skeleton() != null:
				reach = effect.call("_get_head_forward_reach", spine.get_skeleton())
			print("CMLY_DAMAGE_TRACE_FRAME f=%d hp=%d reach=%s cached=%d calls=%d" % [frame, target.Hp, str(reach), (effect.get("_cached_targets") as Array).size(), effect.calls])
	print("CMLY_DAMAGE_TRACE_RESULT hp=%d calls=%d" % [target.Hp, effect.calls])
	get_tree().quit(0)

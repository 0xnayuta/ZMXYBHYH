extends Node

const LEVEL_SCENE: = preload("res://Scene/Level/Level_1.tscn")
const MONSTER_SCENE: = preload("res://Scene/Monster/Monster_1.tscn")
const EFFECT_SCRIPT: = preload("res://Script/Hero/CangMuLongYunEffect.gd")

class TraceEffect:
	extends CangMuLongYunEffect

	var hit_calls: = 0

	func _is_valid_target(target: Node) -> bool:
		var result: = super._is_valid_target(target)
		if target != null and is_instance_valid(target):
			print("CMLY_FILTER_CHECK id=%d result=%s hp=%s death=%s queued=%s no_target=%s boss=%s protect=%s summon_meta=%s summon_prop=%s class=%s pos=%s" % [
				target.get_instance_id(), str(result), str(target.Hp), str(target.is_death), str(target.is_queued_for_deletion()), 
				str(target.NoTarget), str(target.is_boss), str(target.is_boss_protecting()), str(target.get_meta("is_summon", false)), 
				str(target.get("is_summon") if target.has_method("get") else "?"), target.get_class(), str(target.global_position)
			])
		return result

	func _apply_hit(target: BaseMonster) -> void :
		hit_calls += 1
		print("CMLY_FILTER_APPLY before id=%d hp=%s" % [target.get_instance_id(), str(target.Hp)])
		super._apply_hit(target)
		print("CMLY_FILTER_APPLY after id=%d hp=%s" % [target.get_instance_id(), str(target.Hp)])

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	PlayerData.player_data["Myself"] = 4
	PlayerData.player_data["技能学习"]["技能11"]["等级"] = 1
	PlayerData.player_data["技能学习"]["技能12"]["等级"] = 1
	Global.Is_Show = true
	var level: = LEVEL_SCENE.instantiate()
	add_child(level)
	for _i in range(180):
		await get_tree().process_frame
		if level.get("Role_") != null:
			break
	var hero: = level.get("Role_") as BaseHero
	var root: = level.get("monster") as Node
	if hero == null or root == null:
		print("CMLY_FILTER_FAIL setup")
		get_tree().quit(2)
		return
	if level.get("create_control") != null:
		level.get("create_control").stop()
	hero.set_process(false)
	hero.set_physics_process(false)
	hero.global_position = Vector2(500, 350)
	hero.PlayerDir = true
	RoleProp.SourcePlayer = hero
	Global.get_player = hero
	for child in root.get_children():
		if child is BaseMonster:
			child.queue_free()
	await get_tree().process_frame
	var target: = MONSTER_SCENE.instantiate() as BaseMonster
	root.add_child(target)
	target.global_position = hero.global_position + Vector2(220, 0)
	await get_tree().process_frame
	target.set_process(false)
	target.set_physics_process(false)
	target.Hp = 1000000
	target.SHp = 1000000
	target.miss = 0
	target.def = 0
	target.mdef = 0
	target.level = 90
	target.NoTarget = false
	target.is_death = false
	target.is_boss = false
	target.boss_protect_active = false
	target.IsIndestructible = false
	target.llrdzs = 1.0
	print("CMLY_FILTER_SETUP hero=%s target=%s data=%s active=%s" % [str(hero.global_position), str(target.global_position), str(hero.objattackDic.get("cmly", {})), str(level.get_active_monsters())])
	var effect: = TraceEffect.new()
	effect.setup(hero, true, hero.objattackDic.get("cmly", {}))
	level.add_child(effect)
	for frame in range(130):
		await get_tree().process_frame
		if frame % 5 == 0 and is_instance_valid(effect):
			var spine: Variant = effect.get("_spine")
			var skeleton: Variant = spine.get_skeleton() if spine != null and is_instance_valid(spine) else null
			var reach: = -1.0
			if skeleton != null:
				reach = float(effect.call("_get_head_forward_reach", skeleton))
			print("CMLY_FILTER_FRAME f=%d hp=%s cached=%s reach=%s" % [frame, str(target.Hp), str((effect.get("_cached_targets") as Array).size()), str(reach)])
	print("CMLY_FILTER_RESULT hp=%s hits=%d" % [str(target.Hp), effect.hit_calls if is_instance_valid(effect) else -1])
	get_tree().quit(0 if target.Hp < 1000000 else 3)

extends Node

const LEVEL_SCRIPT_PATH: = "res://Script/Level/Level_esbxx.gd"
const BOSS_SCENE_PATH: = "res://Scene/Monster/ConstellationBossBase.tscn"


func _ready() -> void :
	call_deferred("_run")


func _run() -> void :
	var level_script: = load(LEVEL_SCRIPT_PATH) as Script
	var boss_scene: = load(BOSS_SCENE_PATH) as PackedScene
	if level_script == null or boss_scene == null:
		_fail("resource load")
		return
	var level: = level_script.new() as Node
	level.set("_advancing", true)
	var bosses: Array[BaseMonster] = []
	for _index in range(5):
		var boss: = boss_scene.instantiate() as BaseMonster
		if boss == null:
			level.free()
			_fail("boss instantiate")
			return
		boss.is_fall_medi = true
		boss.fall_list = []
		boss.independent_fall_list = []
		boss.fall_stone = []
		bosses.append(boss)

	for boss in bosses:
		level.call("on_constellation_boss_defeated", boss)
		if not bool(boss.get_meta("death_drops_settled", false)):
			for pending_boss in bosses:
				if is_instance_valid(pending_boss):
					pending_boss.free()
			level.free()
			_fail("multi-boss settlement skipped")
			return

	for boss in bosses:
		boss.settle_death_drops()
		if not bool(boss.get_meta("death_drops_settled", false)):
			for pending_boss in bosses:
				if is_instance_valid(pending_boss):
					pending_boss.free()
			level.free()
			_fail("settlement is not idempotent")
			return
		boss.free()
	level.free()
	print("CONSTELLATION_MULTI_DROP_RACE_OK")
	get_tree().quit(0)


func _fail(reason: String) -> void :
	push_error("CONSTELLATION_DROP_RACE_FAIL %s" % reason)
	get_tree().quit(1)

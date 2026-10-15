extends Node

const LEVEL_SCENE: = "res://Scene/Level/Level_1.tscn"
const ROLE_SCENES: = {
	1: "res://Scene/Hero/Role_1/Role1.tscn", 
	2: "res://Scene/Hero/Role_2/Role_2.tscn", 
	3: "res://Scene/Hero/Role_3/Role_3.tscn", 
	4: "res://Scene/Hero/Role_4/Role_4.tscn", 
	5: "res://Scene/Hero/Role_5/Role_5.tscn", 
	6: "res://Scene/Hero/Role_6/Role_6.tscn", 
}
const ROLE_SKILLS: = {
	1: ["slz", "hytj", "lys", "lyfb", "hmz", "hmz_ws", "zz", "qsez", "jdy", "hyjj", "gsrs", "hyjj_ws"], 
	2: ["blb", "xbz", "shy", "tjgl", "smb", "sgq", "myhc", "jgz", "jhsj", "by", "zfjg"], 
	3: ["ssp", "dj", "dgq", "zznh", "tmc", "sd", "jsp", "xgq", "syzq", "bdqk"], 
	4: ["qlj", "dcj", "wdzt", "tkj", "mmw", "jdz", "lhsq", "zq", "wdww", "bylt", "cmly"], 
	5: ["xyq", "slq", "blq", "fhf", "cxq", "llrd", "lljy", "ygth", "tllz", "ltjz"], 
	6: ["nz_jlsh", "nz_fhcc", "nz_hlqg", "nz_hlhs", "nz_lblc", "nz_yysj"], 
}

var _failed: = false

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["CreateMonsterSpeed"] = 99.0
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	var skill_keys_value: Variant = PlayerData.player_data.get("技能学习", {}).get("技能键位", {})
	if skill_keys_value is Dictionary:
		var skill_keys: = skill_keys_value as Dictionary
		if not skill_keys.is_empty():
			skill_keys[skill_keys.keys()[0]] = "slz"

	var checked: = 0
	var invalid_skill_checked: Dictionary = {}
	for role_id in ROLE_SCENES.keys():
		PlayerData.player_data["Myself"] = int(role_id)
		var role_scene: = load(str(ROLE_SCENES[role_id])) as PackedScene
		_check(role_scene != null, "角色%d场景无法加载" % role_id)
		if role_scene == null:
			continue

		for skill_id_value in ROLE_SKILLS[role_id]:
			var skill_id: = str(skill_id_value)
			var level_scene: = load(LEVEL_SCENE) as PackedScene
			var level: = level_scene.instantiate() as BaseLevel
			_check(level != null, "技能%s测试关卡无法实例化" % skill_id)
			if level == null:
				continue
			add_child(level)
			await get_tree().create_timer(0.16).timeout
			var hero: BaseHero = level.Role_ as BaseHero
			_check(hero != null, "角色%d技能%s没有生成角色" % [role_id, skill_id])
			if hero != null:
				level.process_mode = Node.PROCESS_MODE_DISABLED
				RoleProp.roleprop.Mp = maxi(int(RoleProp.roleprop.SMp), 999999)
				if not invalid_skill_checked.has(role_id):
					hero.get_skill("__invalid_auto_skill__")
					invalid_skill_checked[role_id] = true
				_check(hero.Role1SkillInter.has(skill_id), "角色%d冷却表缺少技能%s" % [role_id, skill_id])
				if not hero.Role1SkillInter.has(skill_id):
					level.queue_free()
					await get_tree().process_frame
					continue
				hero.Role1SkillInter[skill_id] = 0.0
				hero.get_skill(skill_id)
				await get_tree().process_frame
			level.queue_free()
			await get_tree().process_frame
			await get_tree().process_frame
			Global.clear_level_resource_cache()
			checked += 1

	_check(checked == 60, "技能数量异常：期望60，实际%d" % checked)
	if not _failed:
		print("AUTO_BATTLE_ALL_SKILLS_PROBE_OK skills=%d roles=6" % checked)
	get_tree().quit(1 if _failed else 0)

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("AUTO_BATTLE_ALL_SKILLS_PROBE_FAIL " + message)

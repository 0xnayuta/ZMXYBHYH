extends Node

var _failed: = false

func _ready() -> void :
	call_deferred("_run_probe")

func _run_probe() -> void :
	_check(PlayerData.PLAYER_MAX_LEVEL == 350, "人物等级上限未调整为350级")
	var scripts_to_parse: = [
		"res://Scene/OtherScene/MonsterHeadInfo.gd", 
		"res://Script/Monster/Monster_139.gd", 
		"res://Script/Monster/Monster_140.gd", 
		"res://Script/Monster/Monster_144.gd", 
		"res://Script/Monster/Monster_146.gd", 
		"res://Script/BackPack/RoleAttributeIntegerFormat.gd", 
		"res://Script/MagicWeapon/QingLian.gd", 
	]
	var parsed_scripts: Array = []
	for script_path in scripts_to_parse:
		var parsed_script: = ResourceLoader.load(script_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		_check(parsed_script != null, "脚本解析失败：" + script_path)
		parsed_scripts.append(parsed_script)
	var settings: Dictionary = MainSet.set_data
	var player_data: Dictionary = PlayerData.player_data
	var original_difficulty: = int(settings.get("Difficult", 0))
	var original_role_damage_bonus: = float(RoleProp.roleprop.get("damage_bonus", 0.0))
	var original_role_damage_reduction: = float(RoleProp.roleprop.get("damage_reduction", 0.0))
	var original_base_damage_bonus: = float(RoleProp.baseroleprop.get("damage_bonus", 0.0))
	var original_base_damage_reduction: = float(RoleProp.baseroleprop.get("damage_reduction", 0.0))
	var original_source_player = RoleProp.SourcePlayer
	var original_tongtianjiaozhu: Variant = player_data.get("通天教主", null)
	var original_minghai: Variant = player_data.get("冥海", null)
	var original_underworld_nightmare: Variant = player_data.get("地府噩梦", null)
	var original_current_level: = str(Global.CurrentLevel)
	RoleProp.roleprop["damage_bonus"] = 0.0
	RoleProp.roleprop["damage_reduction"] = 0.0
	settings["Difficult"] = BaseMonster.NIGHTMARE_DIFFICULTY

	var monster: = BaseMonster.new()
	monster.level = 12
	monster.SHp = 100
	monster.Hp = 40
	monster.def = 10
	monster.mdef = 20
	monster.ar = 30
	monster.sp = 40
	monster.crit = 5
	monster.miss = 6
	monster.lucky = 7
	monster.Htarget = 8
	monster.Toughness = 0.25
	monster.Critreduce = 9
	monster.self_rhp = 11
	monster.fall_coin = 13
	monster.add_exp = 17
	monster.fall_pro = 0.1
	monster.objattackDic = {
		"hit1": {"power": 50}, 
		"utility": {"attackKind": "physics"}, 
	}

	monster.Difficult()

	_check(monster.level == 312, "等级未增加300")
	_check(monster.SHp == 20000300 and monster.Hp == monster.SHp, "生命公式错误")
	_check(monster.objattackDic["hit1"]["power"] == 40150, "攻击公式错误")
	_check(monster.def == 5030 and monster.mdef == 5060, "防御公式错误")
	_check(monster.ar == 5090 and monster.sp == 5120, "穿透公式错误")
	_check(monster.crit == 15 and monster.miss == 18 and monster.lucky == 21, "噩梦闪避计算错误")
	_check(monster.Htarget == 2024 and is_equal_approx(monster.Toughness, 0.75), "额外命中或魔抗计算错误")
	_check(monster.Critreduce == 27 and monster.self_rhp == 33, "减伤或回血未翻3倍")
	_check(monster.fall_coin == 39 and monster.add_exp == 51, "噩梦奖励倍率错误")
	_check(is_equal_approx(monster.fall_pro, 0.3), "噩梦掉落倍率错误")
	_check(is_equal_approx(monster.damage_reduction, 0.3), "噩梦怪物未获得30%免伤属性")
	_check(is_equal_approx(monster.damage_bonus, 0.3), "噩梦怪物未获得30%伤害属性")
	_check(monster.hd_reduce(1000) == 700, "噩梦30%免伤错误")
	monster.Hp = 2000
	_check(monster.HurtReduceHp(1000, null) == 700, "噩梦受击未返回实际伤害")
	_check(monster.Hp == 1300, "噩梦受击实际扣血不是700")

	var underworld_level_scene: = load("res://Scene/Level/Level_11.tscn") as PackedScene
	_check(underworld_level_scene != null, "地府关卡场景加载失败")
	if underworld_level_scene != null:
		var underworld_level: = underworld_level_scene.instantiate() as BaseLevel
		_check(underworld_level != null, "地府关卡实例化失败")
		if underworld_level != null:
			underworld_level.process_mode = Node.PROCESS_MODE_DISABLED
			add_child(underworld_level)
			await get_tree().process_frame
			var underworld_monster_parent: = underworld_level.get_node_or_null("Monster")
			var underworld_monster: = Global.Create_Monster(26, underworld_monster_parent, Vector2.ZERO)
			_check(underworld_monster != null, "地府怪物生成失败")
			if underworld_monster != null:
				underworld_monster.process_mode = Node.PROCESS_MODE_ALWAYS
				await get_tree().physics_frame
				await get_tree().physics_frame
				_check(underworld_monster.SHp == 40003900, "地府噩梦生命加成错误")
				_check(underworld_monster.objattackDic["hit1"]["power"] == 60525, "地府噩梦攻击加成错误")
				_check(underworld_monster.def == 9360 and underworld_monster.mdef == 9360, "地府噩梦防御加成错误")
				_check(is_equal_approx(underworld_monster.damage_bonus, 0.6), "地府噩梦伤害属性错误")
				_check(is_equal_approx(underworld_monster.damage_reduction, 0.6), "地府噩梦免伤属性错误")
				_check(underworld_monster._settle_nightmare_soul_drop(), "地府噩梦未拦截普通装备掉落")
				_check(bool(underworld_monster.get_meta("underworld_nightmare_soul_drop_settled", false)), "地府噩梦魂晶掉落未结算")
				var white_bone: = Global.Create_Monster(32, underworld_monster_parent, Vector2.ZERO)
				_check(white_bone != null, "地府白骨精生成失败")
				if white_bone != null:
					await get_tree().process_frame
					white_bone.process_mode = Node.PROCESS_MODE_DISABLED
					white_bone.current_ = white_bone.max_
					white_bone.Hp = 0
					white_bone.is_death = false
					white_bone.set_meta("death_drops_settled", false)
					white_bone.state_death()
					_check(bool(white_bone.get_meta("underworld_nightmare_soul_drop_settled", false)), "地府噩梦白骨精最终形态未结算魂晶掉落")
					white_bone.free()
			underworld_level.free()
			await get_tree().process_frame

	var heaven_level_scene: = load("res://Scene/Level/Level_23.tscn") as PackedScene
	_check(heaven_level_scene != null, "天庭关卡场景加载失败")
	if heaven_level_scene != null:
		var heaven_level: = heaven_level_scene.instantiate() as BaseLevel
		_check(heaven_level != null, "天庭关卡实例化失败")
		if heaven_level != null:
			heaven_level.process_mode = Node.PROCESS_MODE_DISABLED
			add_child(heaven_level)
			await get_tree().process_frame
			var heaven_monster_parent: = heaven_level.get_node_or_null("Monster")
			var heaven_monster: = Global.Create_Monster(74, heaven_monster_parent, Vector2.ZERO)
			_check(heaven_monster != null, "天庭怪物生成失败")
			if heaven_monster != null:
				heaven_monster.process_mode = Node.PROCESS_MODE_ALWAYS
				await get_tree().physics_frame
				await get_tree().physics_frame
				_check(heaven_monster._human_soul_crystal_monster_id() == 74, "天庭怪物魂晶 ID 识别错误")
				_check(heaven_monster.SHp >= BaseMonster.HEAVEN_NIGHTMARE_HEALTH_BONUS, "天庭噩梦生命未使用1亿档位")
				_check(heaven_monster.objattackDic["hit1"]["power"] >= BaseMonster.HEAVEN_NIGHTMARE_ATTACK_BONUS, "天庭噩梦攻击未使用10万档位")
				_check(heaven_monster.def >= BaseMonster.HEAVEN_NIGHTMARE_DEFENSE_BONUS and heaven_monster.mdef >= BaseMonster.HEAVEN_NIGHTMARE_DEFENSE_BONUS, "天庭噩梦防御未使用13000档位")
				_check(heaven_monster.ar >= BaseMonster.HEAVEN_NIGHTMARE_PENETRATION_BONUS and heaven_monster.sp >= BaseMonster.HEAVEN_NIGHTMARE_PENETRATION_BONUS, "天庭噩梦穿透未使用21000档位")
				_check(is_equal_approx(heaven_monster.damage_bonus, 1.0), "天庭噩梦100%增伤属性错误")
				_check(is_equal_approx(heaven_monster.damage_reduction, 1.0), "天庭噩梦100%免伤属性错误")
				_check(heaven_monster._settle_nightmare_soul_drop(), "天庭噩梦未拦截普通装备掉落")
				_check(bool(heaven_monster.get_meta("heaven_nightmare_soul_drop_settled", false)), "天庭噩梦魂晶掉落未结算")
				heaven_monster.free()
			var no_soul_boss: = Global.Create_Monster(134, heaven_monster_parent, Vector2.ZERO)
			_check(no_soul_boss != null, "天庭隐藏 Boss 生成失败")
			if no_soul_boss != null:
				await get_tree().process_frame
				no_soul_boss.process_mode = Node.PROCESS_MODE_DISABLED
				_check(no_soul_boss._settle_nightmare_soul_drop(), "无官方魂晶的天庭 Boss 未拦截普通掉落")
				_check(bool(no_soul_boss.get_meta("heaven_nightmare_soul_drop_settled", false)), "无官方魂晶的天庭 Boss 未完成掉落结算")
				no_soul_boss.free()
			heaven_level.free()
			await get_tree().process_frame

	var white_bone_level_scene: = load("res://Scene/Level/Level_bgmj.tscn") as PackedScene
	_check(white_bone_level_scene != null, "白骨秘境关卡场景加载失败")
	if white_bone_level_scene != null:
		var white_bone_level: = white_bone_level_scene.instantiate() as BaseLevel
		_check(white_bone_level != null, "白骨秘境关卡实例化失败")
		if white_bone_level != null:
			white_bone_level.process_mode = Node.PROCESS_MODE_DISABLED
			add_child(white_bone_level)
			await get_tree().process_frame
			var white_bone_parent: = white_bone_level.get_node_or_null("Monster")
			var nightmare_white_bone: = Global.Create_Monster(32, white_bone_parent, Vector2.ZERO)
			_check(nightmare_white_bone != null, "白骨秘境白骨精生成失败")
			if nightmare_white_bone != null:
				nightmare_white_bone.process_mode = Node.PROCESS_MODE_ALWAYS
				await get_tree().physics_frame
				await get_tree().physics_frame
				_check(nightmare_white_bone.SHp >= 40000000, "白骨秘境噩梦白骨精生命未达到4000万")
				_check(is_equal_approx(nightmare_white_bone.damage_bonus, 0.6), "白骨秘境噩梦白骨精未使用地府噩梦伤害属性")
				nightmare_white_bone.relive()
				await get_tree().physics_frame
				_check(nightmare_white_bone.SHp >= 40000000, "白骨精第二形态未重新应用地府噩梦生命")
				nightmare_white_bone.relive()
				await get_tree().physics_frame
				_check(nightmare_white_bone.SHp >= 40000000, "白骨精第三形态未重新应用地府噩梦生命")
				_check(nightmare_white_bone._settle_nightmare_soul_drop(), "白骨秘境噩梦白骨精未拦截普通装备掉落")
				_check(bool(nightmare_white_bone.get_meta("underworld_nightmare_soul_drop_settled", false)), "白骨秘境噩梦白骨精魂晶掉落未结算")
				nightmare_white_bone.free()
			white_bone_level.free()
			await get_tree().process_frame

	var puppet_king_level_scene: = load("res://Scene/Level/Level_13.tscn") as PackedScene
	_check(puppet_king_level_scene != null, "鬼门关场景加载失败")
	if puppet_king_level_scene != null:
		var puppet_king_level: = puppet_king_level_scene.instantiate() as BaseLevel
		_check(puppet_king_level != null, "鬼门关场景实例化失败")
		if puppet_king_level != null:
			puppet_king_level.process_mode = Node.PROCESS_MODE_DISABLED
			add_child(puppet_king_level)
			await get_tree().process_frame
			var puppet_king_parent: = puppet_king_level.get_node_or_null("Monster")
			puppet_king_parent.process_mode = Node.PROCESS_MODE_ALWAYS
			var nightmare_puppet_king: = Global.Create_Monster(33, puppet_king_parent, Vector2.ZERO)
			_check(nightmare_puppet_king != null, "鬼门关傀儡王生成失败")
			if nightmare_puppet_king != null:
				await get_tree().process_frame
				_check(nightmare_puppet_king._human_soul_crystal_monster_id() == 33, "傀儡王魂晶 ID 识别错误")
				nightmare_puppet_king.process_mode = Node.PROCESS_MODE_ALWAYS
				await get_tree().physics_frame
				await get_tree().physics_frame
				_check(nightmare_puppet_king.SHp >= BaseMonster.UNDERWORLD_NIGHTMARE_HEALTH_BONUS, "鬼门关噩梦傀儡王生命未获得4000万加成")
				_check(nightmare_puppet_king.Hp > 0 and not nightmare_puppet_king.death(), "鬼门关傀儡王生成后首帧死亡")
				_check(nightmare_puppet_king.mr_player.current_animation != "death", "鬼门关傀儡王生成后错误播放死亡动画")
				nightmare_puppet_king.Hp = 0
				await get_tree().physics_frame
				_check(bool(nightmare_puppet_king.get_meta("death_drops_settled", false)), "鬼门关噩梦傀儡王死亡时未结算掉落")
				_check(bool(nightmare_puppet_king.get_meta("underworld_nightmare_soul_drop_settled", false)), "鬼门关噩梦傀儡王魂晶掉落未结算")
				nightmare_puppet_king.free()
			puppet_king_level.free()
			await get_tree().process_frame

	var bovine_level_scene: = load("res://Scene/Level/Level_10.tscn") as PackedScene
	_check(bovine_level_scene != null, "牛魔谷场景加载失败")
	if bovine_level_scene != null:
		var bovine_level: = bovine_level_scene.instantiate() as BaseLevel
		_check(bovine_level != null, "牛魔谷场景实例化失败")
		if bovine_level != null:
			bovine_level.process_mode = Node.PROCESS_MODE_DISABLED
			add_child(bovine_level)
			await get_tree().process_frame
			var bovine_monster_parent: = bovine_level.get_node_or_null("Monster")
			var bovine_expected_attack: = {22: ["hit1", 40900], 23: ["hit1", 40450], 24: ["Fire", 40750]}
			var bovine_expected_defense: = {22: 5300, 23: 5300, 24: 5600}
			for bovine_id in [22, 23, 24]:
				var bovine_form: = Global.Create_Monster(bovine_id, bovine_monster_parent, Vector2.ZERO)
				await get_tree().process_frame
				_check(bovine_form != null, "牛魔王形态加载失败：%d" % bovine_id)
				if bovine_form == null:
					continue
				bovine_form.process_mode = Node.PROCESS_MODE_ALWAYS
				await get_tree().physics_frame
				await get_tree().physics_frame
				_check(bovine_form.Hp > 0 and not bovine_form.death(), "牛魔王%d创建后首帧直接死亡" % bovine_id)
				if bovine_id == 24:
					_check(bovine_form.mr_player.current_animation == "heart", "牛魔王三形态生成后错误播放死亡动画")
				var bovine_spawn_hp: = bovine_form.Hp
				_check(bovine_form.is_spawn_damage_protected(), "牛魔王%d未开启出生保护" % bovine_id)
				_check(bovine_form.HurtReduceHp(bovine_spawn_hp * 2, null) == 0 and bovine_form.Hp == bovine_spawn_hp, "牛魔王%d出生时仍会被直接击杀" % bovine_id)
				_check(is_equal_approx(bovine_form.damage_bonus, 0.3), "牛魔王%d未获得噩梦伤害加成" % bovine_id)
				_check(is_equal_approx(bovine_form.damage_reduction, 0.3), "牛魔王%d未获得噩梦免伤加成" % bovine_id)
				_check(bovine_form.SHp > BaseMonster.NIGHTMARE_HEALTH_BONUS, "牛魔王%d未获得噩梦生命加成" % bovine_id)
				_check(bovine_form.def == bovine_expected_defense[bovine_id], "牛魔王%d噩梦物防错误" % bovine_id)
				var expected_attack: Array = bovine_expected_attack[bovine_id]
				_check(bovine_form.objattackDic[expected_attack[0]]["power"] == expected_attack[1], "牛魔王%d噩梦攻击错误" % bovine_id)
				_check(is_equal_approx(bovine_form.fall_pro, 1.5), "牛魔王%d基础掉率未与其他形态统一" % bovine_id)
				_check(bovine_form.fall_list.size() == 1, "牛魔王%d掉落表为空" % bovine_id)
				bovine_form.free()
			bovine_monster_parent.process_mode = Node.PROCESS_MODE_ALWAYS
			var bovine_first_form: = Global.Create_Monster(22, bovine_monster_parent, Vector2(1400, 330))
			await get_tree().process_frame
			await get_tree().physics_frame
			await get_tree().physics_frame
			_check(bovine_first_form != null and bovine_first_form.Hp > 0, "牛魔王一形态切换测试初始化失败")
			bovine_first_form.Hp = 0
			await get_tree().physics_frame
			await get_tree().process_frame
			var bovine_second_form: = bovine_first_form.boss_2 as Monster23
			_check(bovine_second_form != null and bovine_second_form.Hp > 0 and not bovine_second_form.death(), "牛魔王二形态生成后直接死亡")
			if bovine_second_form != null:
				await get_tree().physics_frame
				bovine_second_form.Hp = 0
				await get_tree().physics_frame
				await get_tree().process_frame
				var bovine_third_form: = bovine_second_form.boss_3 as Monster24
				_check(bovine_third_form != null and bovine_third_form.Hp > 0 and not bovine_third_form.death(), "牛魔王三形态生成后直接死亡")
				if bovine_third_form != null:
					bovine_third_form.Monster_Intelligence()
					await get_tree().process_frame
					for _frame in range(5):
						await get_tree().physics_frame
					_check(is_instance_valid(bovine_third_form.hand_1) and is_instance_valid(bovine_third_form.hand_2), "牛魔王三形态未正确生成两只鬼手")
					_check(bovine_third_form.Hp > 0 and not bovine_third_form.death() and not bovine_third_form.is_death, "牛魔王三形态生成鬼手后主体死亡")
			bovine_level.free()
			await get_tree().process_frame

	var original_tower_floor: Variant = player_data.get(LevelZhenYaoTower.TOWER_CURRENT_FLOOR_KEY, null)
	player_data[LevelZhenYaoTower.TOWER_CURRENT_FLOOR_KEY] = 1
	var tower: = LevelZhenYaoTower.new()
	var tower_config: = tower.get_level_monster_config(1)
	_check(int(tower_config.get("hp", 0)) == 9000000, "镇妖塔未将噩梦设置降为地狱生命倍率")
	_check(int(tower_config.get("attack", 0)) == 21000, "镇妖塔未将噩梦设置降为地狱攻击倍率")
	_check(int(tower_config.get("def", 0)) == 500, "镇妖塔错误应用了噩梦物防属性")
	_check(int(tower_config.get("armor_break", 0)) == 500, "镇妖塔错误应用了噩梦物穿属性")
	_check(int(tower_config.get("miss", 0)) == 50, "镇妖塔错误应用了噩梦闪避属性")
	_check(int(tower_config.get("hit", 0)) == 50, "镇妖塔错误应用了噩梦命中属性")
	_check( not bool(tower_config.get("nightmare", false)), "镇妖塔仍标记为噩梦难度")
	var tower_monster: = BaseMonster.new()
	tower_monster.objattackDic = {}
	tower_monster.apply_tower_monster_config(tower_config)
	_check(is_zero_approx(tower_monster.damage_reduction), "镇妖塔怪物仍获得噩梦免伤属性")
	_check(is_zero_approx(tower_monster.damage_bonus), "镇妖塔怪物仍获得噩梦伤害属性")
	_check(tower_monster.hd_reduce(1000) == 1000, "镇妖塔怪物仍应用噩梦30%免伤")

	var normal_monster: = BaseMonster.new()
	_check(is_zero_approx(normal_monster.damage_reduction), "其他难度怪物错误获得免伤属性")
	_check(is_zero_approx(normal_monster.damage_bonus), "其他难度怪物错误获得伤害属性")
	_check(normal_monster.hd_reduce(1000) == 1000, "噩梦免伤错误影响其他难度")
	normal_monster.Hp = 2000
	normal_monster.SHp = 2000
	_check(normal_monster.HurtReduceHp(1000, null) == 1000, "其他难度受击返回值错误")
	_check(normal_monster.Hp == 1000, "其他难度实际扣血被错误修改")

	var hero: = BaseHero.new()
	_check(hero._apply_damage_vs_reduction(1000, monster.damage_bonus) == 1300, "噩梦怪物30%最终伤害错误")
	_check(hero._apply_damage_vs_reduction(1000, normal_monster.damage_bonus) == 1000, "其他难度怪物伤害被错误修改")
	RoleProp.roleprop["damage_bonus"] = 0.3
	RoleProp.roleprop["damage_reduction"] = 0.3
	RoleProp.baseroleprop["damage_bonus"] = 0.3
	RoleProp.baseroleprop["damage_reduction"] = 0.3
	_check(normal_monster._apply_role_damage_vs_reduction(1000) == 1300, "人物30%伤害属性未参与结算")
	_check(monster._apply_role_damage_vs_reduction(1000) == 1000, "人物伤害与怪物免伤未互相抵消")
	_check(hero._apply_damage_vs_reduction(1000) == 700, "人物30%免伤属性未参与结算")
	RoleProp.roleprop["damage_reduction"] = 0.5
	_check(hero._apply_damage_vs_reduction(1000, monster.damage_bonus) == 800, "怪物30%伤害与人物50%免伤相减错误")
	_check(RoleProp.roleprop.has("damage_bonus") and RoleProp.roleprop.has("damage_reduction"), "人物伤害或免伤属性未初始化")
	AE.ensure_loaded()
	_check(str(AE.AllEquipment_.get("human_soul_crystal_6", {}).get("名字", "")) == "龙王魂晶", "龙王低/高未共用龙王魂晶")
	_check( not AE.AllEquipment_.has("human_soul_crystal_19"), "嗜血狂鲨错误注册了魂晶")
	_check(str(AE.AllEquipment_.get("underworld_soul_crystal_26", {}).get("名字", "")) == "鬼灯魂晶", "地府魂晶物品未注册")
	_check(FileAccess.file_exists("res://Art/Monster/魂晶/26.png"), "缺少鬼灯官方精魄图片")
	_check(str(AE.AllEquipment_.get("heaven_soul_crystal_74", {}).get("名字", "")) == "黑龟魂晶", "天庭魂晶物品未注册")
	_check(FileAccess.file_exists("res://Art/Monster/魂晶/74.png"), "缺少黑龟官方魂晶图片")

	for human_monster_id in [1, 5, 12, 24]:
		var human_monster_scene: = load("res://Scene/Monster/Monster_%d.tscn" % human_monster_id) as PackedScene
		_check(human_monster_scene != null, "人间怪物场景加载失败：%d" % human_monster_id)
		if human_monster_scene == null:
			continue
		var human_monster: = human_monster_scene.instantiate() as BaseMonster
		_check(human_monster != null, "人间怪物实例化失败：%d" % human_monster_id)
		if human_monster == null:
			continue
		_check(human_monster._human_soul_crystal_monster_id() == human_monster_id, "真实人间怪物ID识别失败：%d，节点名=%s" % [human_monster_id, human_monster.name])
		human_monster.free()

	var red_boy_scene: = load("res://Scene/Monster/Monster_29.tscn") as PackedScene
	_check(red_boy_scene != null, "红孩儿场景加载失败")
	if red_boy_scene != null:
		var red_boy: = red_boy_scene.instantiate() as BaseMonster
		_check(red_boy != null, "红孩儿实例化失败")
		if red_boy != null:
			_check(red_boy._human_soul_crystal_monster_id() == 29, "红孩儿真实怪物ID识别失败")
			_check(str(AE.AllEquipment_.get("underworld_soul_crystal_29", {}).get("名字", "")) == "魔·红孩儿魂晶", "红孩儿魂晶物品未注册")
			red_boy.free()

	RoleProp.SourcePlayer = hero
	hero.IsDoubleFallPro = false
	_check(is_equal_approx(monster._get_human_nightmare_soul_drop_chance(), 0.25), "噩梦魂晶基础掉率不是25%")
	hero.IsDoubleFallPro = true
	_check(is_equal_approx(monster._get_human_nightmare_soul_drop_chance(), 0.5), "幸运的喜鹊未将噩梦魂晶掉率提升至50%")
	hero.IsDoubleFallPro = false

	var level_guard: = BaseLevel.new()
	var pending_boss: = BaseMonster.new()
	pending_boss.is_boss = true
	pending_boss.Hp = 0
	_check(level_guard._is_stage_monster_node(pending_boss), "未结算掉落的死亡Boss被关卡提前清除")
	pending_boss.set_meta("death_drops_settled", true)
	_check( not level_guard._is_stage_monster_node(pending_boss), "已结算掉落的死亡Boss仍阻塞关卡")
	pending_boss.free()
	level_guard.free()

	var monster_head_scene: = load("res://Scene/OtherScene/MonsterHeadInfo.tscn") as PackedScene
	_check(monster_head_scene != null, "怪物信息页面加载失败")
	if monster_head_scene != null:
		var monster_head = monster_head_scene.instantiate()
		monster_head.MonsterName = "xh"
		var attr_panel: Control = monster_head._create_monster_attr_panel()
		attr_panel.position = Vector2(20, 20)
		add_child(attr_panel)
		await get_tree().process_frame
		var attr_texts: Array[String] = []
		for label_node in attr_panel.find_children("*", "Label", true, false):
			attr_texts.append((label_node as Label).text)
		_check("闪避：0" in attr_texts, "怪物信息页面仍显示噩梦额外闪避")
		_check("命中：2000" in attr_texts, "怪物信息页面未显示噩梦额外2000命中")
		_check("伤害：30%" in attr_texts, "怪物信息页面未显示噩梦30%伤害")
		_check("免伤：30%" in attr_texts, "怪物信息页面未显示噩梦30%免伤")
		_check("  小猴子魂晶 ×3-5：25.0%" in attr_texts, "怪物信息页面未显示固定25%魂晶掉落或数量范围错误")
		hero.IsDoubleFallPro = true
		_check(monster_head._get_drop_chance_text(0.25, BaseMonster.NIGHTMARE_DIFFICULTY, true) == "50.0%", "怪物信息页面未显示喜鹊加成后的50%魂晶掉率")
		hero.IsDoubleFallPro = false
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			var monster_info_image: = get_viewport().get_texture().get_image()
			var monster_info_screenshot: = ProjectSettings.globalize_path("user://nightmare_monster_info_probe.png")
			_check(monster_info_image.save_png(monster_info_screenshot) == OK, "怪物信息页面截图保存失败")
			print("NIGHTMARE_MONSTER_INFO_SCREENSHOT=" + monster_info_screenshot)
		attr_panel.queue_free()
		monster_head.free()
		await get_tree().process_frame

	var level_info_script: = load("res://Scene/OtherScene/LevelInfo.gd") as Script
	_check(level_info_script != null, "关卡信息页面脚本加载失败")
	if level_info_script != null:
		var level_info_node = level_info_script.new()
		level_info_node.LevelName = "花果山"
		level_info_node.TargetStagePath = "res://Scene/Level/Level_1.tscn"
		var human_level_info: Dictionary = level_info_node.LevelInfo["花果山"]
		var nightmare_items: Array = level_info_node._get_level_fall_items(human_level_info)
		var nightmare_probabilities: Dictionary = level_info_node._get_level_fall_probabilities(human_level_info)
		_check(nightmare_items == ["human_soul_crystal_1", "human_soul_crystal_2", "human_soul_crystal_3"], "人间噩梦关卡信息仍混有其他掉落")
		_check(nightmare_probabilities == {
			"human_soul_crystal_1": 25, 
			"human_soul_crystal_2": 25, 
			"human_soul_crystal_3": 25, 
		}, "人间噩梦关卡信息魂晶概率不是固定25%")
		player_data["通天教主"] = 0
		_check(level_info_node._get_nightmare_entry_block_message() == "通关碧游宫开放此难度", "未通关碧游宫时人间噩梦未正确拦截")
		player_data["通天教主"] = 1
		_check(level_info_node._get_nightmare_entry_block_message() == "", "通关碧游宫后人间噩梦仍被拦截")
		var underworld_nightmare_paths: = [
			"res://Scene/Level/Level_nmg.tscn", 
			"res://Scene/Level/Level_bgmj.tscn", 
			"res://Scene/Level/Level_11.tscn", "res://Scene/Level/Level_12.tscn", 
			"res://Scene/Level/Level_13.tscn", "res://Scene/Level/Level_14.tscn", 
			"res://Scene/Level/Level_15.tscn", "res://Scene/Level/Level_16.tscn", 
			"res://Scene/Level/Level_17.tscn", "res://Scene/Level/Level_18.tscn", 
			"res://Scene/Level/Level_19.tscn", "res://Scene/Level/Level_21.tscn", 
		]
		player_data["冥海"] = 0
		for underworld_path in underworld_nightmare_paths:
			level_info_node.TargetStagePath = underworld_path
			_check(level_info_node._get_nightmare_entry_block_message() == "通关南瞻部洲开放此难度", "未通关南瞻部洲时地府噩梦未正确拦截：" + underworld_path)
		player_data["冥海"] = 1
		for underworld_path in underworld_nightmare_paths:
			level_info_node.TargetStagePath = underworld_path
			_check(level_info_node._get_nightmare_entry_block_message() == "", "通关南瞻部洲后地府噩梦仍被拦截：" + underworld_path)
		level_info_node.LevelName = "鬼城"
		level_info_node.TargetStagePath = "res://Scene/Level/Level_11.tscn"
		var underworld_items: Array = level_info_node._get_level_fall_items(level_info_node.LevelInfo["鬼城"])
		_check(underworld_items == ["underworld_soul_crystal_26", "underworld_soul_crystal_27", "underworld_soul_crystal_28"], "地府噩梦关卡信息未替换为魂晶掉落")
		_check(level_info_node._get_level_fall_probabilities(level_info_node.LevelInfo["鬼城"]) == {
			"underworld_soul_crystal_26": 25, 
			"underworld_soul_crystal_27": 25, 
			"underworld_soul_crystal_28": 25, 
		}, "地府噩梦魂晶概率不是固定25%")
		level_info_node.LevelName = "鬼门关"
		level_info_node.TargetStagePath = "res://Scene/Level/Level_13.tscn"
		_check(level_info_node._get_level_fall_items(level_info_node.LevelInfo["鬼门关"]) == [
			"underworld_soul_crystal_26", "underworld_soul_crystal_27", 
			"underworld_soul_crystal_28", "underworld_soul_crystal_33", 
		], "鬼门关噩梦掉落未替换为地府魂晶")
		_check(level_info_node._get_level_fall_probabilities(level_info_node.LevelInfo["鬼门关"]) == {
			"underworld_soul_crystal_26": 25, 
			"underworld_soul_crystal_27": 25, 
			"underworld_soul_crystal_28": 25, 
			"underworld_soul_crystal_33": 25, 
		}, "鬼门关噩梦傀儡王魂晶概率不是固定25%")
		level_info_node.LevelName = "白骨秘境"
		level_info_node.TargetStagePath = "res://Scene/Level/Level_bgmj.tscn"
		_check(level_info_node._get_level_fall_items(level_info_node.LevelInfo["白骨秘境"]) == ["underworld_soul_crystal_32"], "白骨秘境噩梦掉落仍包含正常装备")
		_check(level_info_node._get_level_fall_probabilities(level_info_node.LevelInfo["白骨秘境"]) == {
			"underworld_soul_crystal_32": 25, 
		}, "白骨秘境噩梦魂晶概率不是固定25%")
		level_info_node.LevelName = "火焰山"
		level_info_node.TargetStagePath = "res://Scene/Level/Level_nmg.tscn"
		_check(level_info_node._get_level_fall_items(level_info_node.LevelInfo["火焰山"]) == ["underworld_soul_crystal_29"], "红孩儿噩梦关卡未显示魂晶掉落")
		_check(level_info_node._get_level_fall_probabilities(level_info_node.LevelInfo["火焰山"]) == {
			"underworld_soul_crystal_29": 25, 
		}, "红孩儿噩梦魂晶概率不是固定25%")
		var heaven_nightmare_paths: = [
			"res://Scene/Level/Level_23.tscn", "res://Scene/Level/Level_24.tscn", 
			"res://Scene/Level/Level_25.tscn", "res://Scene/Level/Level_26.tscn", 
			"res://Scene/Level/Level_27.tscn", "res://Scene/Level/Level_28.tscn", 
			"res://Scene/Level/Level_29.tscn", "res://Scene/Level/Level_30.tscn", 
			"res://Scene/Level/Level_pty.tscn", "res://Scene/Level/Level_ymj.tscn", 
			"res://Scene/Level/Level_llbt.tscn", "res://Scene/Level/Level_dtwd.tscn", "兜率宫", 
		]
		player_data["地府噩梦"] = false
		for heaven_path in heaven_nightmare_paths:
			level_info_node.TargetStagePath = heaven_path
			_check(level_info_node._get_nightmare_entry_block_message() == "通关地府噩梦开放此难度", "未通关地府噩梦时天庭噩梦未正确拦截：" + heaven_path)
		player_data["地府噩梦"] = true
		for heaven_path in heaven_nightmare_paths:
			level_info_node.TargetStagePath = heaven_path
			_check(level_info_node._get_nightmare_entry_block_message() == "", "通关地府噩梦后天庭噩梦仍被拦截：" + heaven_path)
		level_info_node.LevelName = "天宫道"
		level_info_node.TargetStagePath = "res://Scene/Level/Level_23.tscn"
		_check(level_info_node._get_level_fall_items(level_info_node.LevelInfo["天宫道"]) == [
			"heaven_soul_crystal_74", "heaven_soul_crystal_75", "heaven_soul_crystal_76", 
			"heaven_soul_crystal_77", "heaven_soul_crystal_78", "heaven_soul_crystal_96", 
		], "天宫道噩梦关卡信息未替换为天庭魂晶")
		_check(level_info_node._get_level_fall_probabilities(level_info_node.LevelInfo["天宫道"]) == {
			"heaven_soul_crystal_74": 25, "heaven_soul_crystal_75": 25, 
			"heaven_soul_crystal_76": 25, "heaven_soul_crystal_77": 25, 
			"heaven_soul_crystal_78": 25, "heaven_soul_crystal_96": 25, 
		}, "天宫道噩梦魂晶概率不是固定25%")
		level_info_node.LevelName = "兜率宫"
		level_info_node.TargetStagePath = "兜率宫"
		var dsg_items: Array = level_info_node._get_level_fall_items(level_info_node.LevelInfo["兜率宫"])
		_check(dsg_items.size() == 11 and "heaven_soul_crystal_114" in dsg_items, "兜率宫噩梦未只显示天庭魂晶")
		level_info_node.TargetStagePath = "res://Scene/Level/Level_22.tscn"
		_check(level_info_node._get_nightmare_entry_block_message() == "当前副本暂未开放此难度", "未开放噩梦副本未正确拦截")
		settings["Difficult"] = 0
		_check(level_info_node._get_nightmare_entry_block_message() == "", "噩梦开放判断错误影响其他难度")
		settings["Difficult"] = BaseMonster.NIGHTMARE_DIFFICULTY
		level_info_node.LevelName = "鲨之涡流"
		level_info_node.TargetStagePath = "res://Scene/Level/Level_9.tscn"
		var shark_level_items: Array = level_info_node._get_level_fall_items(level_info_node.LevelInfo["鲨之涡流"])
		_check(shark_level_items == [
			"human_soul_crystal_14", "human_soul_crystal_15", "human_soul_crystal_17", 
			"human_soul_crystal_16", "human_soul_crystal_20", 
		], "鲨之涡流错误显示嗜血狂鲨魂晶")
		level_info_node.free()

	player_data["地府噩梦"] = false
	Global.CurrentLevel = ""
	var progression_probe: = BaseLevel.new()
	settings["Difficult"] = 0
	progression_probe.add_tg(20)
	_check( not bool(player_data.get("地府噩梦", false)), "普通难度通关转轮殿错误解锁天庭噩梦")
	settings["Difficult"] = BaseMonster.NIGHTMARE_DIFFICULTY
	progression_probe.add_tg(20)
	_check(bool(player_data.get("地府噩梦", false)), "地府噩梦通关后未解锁天庭噩梦")
	progression_probe.free()

	var summoned_shark: = (load("res://Scene/Monster/Monster_19.tscn") as PackedScene).instantiate() as BaseMonster
	_check(summoned_shark != null, "嗜血狂鲨场景加载失败")
	if summoned_shark != null:
		_check(summoned_shark._settle_human_nightmare_soul_drop(), "噩梦嗜血狂鲨未拦截原掉落")
		_check(bool(summoned_shark.get_meta("human_nightmare_soul_drop_settled", false)), "噩梦嗜血狂鲨掉落未结算")
		summoned_shark.free()

	RoleProp.roleprop["damage_reduction"] = 0.0
	RoleProp.baseroleprop["damage_reduction"] = 0.0
	RoleProp.SourcePlayer = hero
	hero.wdsl_damage_reduction = 0.5

	var backpack_scene: = load("res://Scene/BackPack/BackPack.tscn") as PackedScene
	_check(backpack_scene != null, "人物属性页面加载失败")
	if backpack_scene != null:
		var backpack: = backpack_scene.instantiate()
		backpack.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(backpack)
		await get_tree().process_frame
		var main_backpack = backpack.get_node_or_null("Main_Backpack")
		_check(main_backpack != null, "背包道具列表不存在")
		if main_backpack != null:
			var soul_texture: = main_backpack.load_("human_soul_crystal_1") as Texture2D
			_check(soul_texture != null and soul_texture.resource_path == "res://Art/Monster/魂晶/1.png", "背包魂晶未使用掉落魂晶图片")
			var soul_box = main_backpack.target_box(1)
			main_backpack._set_box_item(soul_box, "human_soul_crystal_1", 0, 2)
			soul_box._physics_process(0.0)
			_check(soul_box.get_item_name == "human_soul_crystal_1", "魂晶自定义图标导致背包格物品ID丢失")
		var second_button: = backpack.get_node_or_null("background/infomation/second") as BaseButton
		_check(second_button != null, "人物属性第二页按钮不存在")
		if second_button != null:
			second_button.emit_signal("pressed")
			await get_tree().physics_frame
			await get_tree().process_frame
			var damage_label: = backpack.get_node_or_null("background/infomation/crit") as Label
			var reduction_label: = backpack.get_node_or_null("background/infomation/miss") as Label
			var damage_title: = backpack.get_node_or_null("background/infomation/crit/Crit_tt") as Label
			var reduction_title: = backpack.get_node_or_null("background/infomation/miss/misstt") as Label
			_check(damage_label != null and damage_label.text == "30.00%", "人物伤害百分比显示错误")
			_check(reduction_label != null and reduction_label.text == "50.00%", "多智青莲50%免伤未显示在人物属性页面")
			_check(damage_title != null and damage_title.text == "伤害", "人物伤害标题显示错误")
			_check(reduction_title != null and reduction_title.text == "免伤", "人物免伤标题显示错误")
			if DisplayServer.get_name() != "headless":
				var viewport_image: = get_viewport().get_texture().get_image()
				var screenshot_path: = ProjectSettings.globalize_path("user://nightmare_attribute_probe.png")
				_check(viewport_image.save_png(screenshot_path) == OK, "人物属性页面截图保存失败")
				print("NIGHTMARE_ATTRIBUTE_SCREENSHOT=" + screenshot_path)
		backpack.queue_free()
		await get_tree().process_frame

	settings["Difficult"] = original_difficulty
	RoleProp.roleprop["damage_bonus"] = original_role_damage_bonus
	RoleProp.roleprop["damage_reduction"] = original_role_damage_reduction
	RoleProp.baseroleprop["damage_bonus"] = original_base_damage_bonus
	RoleProp.baseroleprop["damage_reduction"] = original_base_damage_reduction
	RoleProp.SourcePlayer = original_source_player
	if original_tongtianjiaozhu == null:
		player_data.erase("通天教主")
	else:
		player_data["通天教主"] = original_tongtianjiaozhu
	if original_minghai == null:
		player_data.erase("冥海")
	else:
		player_data["冥海"] = original_minghai
	if original_underworld_nightmare == null:
		player_data.erase("地府噩梦")
	else:
		player_data["地府噩梦"] = original_underworld_nightmare
	Global.CurrentLevel = original_current_level
	if original_tower_floor == null:
		player_data.erase(LevelZhenYaoTower.TOWER_CURRENT_FLOOR_KEY)
	else:
		player_data[LevelZhenYaoTower.TOWER_CURRENT_FLOOR_KEY] = original_tower_floor
	monster.free()
	tower.free()
	tower_monster.free()
	normal_monster.free()
	hero.free()
	parsed_scripts.clear()
	await get_tree().process_frame
	print("NIGHTMARE_DIFFICULTY_PROBE_OK")
	get_tree().quit(1 if _failed else 0)

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	_failed = true

extends SceneTree

const FORMULAS = preload("res://Script/Skill/SkillDamageFormulaData.gd")


func _init() -> void :
	var role_skills: = {
		1: ["slz", "hytj", "lys", "lyfb", "hmz", "hmz_ws", "zz", "qsez", "jdy", "hyjj", "sx", "gsrs", "hyjj_ws"], 
		2: ["blb", "xbz", "shy", "tjgl", "smb", "sgq", "myhc", "jgz", "jhsj", "sjt", "by", "zfjg"], 
		3: ["ssp", "dj", "dgq", "zznh", "tmc", "sd", "jsp", "xgq", "syzq", "rj", "bdqk"], 
		4: ["qlj", "dcj", "wdzt", "tkj", "mmw", "jdz", "lhsq", "zq", "wdww", "mds", "bylt", "cmly"], 
		5: ["xyq", "slq", "blq", "fhf", "cxq", "llrd", "lljy", "ygth", "tllz", "yyb", "ltjz"], 
		6: ["nz_jlsh", "nz_fhcc", "nz_hlqg", "nz_hlhs", "nz_lblc", "nz_yysj"], 
	}
	for role_id in role_skills:
		for skill_id in role_skills[role_id]:
			var detail: Dictionary = FORMULAS.get_skill_detail(role_id, skill_id, 5, {"sjt": 5, "rj": 5, "mds": 5})
			if _contains_text(detail, "暂无"):
				_fail("missing formula: role=%d skill=%s" % [role_id, skill_id])
				return

	var hmz: Dictionary = FORMULAS.get_skill_detail(1, "hmz_ws", 4, {})
	if not _contains_text(hmz, "自己的等级") or not _contains_text(hmz, "腾空首段") or not _contains_text(hmz, "落地爆发"):
		_fail("fire demon slash segment formulas")
		return

	var ice: Dictionary = FORMULAS.get_skill_detail(2, "xbz", 4, {"sjt": 10})
	if not _contains_text(ice, "8%") or not _contains_text(ice, "2秒"):
		_fail("water mastery freeze values")
		return

	var spear: Dictionary = FORMULAS.get_skill_detail(6, "nz_lblc", 5, {})
	if not _contains_text(spear, "普通突刺") or not _contains_text(spear, "砸地段") or not _contains_text(spear, "强化追踪"):
		_fail("nezha spear segment formulas")
		return

	var tllz: Dictionary = FORMULAS.get_skill_detail(5, "tllz", 5, {})
	if not _contains_text(tllz, "50%物理防御和魔法防御") or not _contains_text(tllz, "目标位置额外释放一个相同伤害的雷阵"):
		_fail("dragon prince lightning array awaken description")
		return

	var fhf: Dictionary = FORMULAS.get_skill_detail(5, "fhf", 5, {})
	if not _contains_text(fhf, "前摇、后摇和冷却") or not _contains_text(fhf, "原来的三分之一"):
		_fail("dragon prince flash awaken description")
		return

	var ygth: Dictionary = FORMULAS.get_skill_detail(5, "ygth", 5, {})
	if not _contains_text(ygth, "三次巨型银钩") or not _contains_text(ygth, "未觉醒的三倍") or not _contains_text(ygth, "0.8秒"):
		_fail("dragon prince giant hook awaken description")
		return

	var wdww: Dictionary = FORMULAS.get_skill_detail(4, "wdww", 5, {})
	if not _contains_text(wdww, "同时连接四个敌人"):
		_fail("sand monk voodoo doll awaken description")
		return

	var lhsq: Dictionary = FORMULAS.get_skill_detail(4, "lhsq", 5, {})
	if not _contains_text(lhsq, "20%最大生命值和20%攻击") or not _contains_text(lhsq, "最多叠加五次") or not _contains_text(lhsq, "持续10秒"):
		_fail("sand monk soul capture awaken description")
		return

	var level_ten: Dictionary = FORMULAS.get_skill_detail(6, "nz_hlqg", 10, {})
	if not _contains_text(level_ten, "技能公式") or not _contains_text(level_ten, "当前Lv.10") or not _contains_text(level_ten, "攻击 × 3.05"):
		_fail("level ten expanded formula")
		return

	var direct_level: Dictionary = FORMULAS.get_skill_detail(6, "nz_jlsh", 0, {})
	if _contains_text(direct_level, "max(1") or not _contains_text(direct_level, "技能等级") or not _contains_text(direct_level, "攻击 × 0.671"):
		_fail("direct skill level formula")
		return

	var direct_offset: Dictionary = FORMULAS.get_skill_detail(4, "bylt", 0, {})
	if _contains_text(direct_offset, "max(1") or not _contains_text(direct_offset, "技能等级 - 1") or not _contains_text(direct_offset, "攻击 × 1.55"):
		_fail("direct offset skill level formula")
		return

	var shield: Dictionary = FORMULAS.get_skill_detail(3, "sd", 10, {})
	if not _contains_text(shield, "每秒治疗公式") or not _contains_text(shield, "当前Lv.10") or not _contains_text(shield, "1.5%"):
		_fail("shield growth formula")
		return

	var blade: Dictionary = FORMULAS.get_skill_detail(3, "rj", 10, {})
	if not _contains_text(blade, "受击回血概率公式") or not _contains_text(blade, "回血量") or not _contains_text(blade, "7%") or not _contains_text(blade, "4秒"):
		_fail("blade armor growth formula")
		return

	var jgz: Dictionary = FORMULAS.get_skill_detail(2, "jgz", 10, {})
	if not _contains_text(jgz, "目标承受伤害倍率") or not _contains_text(jgz, "当前Lv.10") or not _contains_text(jgz, "2.1"):
		_fail("tight hoop damage taken formula")
		return

	var tjgl: Dictionary = FORMULAS.get_skill_detail(2, "tjgl", 10, {})
	if not _contains_text(tjgl, "技能等级不参与治疗量计算") or not _contains_text(tjgl, "当前Lv.10") or not _contains_text(tjgl, "护盾不被击破就不会消失") or not _contains_text(tjgl, "护盾存在期间免疫击退"):
		_fail("heavenly dew level-independent formula")
		return

	var myhc: Dictionary = FORMULAS.get_skill_detail(2, "myhc", 10, {})
	if not _contains_text(myhc, "技能等级不参与恢复量计算") or not _contains_text(myhc, "当前Lv.10") or not _contains_text(myhc, "4%～5%"):
		_fail("spring recovery level-independent formula")
		return

	print("SKILL_DAMAGE_FORMULA_PROBE_OK")
	quit(0)


func _contains_text(detail: Dictionary, expected: String) -> bool:
	for line_value in detail.get("lines", []):
		if str(line_value).contains(expected):
			return true
	return false


func _fail(reason: String) -> void :
	push_error("SKILL_DAMAGE_FORMULA_PROBE_FAIL: " + reason)
	quit(1)

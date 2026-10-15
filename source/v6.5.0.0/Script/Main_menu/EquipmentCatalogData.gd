extends RefCounted

const EQUIPMENT_TYPES: = ["武器", "防具", "饰品", "时装", "翅膀", "头衔", "神骨"]
const ATTRIBUTES: = {
	"SHp": "生命", "SMp": "魔法", "power": "攻击", "Def": "物防", "Mdef": "魔防", 
	"Crit": "暴击", "Miss": "闪避", "R_hp": "回血", "R_mp": "回魔", "Lucky": "幸运", 
	"Toughness": "韧性", "Htarget": "命中", "CritReduce": "减暴", "ar": "破甲", "sp": "破魔", 
	"vampirism": "吸血", "成长率": "成长率", 
}
const RECIPE_SCRIPT: = preload("res://Script/LDL/RecipeData.gd")
const MAGIC_INFO_SCRIPT: = preload("res://Script/BackPack/Magic_weapon_infor.gd")
const HIDDEN_ITEM_IDS: = ["fgwxg", "fgwxj", "sbhf", "xczg", "zxttq", "zxttp"]

var equipment: Dictionary = {}
var drops: Dictionary = {}
var recipes: Dictionary = {}
var forge_materials: Dictionary = {}
var shop_items: Dictionary = {}

func initialize(all_equipment: Dictionary) -> void :
	equipment = all_equipment
	var level_script: = load("res://Scene/OtherScene/LevelInfo.gd")
	var level_info = level_script.new()
	for level_name in level_info.LevelInfo:
		_register_level(str(level_name), level_info.LevelInfo[level_name])

	for level_id in range(63, 76):
		level_info.TargetStagePath = "res://Scene/Level/Level_%d.tscn" % level_id
		var info: Dictionary = level_info._get_level_info()
		_register_level("东胜神洲·" + str(info.get("LevelName", "")), info)
	level_info.free()
	var immortal_script: = load("res://Script/Level/Level_bxgh.gd")
	var immortal_drops: Dictionary = immortal_script.get_script_constant_map()["EIGHT_IMMORTAL_DROP_DATA"]
	for drop_group in immortal_drops.values():
		var item_ids: Array[String] = []
		for drop in drop_group:
			item_ids.append(str(drop.get("name", "")))
		_register_level("八仙过海副本", {"LevelFall": item_ids})
	for recipe in RECIPE_SCRIPT.RECIPES:
		var result: = str(recipe.get("result", ""))
		if not recipes.has(result):
			recipes[result] = []
		recipes[result].append(recipe)
	var forge = load("res://Script/LDL/Forge.gd").new()
	forge_materials = forge.ItemMaterialList.duplicate(true)
	forge.free()
	var shop = load("res://Script/Shop/SHOP.gd").new()
	for category in shop.CUSTOM_SHOP_ITEMS.values():
		for item in category:
			shop_items[str(item.get("名字", ""))] = true
	shop.free()

func _register_level(level_name: String, info: Dictionary) -> void :
	for item_id in info.get("LevelFall", []):
		var key: = str(item_id)
		if not drops.has(key):
			drops[key] = []
		if not drops[key].has(level_name):
			drops[key].append(level_name)

func item_name(item_id: String) -> String:
	var name_text: = str(equipment.get(item_id, {}).get("名字", "")).strip_edges()
	return name_text if name_text != "" else "未登记物品"

func get_sources(item_id: String) -> String:
	var lines: Array[String] = []
	var direct: Array = drops.get(item_id, [])
	lines.append("直接掉落：" + ("、".join(direct) if not direct.is_empty() else "暂无关卡掉落记录"))
	if shop_items.has(item_id):
		lines.append("获取方式：商城购买")
	var book_id: = item_id + "zzs"
	if forge_materials.has(book_id) and equipment.has(book_id):
		lines.append("获取方式：炼丹炉打造（" + item_name(book_id) + "）")
		var book_drops: Array = drops.get(book_id, [])
		lines.append("制作书掉落：" + ("、".join(book_drops) if not book_drops.is_empty() else "暂无关卡掉落记录"))
		if shop_items.has(book_id):
			lines.append("制作书也可在商城购买")
		var materials: Array[String] = []
		for material_id in forge_materials[book_id]:
			materials.append("%s ×%s" % [item_name(str(material_id)), str(forge_materials[book_id][material_id])])
		lines.append("打造材料：" + "、".join(materials))
	for recipe in recipes.get(item_id, []):
		var counts: Dictionary = {}
		for material_id in recipe.get("materials", []):
			counts[str(material_id)] = int(counts.get(str(material_id), 0)) + 1
		var materials: Array[String] = []
		for material_id in counts:
			var origin: Array = drops.get(material_id, [])
			var suffix: = "（" + "、".join(origin) + "）" if not origin.is_empty() else ""
			if shop_items.has(material_id):
				suffix += "（商城）"
			materials.append("%s ×%d%s" % [item_name(material_id), int(counts[material_id]), suffix])
		var recipe_kind: = "同类型合成" if bool(recipe.get("use_same_type", false)) else "合成"
		lines.append("炼丹炉%s：%s；灵魂 %s" % [recipe_kind, " + ".join(materials), str(recipe.get("cost", 0))])
	return "\n".join(lines)

func get_description(item_id: String) -> String:
	var text: = str(equipment.get(item_id, {}).get("描述", "")).strip_edges()
	if text == "":
		text = "暂无描述"
	var skill: Dictionary = MAGIC_INFO_SCRIPT.SKILL_INFO.get(item_id, {})
	if not skill.is_empty():
		text += "\n\n法宝技能：%s\n%s" % [str(skill.get("title", "")), str(skill.get("desc", ""))]
		if str(skill.get("passive", "")) != "":
			text += "\n被动：" + str(skill.passive)
	return text

func get_attributes(item_id: String) -> Array[String]:
	var data: Dictionary = equipment.get(item_id, {})
	var result: Array[String] = []
	for key in ATTRIBUTES:
		var value: = float(data.get(key, 0.0))
		if not is_zero_approx(value):
			var value_text: = str(int(value)) if is_equal_approx(value, roundf(value)) else str(snappedf(value, 0.01))
			if key == "vampirism":
				value_text = str(snappedf(value * 100.0, 0.01)) + "%"
			result.append("%s  %s" % [ATTRIBUTES[key], value_text])
	if result.is_empty():
		result.append("无基础属性加成")
	return result

func get_icon_path(item_id: String) -> String:
	var custom: = str(equipment.get(item_id, {}).get("图标", ""))
	for path in [custom, "res://Art/BackPack/AllItems/%s.png" % item_id]:
		if path != "" and ResourceLoader.exists(path):
			return path
	return ""

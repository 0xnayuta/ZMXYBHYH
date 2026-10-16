extends Area2D
class_name RoleBullet1
@onready var bullet_an: AnimatedSprite2D = $BulletAN
@onready var bullet_player: AnimationPlayer = $BulletPlayer
var MonsterList
var name_: String
var Player: BaseHero
var is_set = false
var HitDic = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}
var Shallow
var FirstHyjj: bool = true


func _physics_process(_delta: float) -> void:
	if not is_set:
		Player = get_parent().get_parent()
		if name_ == "hyjj":
			call_hyjj()
		else:
			bullet_player.play(name_)
			await bullet_player.animation_finished
		is_set = true


func call_hyjj():
	var cur_level = PlayerData.player_data["技能学习"]["技能9"]["等级"] + 1

	for i in range(3):
		var Monster = get_monster()

		if Monster == null:
			self.queue_free()
			return

		self.position = Monster.position

		bullet_player.play(name_)
		Global.add_sound(self, "res://Music/Hero/44_Role1_hit12_2.mp3")

		await bullet_player.animation_finished
		await get_tree().create_timer(0.55, false).timeout

	self.queue_free()


func get_monster():
	var AllMonsterList = Player.get_parent().get_parent().get_node("Monster").get_children()
	if AllMonsterList.size() <= 0:
		return null
	for i in AllMonsterList:
		if i is BaseMonster:
			if (
				i.get_meta("pet_tiger_unit", false)
				or i.get_meta("is_summon", false)
				or (i.has_method("get") and i.get("is_summon") == true)
			):
				continue

			if i.is_death:
				continue

			if i is Monster48:
				if i.ChangeBody:
					continue
			if i is Monster50:
				if i.is_stop:
					continue
			if i is Monster49:
				if i.is_stop:
					continue

			if abs(i.position.x - Player.position.x) >= 2000:
				continue

			if Player.PlayerDir:
				if i.position.x > Player.position.x:
					return i
			else:
				if i.position.x < Player.position.x:
					return i
	return null


func _on_area_entered(_area: Area2D) -> void:
	randomize()
	if name_ == "qsez" or name_ == "qsez_1":
		var num = randi_range(0, 4)

		if Player.ShallowList.size() < GetMaxMinShallowNum()[0]:
			for i in range(GetMaxMinShallowNum()[0]):
				if Player.ShallowList.size() > GetMaxMinShallowNum()[1]:
					return
				Global.addRole1Shallow(Player.get_parent(), Player.position, Player.action.scale.x, num)
		if Player.ShallowList.size() >= GetMaxMinShallowNum()[1]:
			return
		if randi_range(0, 100) < 45 + (PlayerData.player_data["技能学习"]["技能7"]["等级"] + 1) * 3:
			Global.addRole1Shallow(Player.get_parent(), Player.position + Vector2(0, -20), Player.action.scale.x, num)


func GetMaxMinShallowNum():
	var GetLevel = int(PlayerData.player_data["技能学习"]["技能7"]["等级"])

	if GetLevel <= 2:
		return [1, 5]
	if GetLevel <= 5:
		return [2, 6]
	if GetLevel <= 8:
		return [2, 8]
	return [2, 12]

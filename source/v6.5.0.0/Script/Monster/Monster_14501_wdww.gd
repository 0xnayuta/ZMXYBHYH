extends CharacterBody2D
class_name BossXieShaSengWdww
var MyTarget: BaseHero
@onready var mr_player: AnimationPlayer = $mr_player
@onready var boss_xie_sha_seng_wdww: CharacterBody2D = $"."
@onready var monster_dir: Node2D = $MonsterDir
var entity: BaseMonster
var speed = 200
var currHp = 2000
var maxHp = 2000
var gravity = 980


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	if currHp <= 0:
		mr_player.play("death")
		return
	if MyTarget == null:
		MyTarget = Global.get_player
		pass
	else:
		if self.position.x >= MyTarget.position.x:
			move_left()
		else:
			move_right()
	move_and_slide()


func ai_think():
	pass


func _on_hurt_box_area_entered(area: Area2D) -> void:
	Global.TotalHurtCount += 1
	var Target = area.get_parent().get_parent()
	var MonsterTarget: BaseMonster
	MonsterTarget = entity
	if Target == null or MonsterTarget == null:
		return
	if Target.objattackDic.size() == 0:
		return
	if MonsterTarget is Monster47:
		Global.PlayerBeHitCount += 1
	var last_hit = Global.get_player.get_Monster_last_hurt(MonsterTarget, Target)

	if Global.get_player is Role3Hero and RoleProp.is_ws_state:
		last_hit = int(last_hit * 0.7)
	if MonsterTarget != null:
		MonsterTarget.total_hit += last_hit
	Global.TotalRoleHurt += int(last_hit)

	if Global.get_player is Role1Hero:
		Global.add_sound(self, "res://Music/Hero/49_Role1_beAttack.mp3")
	elif Global.get_player is Role2Hero:
		Global.add_sound(self, "res://Music/Hero/62_Role2_beAttack.mp3")
	else:
		Global.add_sound(self, "res://Music/Hero/68_Role3_beAttack.mp3")
		Global.add_mr_hurt(Global.get_player.pz, Vector2(5, -20))
		if not Global.get_player.IsTMc:
			Global.get_player.CurrentProtect += randi_range(3, 7)
	if Global.get_player is Role3Hero:
		if randi_range(0, 100) <= 4 + PlayerData.player_data["技能学习"]["技能10"]["等级"] * 0.5:
			var Level = PlayerData.player_data["技能学习"]["技能10"]["等级"]
			if Level > 0:
				if not get_parent().get_parent() is Level17 and not get_parent().get_parent() is Level22:
					Global.get_player.cure_Hp(RoleProp.roleprop.power * (0.5 + Level * 0.02))

	if Global.get_player is Role1Hero or Global.get_player is Role2Hero:
		if Global.get_player.is_miss or RoleProp.is_ws_state:
			Global.get_player.is_be_attacking = false
		else:
			Global.get_player.be_hit_back(MonsterTarget, Target)
			Global.get_player.state_behit()
	elif Global.get_player is Role3Hero:
		if Global.get_player.is_miss or Global.get_player.Is_sdBuff or Global.get_player.IsTMc:
			Global.get_player.is_be_attacking = false
		else:
			Global.get_player.be_hit_back(MonsterTarget, Target)
			Global.get_player.state_behit()
	Global.get_player.reduce_hp(last_hit, MonsterTarget, Target)


func move_left():
	monster_dir.scale.x = 1

	velocity.x = -speed
	mr_player.play("walk")


func move_right():
	monster_dir.scale.x = -1

	velocity.x = speed

extends Node2D
class_name ChaseBullet
var speed_
var time_
var name_
var dir: bool

@onready var que: Timer = $que
@onready var chase_player: AnimationPlayer = $ChasePlayer
@onready var chase_ani = $Chaseani
var level = 0
var def = 0
var mdef = 0
var crit = 0
var miss = 0
var lucky = 0
var Htarget = 0
var Toughness = 0
var ar = 0
var sp = 0
var Critreduce = 0
var AttList
var objattackDic = {}
var hit_name
var total_hit = 0
var is_get = false
var is_set = false



var owner_monster: BaseMonster = null
var detection_timer: float = 0
var detection_interval: float = 0.15
var current_direction_x: float = 0
var dead_zone_size: float = 80.0

var velocity: Vector2:
	set(val):
		velocity = val

		if name_ != "Monster1402Bullet2" and name_ != "Monster1402Bullet3" and name_ != "Monster1408Bullet2":
			rotation = velocity.angle()

func _ready():

	set_meta("is_monster_bullet", true)

func _physics_process(delta: float) -> void :
	get_prop()
	if not is_set:
		que.wait_time = float(time_)
		que.start()
		chase_player.play(name_)
		is_set = true


	if name_ == "Monster1402Bullet2" or name_ == "Monster1408Bullet2":

		update_bullet2_direction(delta)
		velocity = Vector2(current_direction_x * speed_, 0)
		global_position += velocity * delta


	elif name_ == "Monster1402Bullet3":

		update_bullet3_direction(delta)
		velocity = Vector2(current_direction_x * speed_, 0)
		global_position += velocity * delta

	else:

		var desired_angle = global_position.direction_to(Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, RoleProp.get_nearest_monster_target_position(global_position).y)).angle()
		var cur_angle = lerp_angle(rotation, desired_angle, 0.05)
		velocity = Vector2.RIGHT.rotated(cur_angle) * speed_
		global_position += velocity * delta


func update_bullet2_direction(delta: float):
	detection_timer += delta


	if detection_timer >= detection_interval:
		var target_x = RoleProp.get_nearest_monster_target_position(global_position).x
		var current_x = global_position.x
		var distance_x = target_x - current_x


		if abs(distance_x) > dead_zone_size:
			current_direction_x = sign(distance_x)
		else:

			if abs(distance_x) < dead_zone_size * 0.3:
				current_direction_x = 0



		detection_timer = 0


func update_bullet3_direction(delta: float):

	if owner_monster == null:
		owner_monster = get_parent().get_parent()
		if not owner_monster is BaseMonster:
			owner_monster = null

	detection_timer += delta


	if detection_timer >= detection_interval:
		var target_x: float

		if owner_monster != null and is_instance_valid(owner_monster):
			target_x = owner_monster.global_position.x
		else:

			target_x = RoleProp.get_nearest_monster_target_position(global_position).x

		var current_x = global_position.x
		var distance_x = target_x - current_x


		if abs(distance_x) > dead_zone_size:
			current_direction_x = sign(distance_x)
		else:

			if abs(distance_x) < dead_zone_size * 0.3:
				current_direction_x = 0



		detection_timer = 0

func get_prop():
	var tt = get_parent().get_parent()
	if tt is BaseMonster:
		level = tt.level
		def = tt.def
		mdef = tt.mdef
		crit = tt.crit
		miss = tt.miss
		lucky = tt.lucky
		Htarget = tt.Htarget
		Toughness = tt.Toughness
		ar = tt.ar
		sp = tt.sp
		Critreduce = tt.Critreduce
		total_hit = tt.total_hit


		if name_ == "Monster1402Bullet3" and owner_monster == null:
			owner_monster = tt

	if hit_name != "":
		self.objattackDic[hit_name] = AttList


func _on_que_timeout() -> void :

	if name_ != "Monster1402Bullet2" and name_ != "Monster1402Bullet3" and name_ != "Monster1408Bullet2":
		add_otherBullet()
		queue_free()


func _on_hit_box_area_entered(area: Area2D) -> void :
	var target = area.get_parent().get_parent()


	if objattackDic[hit_name].has("addeffect"):
		Global.AddBuff(target.buff, objattackDic[hit_name]["addeffect"])


	if name_ != "Monster1402Bullet2" and name_ != "Monster1402Bullet3" and name_ != "Monster1408Bullet2":
		add_otherBullet()
		queue_free()


	if name_ == "Monster1402Bullet3" and owner_monster != null and target == owner_monster:

		return

func add_otherBullet():
	match name_:
		"Monster33Bullet":
			Global.add_Bullet("Monster33Bullet", get_parent(), false, 1, Vector2(self.position.x, self.position.y), hit_name, AttList)
		"Monster37Bullet":
			Global.add_Bullet("Monster37Bullet", get_parent(), false, 1, Vector2(self.position.x, self.position.y), hit_name, AttList)
			Global.add_Bullet("PoisionBullet", get_parent(), false, 1, Vector2(self.position.x, self.position.y), hit_name, AttList)

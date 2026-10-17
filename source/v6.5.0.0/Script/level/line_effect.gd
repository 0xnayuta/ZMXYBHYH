extends Line2D

var type: String
var player: BaseHero
var monster: BaseMonster
var reduce_count: int


func _physics_process(delta: float) -> void:
	player = RoleProp.source_player
	if player != null:
		points[1] = player.position

	reduce_count += 1
	if reduce_count % 60 == 0:
		reduce_count = 0
		match type:
			"Red":
				if player != null:
					player.effect_reducehp(RoleProp.roleprop.SHp * 0.03, "magic")
			"Blue":
				if player != null:
					RoleProp.roleprop.Mp -= RoleProp.roleprop.SMp * 0.03

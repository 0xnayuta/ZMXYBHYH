class_name Wds_Skill_Effet extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer



var HitDic = {
		"power": RoleProp.roleprop.power * (4 + (10 * 0.5)), 
		"hurtBack": [19, 0], 
		"attackKind": "physics", 
		"WSValue": randi_range(15, 18)
	}

var objattackDic: Dictionary = {
	"hit1": {
		"power": int(25 + RoleProp.roleprop.power * (2.5)), 
		"hurtBack": [5, -5], 
		"attackKind": "real", 
		"addeffect": {
			"Name": "poision", 
			"AddTime": 5, 
			"ReduceInterval": 1, 
			"value": int(RoleProp.roleprop.power * (0.4 + 0.04 * 5)), 
			"AttackKind": "real", 
		}
	}
}

func _ready() -> void :


	pass



func sel_skill(skill_name: String) -> void :
	match skill_name:
		"Feng_Skill":
			animation_player.play("Feng_Skill")

			pass
		"Fire_Skill":
			animation_player.play("Fire_Skill")

			pass
		"Yu_Skill":


			pass
		"Lei_Skill":
			animation_player.play("Lei_Skill")

			pass
		"Dian_Skill":


			pass
	pass





func _on_damage_area_2d_area_entered(area: Area2D) -> void :
	var target = area.get_parent().get_parent()

extends Node2D

const TIGER_BOSS_IDS: Array[int] = [1501, 1502, 1503, 1504]

@onready var monster: Node2D = $Monster
@onready var monster_blood: VBoxContainer = $CanvasLayer / MonsterBlood

func _ready() -> void :
	add_to_group("BaseLevel")
	add_to_group("level_container")
	spawn_all_pet_tiger_bosses()

func spawn_all_pet_tiger_bosses() -> void :
	for i in TIGER_BOSS_IDS.size():
		var monster_id: int = TIGER_BOSS_IDS[i]
		var spawn_position: = Vector2(180 + i * 220, 360)
		var monster_node = Global.Create_Monster(monster_id, monster, spawn_position)
		if monster_node == null:
			push_error("PET_TIGER_TEST_FAIL %d" % monster_id)
		else:
			print("PET_TIGER_TEST_OK ", monster_id, " ", monster_node.name)

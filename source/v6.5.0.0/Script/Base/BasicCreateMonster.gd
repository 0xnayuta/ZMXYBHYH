extends Node2D
var BaseLevel_: BaseLevel
@onready var create_monster_timer: Timer = $CreateMonster

@export var MonsterIdList: Array[int]
@export var MonsterPosition: Array[Vector2]
@export var Id: int = 1
@export var Stage: int = 1
var CreateInter: float = 1.2
var CanCreate: bool = false
var CanChcek: bool


func _physics_process(_delta: float) -> void:
	if MonsterIdList.is_empty() or MonsterPosition.is_empty():
		set_physics_process(false)
		create_monster_timer.stop()
		return
	var monster_count := BaseLevel_.monster.get_child_count()
	if monster_count > 4 and monster_count < 6:
		CanChcek = true
	elif monster_count < 4:
		CanCreate = true
	if CanChcek:
		check()
		CanChcek = false
	if CanCreate:
		if create_monster_timer.is_stopped():
			create_monster_timer.start(CreateInter)
		CanCreate = false


func check():
	match Stage:
		1:
			for i in BaseLevel_.create_1.get_children():
				if i.Id > Id:
					return
		2:
			for i in BaseLevel_.create_1.get_children():
				if i.Id > Id:
					return
		3:
			for i in BaseLevel_.create_1.get_children():
				if i.Id > Id:
					return
		4:
			for i in BaseLevel_.create_1.get_children():
				if i.Id > Id:
					return
	CanCreate = true


func create_monster(Id: int, Po: Vector2):
	Global.create_monster(Id, BaseLevel_.monster, Po)


func _on_create_monster_timeout() -> void:
	if MonsterIdList.is_empty() or MonsterPosition.is_empty():
		set_physics_process(false)
		return
	create_monster(MonsterIdList[0], MonsterPosition[0])
	MonsterIdList.remove_at(0)
	MonsterPosition.remove_at(0)

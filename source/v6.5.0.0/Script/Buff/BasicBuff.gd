extends Node
class_name BasicBuff
var CanAdd: bool
var Value: float
var AtkKind: String
var AddObj: BaseObject
var AddTimes: int
func _physics_process(delta: float) -> void :
	pass
func _ready() -> void :
	AddObj = get_parent().get_parent()


func _on_cyele_timer_timeout() -> void :
	pass


func _on_reduce_timer_timeout() -> void :
	pass


func _on_queue_timer_timeout() -> void :
	pass

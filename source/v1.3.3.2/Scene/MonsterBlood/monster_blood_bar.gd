extends Node2D
class_name mr_blood_bar
@onready var blood_bar: TextureProgressBar = $blood_bar
@onready var blood_text: Label = $blood_bar / blood_text
@onready var queue_free_timer: Timer = $queue_free_Timer
@onready var blood_bar_2: TextureProgressBar = $blood_bar / blood_bar2
var t
var bar_value: float
var bar_text: int
var can_show: bool
var Blood:
	set(va):
		Blood = va
		on_Hpchange(Blood)
func _ready() -> void :
	t = create_tween()
func _physics_process(_delta: float) -> void :

	if bar_text <= 0:
		bar_text = 0
	if can_show == false:
		if queue_free_timer.is_stopped():

			queue_free_timer.start()

	else:
		t.pause()

		queue_free_timer.stop()
		self.modulate = Color(1, 1, 1, 1)
	blood_bar.value = bar_value
	Blood = bar_value
	if MainSet.set_data["MonsterBloodTextSHow"]:
		blood_text.text = ""

	else:
		blood_text.text = ""










func _on_timer_timeout() -> void :

	var new_tween = create_tween()
	new_tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 2)
	await new_tween.finished
	queue_free()
func on_Hpchange(vale):
	if not MainSet.set_data["HpBarDelay"]:
		$blood_bar / blood_bar2.value = 0
		return
	create_tween().tween_property($blood_bar / blood_bar2, "value", vale, 0.5)

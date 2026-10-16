extends Node2D
@onready var message: Label = $Message
@onready var message_player: AnimationPlayer = $MessagePlayer
var ShowText: String
var LastTime: float
var _started := false


func _ready() -> void:
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message.position = Vector2(-470, -61)


func _process(_delta: float) -> void:
	message.text = str(ShowText)
	if _started:
		return
	_started = true
	await get_tree().create_timer(LastTime).timeout
	message_player.play("MessageShow")

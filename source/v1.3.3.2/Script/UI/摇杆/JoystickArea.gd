extends Node2D

@export var joystick_size: float = 200
@export var dead_zone: float = 0.2

@onready var background = $Background
@onready var handle = $Handle
@onready var area = $Area2D

var is_active: = false
var current_touch_id: = -1

signal joystick_moved(direction: Vector2)
signal joystick_released

func _ready():

	var shape = CircleShape2D.new()
	shape.radius = joystick_size / 2
	$Area2D / CollisionShape2D.shape = shape


	set_process_input(true)
	print("摇杆初始化完成，半径:", shape.radius)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and not is_active:
			var query = PhysicsPointQueryParameters2D.new()
			query.position = event.position
			var result = area.get_world_2d().direct_space_state.intersect_point(query)

			if not result.is_empty():
				is_active = true
				current_touch_id = event.index
				update_joystick(event.position)
				print("摇杆激活，触摸ID:", current_touch_id)

		elif event.index == current_touch_id and not event.pressed:
			release_joystick()

	elif event is InputEventScreenDrag and event.index == current_touch_id and is_active:
		update_joystick(event.position)

func update_joystick(touch_position: Vector2):
	var center = global_position + Vector2(joystick_size / 2, joystick_size / 2)
	var direction = touch_position - center
	var distance = direction.length()

	if distance > joystick_size / 2:
		direction = direction.normalized() * joystick_size / 2

	handle.position = direction

	var input_vector = direction / (joystick_size / 2)
	if input_vector.length() < dead_zone:
		input_vector = Vector2.ZERO
	else:
		input_vector = input_vector.normalized() * ((input_vector.length() - dead_zone) / (1 - dead_zone))

	joystick_moved.emit(input_vector)
	print("摇杆输入:", input_vector)

func release_joystick():
	is_active = false
	current_touch_id = -1
	var tween = create_tween()
	tween.tween_property(handle, "position", Vector2.ZERO, 0.15)
	joystick_released.emit()
	print("摇杆释放")

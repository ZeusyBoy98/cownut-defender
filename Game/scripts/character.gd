extends CharacterBody2D

@onready var sprite = $Sprite2D

@export var flySpeed = 2000
@export var pitchSpeed = 2

var facing = 1

func _physics_process(delta: float) -> void:
	var dir = Input.get_axis("ui_left", "ui_right")
	if dir != 0:
		facing = 1 if dir > 0 else -1
		sprite.flip_h = (facing == -1)
	
	var pitchDir = Input.get_axis("ui_up", "ui_down")
	rotation = lerp_angle(rotation, pitchDir * facing, delta * pitchSpeed)

	var forwardDir = Vector2(facing, 0).rotated(rotation)
	
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		velocity = forwardDir * flySpeed
	else:
		velocity += get_gravity() * delta
		velocity.y = min(velocity.y, 400)
	
	move_and_slide()

extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var shape = $CollisionShape2D
@onready var fuelGauge = $"/root/Root/CanvasLayer/MarginContainer/Fuel"

@export var flySpeed = 2000
@export var pitchSpeed = 2
@export var acceleration = 1000
@export var brake = 2000

var lastFacing = 1
var facing = 1
var gearDown = true
var braking = false

var fuelBurn = 1
var fuel = 200

var worldWidth = 4096

func _ready() -> void:
	gear()

func gear() -> void:
	shape.shape.size = Vector2(51, 22) if gearDown else Vector2(51, 16)
	shape.position = Vector2(8.0 * facing, 14.5 if gearDown else 6.5)
	sprite.play(&"gear_down" if gearDown else &"gear_up")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("gear"):
		gearDown = not gearDown
		gear()
	
	braking = Input.is_action_pressed("brake")
	if braking:
		velocity = velocity.move_toward(get_gravity(), delta * brake)

	var dir = Input.get_axis("ui_left", "ui_right")
	var flying = dir != 0.0 and fuel > 0
	if dir != 0:
		facing = 1 if dir > 0 else -1
		sprite.flip_h = (facing == -1)
		shape.position.x = 8.0 * facing
	
	var pitchDir = Input.get_axis("ui_up", "ui_down")
	#if pitchDir == 0.0:
	#	pitchDir = -0.5 if flying else 0.5
	
	rotation = lerp_angle(rotation, pitchDir * facing, minf(delta * pitchSpeed, 1.0))

	if flying:
		var target = Vector2(facing, 0).rotated(rotation) * flySpeed
		if !braking:
			velocity = velocity.move_toward(target, delta * acceleration)
		fuel -= fuelBurn * delta
		fuelGauge.text = "Fuel: " + str("%.2f" % fuel)
	else:
		velocity += get_gravity() * delta
		velocity.y = minf(velocity.y, 400)
	
	# Boost code INOP
	#if facing != lastFacing:
	#	if flySpeed < 4000:
	#		flySpeed *= 1.2
	#	lastFacing = facing
	#else:
	#	if flySpeed > 2000:
	#		await get_tree().create_timer(0.1).timeout
	#		flySpeed *= 0.8
	
	if global_position.x < 0:
		global_position.x += worldWidth
	elif global_position.x > worldWidth:
		global_position.x -= worldWidth
	
	move_and_slide()

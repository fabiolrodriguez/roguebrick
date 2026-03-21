extends CharacterBody2D

@export var speed := 220.0
@export var start_speed := 220.0
@export var player_path: NodePath =  NodePath("../../player")
@export var launch_offset_y := 20.0

var is_stuck := true
var start_direction := Vector2(0.1, -1).normalized()

@onready var player = get_node(player_path)
@onready var player_root: Node2D = get_node(player_path)
@onready var paddle: Node2D = player_root.get_node("paddle")
@onready var hit_sound = $"../../hit"
var magnet_enabled := false


func _ready():
	add_to_group("ball")
	stick_to_player(speed)

func _physics_process(delta):
	if is_stuck:
		if paddle != null:
			global_position = Vector2(
				paddle.global_position.x,
				paddle.global_position.y - launch_offset_y - 2
			)
		#global_position.x = paddle.global_position.x
		#global_position.y = paddle.global_position.y - launch_offset_y
		

		if Input.is_action_just_pressed("ui_accept"):
			launch()
		return

	var collision = move_and_collide(velocity * delta)

	if collision:
		var collider = collision.get_collider()
		
		if collider.name == "paddle":
			if magnet_enabled:
				stick_to_player(speed)
				return
			hit_sound.play()
			
		
		if collider.has_method("hit"):
			collider.hit()
			speed += 3
		velocity = velocity.bounce(collision.get_normal()).normalized() * speed

func launch():
	is_stuck = false
	global_position.y -= 1
	velocity = start_direction * speed
	launched.emit()

func stick_to_player(speed: float):
	is_stuck = true
	speed = start_speed
	velocity = Vector2.ZERO
	
	if paddle == null:
		return
	
	global_position = Vector2(
		paddle.global_position.x,
		paddle.global_position.y - launch_offset_y
	)
	
func enable_magnet():
	magnet_enabled = true
	print("Magnet enabled")	
		
signal launched

	

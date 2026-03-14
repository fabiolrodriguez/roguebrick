extends CharacterBody2D

@export var speed := 220.0
@export var player_path: NodePath =  NodePath("../../player")
@export var launch_offset_y := 20.0

var is_stuck := true
var start_direction := Vector2(0.7, -1).normalized()

@onready var player = get_node(player_path)
@onready var player_root: Node2D = get_node(player_path)
@onready var paddle: Node2D = player_root.get_node("paddle")

func _ready():
	stick_to_player()

func _physics_process(delta):
	if is_stuck:
		global_position.x = paddle.global_position.x
		global_position.y = paddle.global_position.y - launch_offset_y

		if Input.is_action_just_pressed("ui_accept"):
			launch()
		return

	var collision = move_and_collide(velocity * delta)

	if collision:
		var collider = collision.get_collider()

		if collider.has_method("hit"):
			collider.hit()
			speed += 10
		velocity = velocity.bounce(collision.get_normal()).normalized() * speed

func launch():
	is_stuck = false
	velocity = start_direction * speed

func stick_to_player():
	is_stuck = true
	velocity = Vector2.ZERO
	global_position.x = paddle.global_position.x
	global_position.y = paddle.global_position.y - launch_offset_y

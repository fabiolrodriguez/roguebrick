extends CharacterBody2D

@export var speed = 400

func apply_size_multiplier(multiplier: float):
	$texture.scale.x *= multiplier

	var rect_shape = $collider.shape as RectangleShape2D
	rect_shape.size.x *= multiplier

func _physics_process(delta):

	var direction = 0

	if Input.is_action_pressed("ui_left"):
		direction -= 1
	if Input.is_action_pressed("ui_right"):
		direction += 1

	velocity.x = direction * speed
	velocity.y = 0

	move_and_slide()

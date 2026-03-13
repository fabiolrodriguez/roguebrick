extends Node2D

@onready var ball = $ball
@onready var player = $player
@onready var deadzone = $deadzone
@onready var bricks = $bricks

var brick_scene = preload("res://scenes/brick.tscn")

func spawn_brick(pos):

	var brick = brick_scene.instantiate()
	$bricks_container.add_child(brick)

	brick.position = pos

	brick.destroyed.connect(check_bricks)

func _on_deadzone_body_entered(body):
	print(body)
	print(body.get_script())	
	if body.name == "ball":
		body.call_deferred("stick_to_player")

func check_bricks():
	if bricks.get_child_count() == 0:
		print("fase completa")

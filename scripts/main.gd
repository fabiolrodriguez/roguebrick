extends Node2D

@onready var ball = $ball
@onready var player = $player
@onready var deadzone = $deadzone

func _on_deadzone_body_entered(body):
	print(body)
	print(body.get_script())	
	if body.name == "ball":
		body.call_deferred("stick_to_player")

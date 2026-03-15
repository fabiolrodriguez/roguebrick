extends Node2D

@onready var ball = $ball
@onready var player = $player
@onready var deadzone = $deadzone
@onready var bricks = $bricks
@export var rows: int = 5
@export var columns: int = 5
@export var spacing_x: float = 9.0
@export var spacing_y: float = 5.0
@export var start_position: Vector2 = Vector2(60, 20)

@export var ball_path: NodePath =  NodePath("./ball")
@onready var ball2 = get_node(ball_path)
@onready var ball2_root: Node2D = get_node(ball_path)
@onready var bola: Node2D = ball2_root.get_node("bola")

var ball_speed : float
var phase := 1
var lives = 3

var brick_scene = preload("res://scenes/brick.tscn")
var brick = brick_scene.instantiate()

func generate_bricks():
	
	var brick_colors = [
		Color.FIREBRICK,
		Color.TOMATO,
		Color.SANDY_BROWN,
		Color.AQUAMARINE,
		Color.DODGER_BLUE
	]
	
	for child in bricks.get_children():
		child.queue_free()
	
	print("gerando bricks para fase:", phase)

	for row in range(rows):
		for col in range(columns):
			
			# get the polygon size
			var sprite = brick.get_node("texture")
			var size = sprite.texture.get_size()
			
			var brick = brick_scene.instantiate()
			bricks.add_child(brick)

			var x = start_position.x + col * (size.x + spacing_x)
			var y = start_position.y + row * (size.y + spacing_y)

			brick.position = Vector2(x, y)
			
			var color = brick_colors[row % brick_colors.size()]
			brick.get_node("texture").modulate = color
			brick.destroyed.connect(check_bricks)

func _ready():
	
	randomize()
	generate_bricks()
	# connect brick to send the get the destroyed signal
	for brick in bricks.get_children():
		brick.destroyed.connect(_on_brick_destroyed)
	
	ball_speed = bola.start_speed		

func _on_brick_destroyed():
	call_deferred("check_bricks")
	
#func spawn_brick(pos):
#
	#var brick = brick_scene.instantiate()
	#$bricks_container.add_child(brick)
	#brick.position = pos
	#brick.destroyed.connect(check_bricks)

func check_lives():
	if lives <= 0:
		print("GAME OVER")
		get_tree().paused = true

func _on_deadzone_body_entered(body):
	if body.name == "bola":
		lives -= 1
		check_lives()
		body.stick_to_player(ball_speed)

func start_phase(phase):
	phase = phase
	ball_speed += 20
	print("Starting phase: ", phase)
	bola.stick_to_player(ball_speed)
	generate_bricks()

func check_bricks():
	print("bricks restantes:", bricks.get_child_count())

	if bricks.get_child_count() <= 1:
		if phase <= 4:
			phase += 1
			start_phase(phase)

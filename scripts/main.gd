extends Node2D

@onready var ball = $ball
@onready var player = $player
@onready var deadzone = $deadzone
@onready var bricks = $bricks

## teste

@export var rows: int = 5
@export var columns: int = 5
@export var spacing_x: float = 11
@export var spacing_y: float = 5.0
@export var start_position: Vector2 = Vector2(10, 5)

var brick_scene = preload("res://scenes/brick.tscn")

var brick = brick_scene.instantiate()

# get the polygon size
var polygon = brick.get_node("Polygon2D")
var rect = Rect2()

func generate_bricks():
	
	var brick_colors = [
		Color.FIREBRICK,
		Color.TOMATO,
		Color.SANDY_BROWN,
		Color.DARK_OLIVE_GREEN,
		Color.DODGER_BLUE
	]
	
	for child in bricks.get_children():
		child.queue_free()
	
	# get the polygon size
	for p in polygon.polygon:
		rect = rect.expand(p)

	var size = rect.size
	var brick_width = rect.size.x
	var brick_height = rect.size.y
	print(brick_width)
	print(brick_height)
	# end of getting polygon size
	
	for row in range(rows):
		for col in range(columns):
			var brick = brick_scene.instantiate()
			bricks.add_child(brick)

			var x = start_position.x + col * (brick_width + spacing_x)
			var y = start_position.y + row * (brick_height + spacing_y)

			brick.position = Vector2(x, y)
			
			var color = brick_colors[row % brick_colors.size()]
			brick.get_node("Polygon2D").modulate = color

func _ready():
	
	randomize()
	generate_bricks()
	# connect brick to send the get the destroyed signal
	for brick in bricks.get_children():
		brick.destroyed.connect(_on_brick_destroyed)

func _on_brick_destroyed():
	call_deferred("check_bricks")
	
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
	print("bricks restantes:", bricks.get_child_count())

	if bricks.get_child_count() <= 1:
		print("fase completa")

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

@onready var lives_label = $hud/LivesLabel
@onready var level_label = $hud/Label
@onready var dead_menu = $dead
@onready var win_menu = $win

var brick_hits := 1
var spawn_chance := 1.0

var ball_speed : float
var phase = 1
var lives = 3

var brick_scene = preload("res://scenes/brick.tscn")
var brick = brick_scene.instantiate()

## Timer
var elapsed_time := 0.0
var timer_running := false
var timer_started_once := false

@onready var timer_label = $hud/TimerLabel

func update_timer_ui():
	var total_seconds = int(elapsed_time)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60

	timer_label.text = "%02d:%02d" % [minutes, seconds]

func _process(delta):
	if timer_running:
		elapsed_time += delta
		update_timer_ui()

func update_lives_ui():
	lives_label.text = "LIVES: %d" % lives
	
func update_level_ui():
	if phase > 4:
		level_label.text = "WINNER"
	else:
		level_label.text = "LEVEL: %d" % phase	

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
			if randf() > spawn_chance:
				continue
			
			var sprite = brick.get_node("texture")
			var size = sprite.texture.get_size()
			
			var brick = brick_scene.instantiate()
			bricks.add_child(brick)

			var x = start_position.x + col * (size.x + spacing_x)
			var y = start_position.y + row * (size.y + spacing_y)

			brick.position = Vector2(x, y)
			
			var color = brick_colors[row % brick_colors.size()]
			brick.get_node("texture").modulate = color
			brick.set_hits(brick_hits)
			brick.destroyed.connect(check_bricks)

func _on_ball_launched():
	timer_running = true
	if not timer_started_once:
		timer_started_once = true

func _ready():
	
	randomize()
	dead_menu.visible = false
	win_menu.visible = false
	generate_bricks()
	# connect brick to send the get the destroyed signal
	for brick in bricks.get_children():
		brick.destroyed.connect(_on_brick_destroyed)
	
	ball_speed = bola.start_speed
	update_lives_ui()
	update_level_ui()
	bola.launched.connect(_on_ball_launched)

func _on_brick_destroyed():
	call_deferred("check_bricks")
	
func check_lives():
	if lives <= 0:
		print("GAME OVER")
		dead_menu.visible = true
		get_tree().paused = true
		
func check_win():
	if phase > 4:
		print("WINNER")
		win_menu.visible = true
		get_tree().paused = true
		timer_running = false	

func _on_deadzone_body_entered(body):
	if body.name == "bola":
		lives -= 1
		update_lives_ui()
		check_lives()
		body.stick_to_player(ball_speed)
		timer_running = false

func start_phase(phase):
	phase = phase
	ball_speed += 20
	brick_hits += 1
	spawn_chance -= 0.1
	print("Starting phase: ", phase)
	bola.stick_to_player(ball_speed)
	generate_bricks()
	update_level_ui()

func check_bricks():
	print("bricks restantes:", bricks.get_child_count())

	if bricks.get_child_count() <= 1:
		phase += 1
		check_win()
		start_phase(phase)


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_quit_pressed() -> void:
	get_tree().quit()

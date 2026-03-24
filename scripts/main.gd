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

@export var player_path: NodePath =  NodePath("./player")
@onready var player2 = get_node(player_path)
@onready var player_root: Node2D = get_node(player_path)
@onready var paddle: Node2D = player_root.get_node("paddle")

@onready var lives_label = $hud/LivesLabel
@onready var level_label = $hud/Label
@onready var dead_menu = $dead
@onready var win_menu = $win
## SFX
@onready var bg_music = $bg
@onready var button_hover = $button_hover
@onready var button_click = $button_click
@onready var game_over = $game_over
@onready var deadzone_sound = $deadzone_sound

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

var has_multiball_upgrade := false

var winner := false

@onready var timer_label = $hud/TimerLabel

## Player upgrades
@onready var upgrade_menu = $UpgradePanel
@onready var option1_button = $UpgradePanel/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/option1
@onready var option2_button = $UpgradePanel/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/option2
@onready var option3_button = $UpgradePanel/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/option3
@export var ball_scene: PackedScene
var available_upgrades = [
	"bigger_paddle",
	"faster_ball",
	"extra_life",
	"faster_player",
	"magnet_ball",
	"multi_ball",
	"piercing_ball",
]

var current_upgrade_choices: Array = []

func show_upgrade_panel():
	get_tree().paused = true
	upgrade_menu.visible = true
	#upgrade_menu.modulate.a = 0.0
	upgrade_menu.scale = Vector2(0.95, 0.95)
	
	var tween = create_tween()
	tween.tween_property(upgrade_menu, "modulate:a", 1.0, 0.15)
	tween.parallel().tween_property(upgrade_menu, "scale", Vector2.ONE, 0.15)

	current_upgrade_choices = available_upgrades.duplicate()
	current_upgrade_choices.shuffle()
	current_upgrade_choices = current_upgrade_choices.slice(0, 3)

	option1_button.text = upgrade_to_text(current_upgrade_choices[0])
	option2_button.text = upgrade_to_text(current_upgrade_choices[1])
	option3_button.text = upgrade_to_text(current_upgrade_choices[2])


func upgrade_to_text(upgrade_id: String) -> String:
	match upgrade_id:
		"bigger_paddle":
			return "BIGGER"
		"faster_ball":
			return "BALL -SPEED"
		"extra_life":
			return "+1UP"
		"faster_player":
			return "PLAYER +SPEED"
		"magnet_ball":
			return "MAGNET BALL"
		"multi_ball":
			return "MULTI BALL"
		"piercing_ball":
			return "PIERCING BALL"			
		_:
			return upgrade_id


func choose_upgrade(index: int):
	var chosen_upgrade = current_upgrade_choices[index]
	get_tree().paused = false
	apply_upgrade(chosen_upgrade)
	upgrade_menu.visible = false

	call_deferred("start_new_phase", phase)


func apply_upgrade(upgrade_id: String):
	match upgrade_id:
		"bigger_paddle": 
			if paddle.has_method("apply_size_multiplier"):
				paddle.apply_size_multiplier(1.2)
		"faster_ball":
			ball_speed -= 20.0
		"extra_life":
			lives += 1
			update_lives_ui()
		"faster_player":
			if player.has_method("increase_speed"):
				player.increase_speed(60.0)
		"magnet_ball":
			print("Entrou no case magnet_ball")
			if bola.has_method("enable_magnet"):
				bola.enable_magnet()
		"multi_ball":
			print("Entrou no case multi ball")
			has_multiball_upgrade = true
			spawn_extra_ball()
		"piercing_ball":
			if bola.has_method("enable_piercing"):
				bola.enable_piercing()
		
			
func _on_option_1_button_pressed():
	choose_upgrade(0)

func _on_option_2_button_pressed():
	choose_upgrade(1)
	
func _on_option_3_button_pressed():
	choose_upgrade(2)			
			
## End of upgrades			

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
	upgrade_menu.visible = false
	
	#generate_bricks()
	# connect brick to send the get the destroyed signal
	for brick in bricks.get_children():
		brick.destroyed.connect(_on_brick_destroyed)
	
	ball_speed = bola.start_speed
	update_lives_ui()
	update_level_ui()
	bola.launched.connect(_on_ball_launched)
	bg_music.stream.loop = true
	bg_music.play()
	
	option1_button.mouse_entered.connect(_on_button_hover.bind(option1_button))
	option1_button.mouse_exited.connect(_on_button_exit.bind(option1_button))

	option2_button.mouse_entered.connect(_on_button_hover.bind(option2_button))
	option2_button.mouse_exited.connect(_on_button_exit.bind(option2_button))

	option3_button.mouse_entered.connect(_on_button_hover.bind(option3_button))
	option3_button.mouse_exited.connect(_on_button_exit.bind(option3_button))
	start_phase(phase)

func _on_brick_destroyed():
	call_deferred("check_bricks")
	
func check_lives():
	if lives <= 0:
		print("GAME OVER")
		await get_tree().create_timer(1).timeout
		game_over.play()
		dead_menu.visible = true
		get_tree().paused = true
		
func check_win():
	if phase > 4:
		winner = true
		print("WINNER")
		win_menu.visible = true
		get_tree().paused = true
		timer_running = false	

func _on_deadzone_body_entered(body):
	if body.is_in_group("ball"):
		if body.is_extra_ball:
			body.queue_free()
			return
		lives -= 1
		update_lives_ui()
		check_lives()
		ball_speed = bola.start_speed
		if dead_menu.visible == false:
			deadzone_sound.play()
		await get_tree().create_timer(0.5).timeout
		bola.call_deferred("stick_to_player", ball_speed)
		timer_running = false
		call_deferred("check_remaining_balls")

func start_phase(phase):
	phase = phase
	print("Starting phase: ", phase)
	bola.call_deferred("stick_to_player", ball_speed)
	generate_bricks()
	update_level_ui()
	if phase > 0:
		ball_speed = bola.start_speed + 18
		brick_hits += 1
		spawn_chance -= 0.1
		if !winner:
			show_upgrade_panel()

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

func _on_option_1_pressed() -> void:
	animate_press(option1_button)
	button_click.play()
	choose_upgrade(0)

func _on_option_2_pressed() -> void:
	animate_press(option2_button)
	button_click.play()
	choose_upgrade(1)

func _on_option_3_pressed() -> void:
	animate_press(option3_button)
	button_click.play()
	choose_upgrade(2)
	
func _on_button_hover(button):
	button.modulate = Color(1.2, 1.2, 1.2)
	button_hover.play()

func _on_button_exit(button):
	button.modulate = Color(1, 1, 1) # normal	
	
func animate_press(button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(button, "scale", Vector2(1, 1), 0.05)

func spawn_extra_ball():
	print("spawn_extra_ball chamada")
	print("ball_scene:", ball_scene)

	if ball_scene == null:
		print("ERRO: ball_scene está null")
		return

	var new_ball = ball_scene.instantiate()
	add_child(new_ball)
	
	var ball_script = new_ball.get_node("bola")

	print("nova bola criada:", new_ball)
	ball_script.scale = Vector2(0.27, 0.27)
	ball_script.global_position = paddle.global_position + Vector2(20, -10)
	ball_script.player = player
	ball_script.is_stuck = false
	ball_script.is_extra_ball = true	
	ball_script.speed = ball_speed
	ball_script.velocity = Vector2(-0.6, -1).normalized() * ball_speed

	print("nova bola posicionada em:", new_ball.global_position)
	print("nova velocidade:", ball_script.velocity)
	
func check_remaining_balls():
	var balls = get_tree().get_nodes_in_group("ball")

	if balls.size() == 0:
		lives -= 1
		update_lives_ui()

		if lives <= 0:
			check_lives()
		else:
			bola.call_deferred("stick_to_player", ball_speed)

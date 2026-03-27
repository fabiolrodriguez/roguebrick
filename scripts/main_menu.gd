extends Node2D

@onready var main_menu := $MainMenu
@onready var controls_menu := $Controls
@onready var settings_menu = $Settings
@onready var volume = $Settings/PanelContainer/CenterContainer/VBoxContainer/HBoxContainer/HSlider
@onready var fullscreen = $Settings/PanelContainer/CenterContainer/VBoxContainer/CheckBox
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	controls_menu.visible = false
	settings_menu.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/wrold.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_control_button_pressed() -> void:
	main_menu.visible = false
	controls_menu.visible = true

func _on_back_button_pressed() -> void:
	main_menu.visible = true
	controls_menu.visible = false
	settings_menu.visible = false 

func _on_settings_button_pressed() -> void:
	main_menu.visible = false
	settings_menu.visible = true

func _on_h_slider_changed(value) -> void:
	print(value)
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_check_box_toggled(pressed) -> void:
	if pressed:
		print("fullscreen set")
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

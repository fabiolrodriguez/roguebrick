extends Node2D

@onready var main_menu := $MainMenu
@onready var controls_menu := $Controls
@onready var settings_menu = $Settings
@onready var volume = $Settings/PanelContainer/CenterContainer/VBoxContainer/HBoxContainer/HSlider
@onready var fullscreen = $Settings/PanelContainer/CenterContainer/VBoxContainer/CheckBox
@onready var start_button = $MainMenu/CenterContainer/VBoxContainer/StartButton
@onready var back_button = $Controls/PanelContainer/CenterContainer/VBoxContainer/BackButton

func _ready() -> void:
	controls_menu.visible = false
	settings_menu.visible = false
	start_button.grab_focus()

func _process(delta: float) -> void:
	pass

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/wrold.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_control_button_pressed() -> void:
	main_menu.visible = false
	controls_menu.visible = true
	back_button.grab_focus()

func _on_back_button_pressed() -> void:
	main_menu.visible = true
	controls_menu.visible = false
	settings_menu.visible = false
	start_button.grab_focus()

func _on_settings_button_pressed() -> void:
	main_menu.visible = false
	settings_menu.visible = true
	fullscreen.grab_focus()

func _on_h_slider_changed(value) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_check_box_toggled(pressed) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

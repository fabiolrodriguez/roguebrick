extends StaticBody2D

signal destroyed

func hit():
	destroyed.emit()
	queue_free()

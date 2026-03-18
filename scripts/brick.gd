extends StaticBody2D

signal destroyed

var hits := 1

@onready var sprite = $texture
@onready var hit_brick = $"../../hit_brick"
@onready var destroy_brick = $"../../destroy_brick"

func set_hits(value: int):
	hits = value
	update_visual()

func hit():
	hits -= 1
	if hits <= 0:
		destroy_brick.play()
		destroyed.emit()
		queue_free()
	else:
		hit_brick.play()
		update_visual()
		

func update_visual():
	match hits:
		1:
			sprite.modulate = Color(0.4, 0.8, 1.0)
		2:
			sprite.modulate = Color(1.0, 0.8, 0.3)
		3:
			sprite.modulate = Color(1.0, 0.4, 0.4)

extends StaticBody2D

signal destroyed

var hits := 1

@onready var sprite = $texture
@onready var hit_brick = $"../../hit_brick"
@onready var destroy_brick = $"../../destroy_brick"
@onready var label = $Label
@onready var collider = $collider

var is_dying := false

func set_hits(value: int):
	hits = value
	update_visual()

func hit():
	hits -= 1
	if hits <= 0:
		destroy_brick.play()
		destroyed.emit()
		play_destroy_effect()
		queue_free()
	else:
		hit_brick.play()
		update_visual()
		

func update_visual():
	#label.visible = hits > 1
	label.text = str(hits)
	match hits:
		1:
			sprite.modulate = Color(0.4, 0.8, 1.0)
		2:
			sprite.modulate = Color(1.0, 0.8, 0.3)
		3:
			sprite.modulate = Color(1.0, 0.4, 0.4)
			
func play_destroy_effect():
	is_dying = true

	collider.disabled = true

	var tween = create_tween()
	tween.parallel().tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.08)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.08)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.08)

	await tween.finished
	queue_free()			

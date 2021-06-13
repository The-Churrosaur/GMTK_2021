extends Node2D

var Rope = preload("res://Scenes/Rope/Parts/Rope.tscn")
var rope : Node2D
var start_pos : Vector2 = Vector2.ZERO
var end_pos : Vector2 = Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton and !event.is_pressed():
		# If first click, set start posiition
		if start_pos == Vector2.ZERO:
			start_pos = get_global_mouse_position()
		# If second, set end position
		elif end_pos == Vector2.ZERO:
			end_pos = get_global_mouse_position()
			# Instantiate rope object, add to scene
			rope = Rope.instance()
			add_child(rope)
			
			rope.spawn_rope(start_pos, end_pos)
			
			# Reset variables to be ready for new rope
			start_pos = Vector2.ZERO
			end_pos = Vector2.ZERO

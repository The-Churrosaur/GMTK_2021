extends Button

export var scene = "res://Scenes/Levels/scroller.tscn"

func _ready():
	connect("button_down", self, "_button_pressed")

func _button_pressed():
	print("button pressed")
	get_tree().paused = false
	get_tree().change_scene(scene)

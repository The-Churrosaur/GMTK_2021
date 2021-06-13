extends Area2D

signal grab_area_entered(area)
signal climber_entered()

func _ready():
	connect("area_entered", self, "on_area_entered")
	connect("body_entered", self, "on_body_entered")

func on_area_entered(area):
	if area.is_in_group("GrabArea"):
		emit_signal("grab_area_entered", area)

func on_body_entered(body):
	emit_signal("climber_entered")

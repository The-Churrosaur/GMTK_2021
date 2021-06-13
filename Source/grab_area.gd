class_name ClimbArea
extends Area2D


func _ready():
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self, "on_body_exited")

func on_body_entered(body):
	
	# tells climber it can grab in here
	if body.is_in_group("Climber"):
		body.enter_grab_area()

func on_body_exited(body):
	
	# tells climber it can no longer grab in here
	if body.is_in_group("Climber"):
		print(body.name, " left area")
		body.leave_grab_area()

# ** potentially bugs if body is in multiple areas at the same time

extends AnimatedSprite

onready var climber = get_parent()

func _process(delta):
	if climber.movement == climber.WALKING:
		if climber.move_vector == Vector2.ZERO:
			play("idle")
		else:
			play("walk")
	elif climber.movement == climber.FALLING:
		play("swing")
	elif climber.movement == climber.GRABBING:
		if climber.move_vector == Vector2.ZERO:
			play("climbidle")
		else:
			play("climb")

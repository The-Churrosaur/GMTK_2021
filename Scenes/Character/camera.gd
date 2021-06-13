extends Camera2D

export var climber1_path : NodePath
export var climber2_path : NodePath
export var sprite_path : NodePath

onready var climber1 = get_node(climber1_path)
onready var climber2 = get_node(climber2_path)

onready var sprite = get_node(sprite_path)

func _physics_process(delta):
	
	# set camera position to halfway between 1 and 2
	# climber a to climber b
	var atob = climber2.global_position - climber1.global_position
	global_position = climber1.global_position + atob / 2
	
#	sprite.position = lerp(sprite.position, position, .5)
#TODO

extends Camera2D

export var climber1_path : NodePath
export var climber2_path : NodePath
export var sprite_path : NodePath

onready var climber1 = get_node(climber1_path)
onready var climber2 = get_node(climber2_path)

export var decay = 2
export var max_offset = Vector2(50, 25)  # Maximum hor/ver shake in pixels.
export var max_roll = 0.05
var trauma = 0.0
var trauma_power = 2

onready var sprite = get_node(sprite_path)

func _ready():
	add_trauma(1)

func _physics_process(delta):
	
	# set camera position to halfway between 1 and 2
	# climber a to climber b
	var atob = climber2.global_position - climber1.global_position
	global_position = climber1.global_position + atob / 2
	
	sprite.position = lerp(sprite.position, position, .5)
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range(-1, 1)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)

class_name Controller
extends Node

# controls and a little bit of level logic for now

export var climber1_path : NodePath
export var climber2_path : NodePath
export var rope_path : NodePath

onready var climber1 = get_node(climber1_path)
onready var climber2 = get_node(climber2_path)
onready var rope = get_node(rope_path)

func _ready():
	rope.call_deferred("spawn_rope",climber1.global_position, climber2.global_position )
	rope.call_deferred("connect_to_objects",climber1, climber2)

func _input(event):
	
	# test
	if event.is_action_pressed("ui_end"):
		pass
#		rope.change_elasticity(0.001)
	
	# grabbing
	if event.is_action_pressed("ui_accept"):
		if climber1.movement == climber1.FALLING or climber1.movement == climber1.WALKING:
			climber1.try_set_grabbing()
		elif climber1.movement == climber1.GRABBING:
			climber1.release_grab()
	
	if event.is_action_pressed("p2_grab"):
		if climber2.movement == climber2.FALLING or climber2.movement == climber2.WALKING:
			climber2.try_set_grabbing()
		elif climber2.movement == climber2.GRABBING:
			climber2.release_grab()
	
	# jump
	if event.is_action_pressed("ui_jump"):
		print("jumping from controller")
		climber1.set_jump()
	if event.is_action_pressed("p2_jump"):
		print("jumping from controller")
		climber2.set_jump()
		
#	if Input.is_action_just_released("ui_left"):
#		climber1.set_move(Vector2.RIGHT)
#	if Input.is_action_just_released("ui_right"):
#		climber1.set_move(Vector2.LEFT)
#	if Input.is_action_just_released("ui_up"):
#		climber1.set_move(Vector2.DOWN)
#	if Input.is_action_just_released("ui_down"):
#		climber1.set_move(Vector2.UP)

func _physics_process(delta):
	
	# climber walking
	
	# move in set direction
	var climber1_move_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left"):
		climber1_move_vector += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		climber1_move_vector += Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		climber1_move_vector += Vector2.UP
	if Input.is_action_pressed("ui_down"):
		climber1_move_vector += Vector2.DOWN
	
	climber1.set_move(climber1_move_vector)
	
	var climber2_move_vector = Vector2.ZERO
	
	if Input.is_action_pressed("p2_left"):
		climber2_move_vector += Vector2.LEFT
	if Input.is_action_pressed("p2_right"):
		climber2_move_vector += Vector2.RIGHT
	if Input.is_action_pressed("p2_up"):
		climber2_move_vector += Vector2.UP
	if Input.is_action_pressed("p2_down"):
		climber2_move_vector += Vector2.DOWN
	
	climber2.set_move(climber2_move_vector)

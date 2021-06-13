class_name Climber
extends RigidBody2D

export var walk_impuse : float = 1000
export var jump_impulse : float = 20000
export var climb_speed : float = 100

export var walking_damp : float = 10
export var falling_damp : float = 0.5

onready var kinematic_anchor = $KinematicAnchor
onready var joint = $KinematicAnchor/PinJoint2D
onready var rope_joint = $RopePin

# GAMEPLAY FLAGS ==========

# set by areas, collisions
var in_grabbable_area : bool = false
var grabbable_counter : int = 0

# current movement type
enum {FALLING,GRABBING,WALKING}
var movement = FALLING

# flags
var move_vector : Vector2 = Vector2.ZERO
# consumed in process
var flag_should_jump = false

var queue_become_rigid = false
var queue_become_kinematic = false

# FUNCS

func _ready():
	
	print("rope joint: ", rope_joint)
	
	# connect collision signals
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self, "on_body_exited")
	
	set_falling()

func _physics_process(delta):
	
	# changing modes: done in here to be safe for reasons
	
	# movement
	if movement == WALKING or movement == GRABBING:
		move(delta)
	if flag_should_jump:
		jump(delta)
		flag_should_jump = false

func on_body_entered(body):
	
	print("a body entered")
	
	# for ie. a climbeable kinematic body
	if body.is_in_group("GrabArea"):
		print ("grabarea")
		in_grabbable_area = true
	
	# enter platform
	if body.is_in_group("WalkSurface"):
		print("walksurface")
		set_walking(body)

func on_body_exited(body):
	
	# for ie. a climbeable kinematic body
	if body.is_in_group("GrabArea"):
		in_grabbable_area = false
	
	# fall off platform
	if movement == WALKING:
		movement = FALLING


# SET MOVEMENT MODES ==========

# called by grab area
func enter_grab_area():
	grabbable_counter += 1

func leave_grab_area():
	grabbable_counter -= 1
	if grabbable_counter <= 0:
		set_falling()
		grabbable_counter = 0

# public, called by controller
func try_set_grabbing():
	if grabbable_counter >= 1:
		movement = GRABBING
		anchor_kinematic()

# called on impact with walkable surface
func set_walking(surface):
	print("walking set")
	movement = WALKING
	linear_damp = walking_damp

# public, will 'fallthrough' to walking if can
func set_falling():
	print ("falling set")
	movement = FALLING
	linear_damp = falling_damp
	release_kinematic()


# MOVEMENT ==========


func set_move(dir : Vector2):
	move_vector = dir
#	print ("vector set: ", move_vector)

func set_jump():
	print ("jumping in climber")
	if movement != FALLING:
		flag_should_jump = true

# move functions called in physics process =====

func jump(delta):
	apply_central_impulse((Vector2.UP + move_vector).normalized() * jump_impulse * delta)

func move(delta):
	
	# walk on surface
	if movement == WALKING:
#		print("moving, vector: ", move_vector)
		# walk force only in x
		apply_central_impulse(Vector2(move_vector.x,0).normalized() * walk_impuse * delta) 
#		print("pos: ", global_position)
	
	# climb on wall
	if movement == GRABBING:
		
		# move anchor
		kinematic_anchor.position += move_vector.normalized() * climb_speed * delta

# kinematic body functions =====

func anchor_kinematic():
	
	print("parenting anchor")
	# reparent anchor
	remove_child(kinematic_anchor)
	get_parent().add_child(kinematic_anchor)
	kinematic_anchor.global_position = global_position
	
	# set joint
	joint.node_b = joint.get_path_to(self)

func release_kinematic():
	
	print("unparenting anchor")
	get_parent().remove_child(kinematic_anchor)
	add_child(kinematic_anchor)
	kinematic_anchor.global_position = global_position
	
	joint.node_b = ""

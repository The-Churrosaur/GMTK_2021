class_name Climber
extends RigidBody2D

enum {FALLING,GRABBING,WALKING}

export var walk_impuse : float = 3000
export var jump_impulse : float = 20000
export var swing_impulse : float = 300
export var swing_out : float = -300 # false centrifugal force outwards
export var climb_speed : float = 100
export var parter_slow_factor = 2
export var partner_max_distance = 200
export var walking_weight = 1
export var falling_weight = .5
export var launch_distance = 175
export var launch_impulse = 100000

export var walking_damp : float = 10
export var falling_damp : float = 0.1

export var other_climber_path : NodePath
export var rope_path : NodePath

export var spriteframes : SpriteFrames

onready var other_climber = get_node(other_climber_path)
onready var rope = get_node(rope_path)
onready var kinematic_anchor = $KinematicAnchor
onready var joint = $KinematicAnchor/PinJoint2D
onready var rope_joint = $RopePin

# GAMEPLAY FLAGS ==========

# set by areas, collisions
var in_grabbable_area : bool = false
var grabbable_counter : int = 0
var on_surface : bool = false
var queue_launch = false

# current movement type
var movement = FALLING

# flags
var move_vector : Vector2 = Vector2.ZERO
# consumed in process
var flag_should_jump = false



# FUNCS

func _ready():
	
	print("rope joint: ", rope_joint)
	
	# connect collision signals
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self, "on_body_exited")
	
	set_falling()
	
	$AnimatedSprite.frames = spriteframes

func _physics_process(delta):
	
	# changing modes: done in here to be safe for reasons
	
	# movement
	move(delta)
	if flag_should_jump:
		jump(delta)
		flag_should_jump = false
	if queue_launch:
		apply_central_impulse((other_climber.global_position - global_position).normalized() * launch_impulse * delta)
		queue_launch = false
	
	# update rope color
	if should_yeet():
		rope.rope_color = Color.coral
	else:
		rope.rope_color = Color.black

func on_body_entered(body):
	
	print("a body entered")
	
	# for ie. a climbeable kinematic body
	if body.is_in_group("GrabArea"):
		print ("grabarea")
		in_grabbable_area = true
	
	# enter platform
	if body.is_in_group("WalkSurface"):
		on_surface = true
		if movement == FALLING:
			print("walksurface")
			set_walking()

func on_body_exited(body):
	
	# for ie. a climbeable kinematic body
	if body.is_in_group("GrabArea"):
		in_grabbable_area = false
	
	# fall off platform
	if body.is_in_group("WalkSurface"):
		on_surface = false
		if movement == WALKING:
			set_falling()

func should_yeet() -> bool:
	if (global_position - other_climber.global_position).length() > launch_distance:
		return true
	else: 
		return false

# SET MOVEMENT MODES ==========

# called by grab area
func enter_grab_area():
	grabbable_counter += 1

func leave_grab_area():
	grabbable_counter -= 1
	if grabbable_counter <= 0 and movement == GRABBING:
	
		release_grab()

# public, called by controller
func try_set_grabbing():
	
	if grabbable_counter >= 1:
		
		movement = GRABBING
		anchor_kinematic()

func release_grab():
	if should_yeet():
		queue_launch = true
	if on_surface:
		set_walking()
	else:
		set_falling()

# called on impact with walkable surface
func set_walking():
	print("walking set")
	if movement == GRABBING:
		release_kinematic()
	movement = WALKING
	
	linear_damp = walking_damp
	
	

# public, will 'fallthrough' to walking if can
func set_falling():
	print ("falling set")
	if movement == GRABBING:
		release_kinematic()
		
	movement = FALLING
	
	linear_damp = falling_damp
	


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
		# calculates maximum rope distance
		var vector_to_other = global_position - other_climber.global_position
		var distance_to_other = global_position.distance_to(other_climber.position)
		var target_move_vector = move_vector.normalized() * climb_speed * delta
		var target_position = target_move_vector + global_position
		var target_position_distance_to_other = target_position.distance_to(other_climber.global_position)
		
		if(distance_to_other < partner_max_distance):
			kinematic_anchor.move_and_collide(target_move_vector) 
		elif (target_position_distance_to_other < distance_to_other):
			kinematic_anchor.move_and_collide(target_move_vector)
		else:
			
			var adjusted_target_move_vector = target_move_vector.reflect(vector_to_other.tangent().normalized())
			print(adjusted_target_move_vector, target_move_vector, vector_to_other)
			kinematic_anchor.move_and_collide(adjusted_target_move_vector)
			
			
			#provide feedback that movement is blocked PROJECT MOVE VECTOR TO AN APROPRIATE RANGE
	
	# swing 
	if movement == FALLING:
		# apply swing normal to the vector facing other character
		var from_other = other_climber.global_position - global_position
		var tangent_move = move_vector.project(from_other.tangent())
		tangent_move *= swing_impulse
		apply_central_impulse(tangent_move.normalized() * swing_impulse * delta)
		# apply a slight outwards force (false centrifugal)
		if move_vector != Vector2.ZERO:
			apply_central_impulse(from_other.normalized() * swing_out * delta) 

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

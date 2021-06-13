extends CanvasItem

#export var start_pin_path : NodePath
#export var end_pin_path : NodePath

var RopePiece = preload("res://Scenes/Rope/Parts/RopePiece.tscn")
var piece_length := 6.0
var rope_parts := []
var rope_close_tolerance := 8.0
var rope_points : PoolVector2Array = []

#onready var start_pin = get_node(start_pin_path)
#onready var end_pin = get_node(end_pin_path)

onready var rope_start_piece = $RopeStartPiece
onready var rope_end_piece = $RopeEndPiece
onready var rope_start_joint = $RopeStartPiece/Collision/Joint
onready var rope_end_joint = $RopeEndPiece/Collision/Joint

func _process(_delta):
	update_points()
	if !rope_points.empty():
		update()

# EXPECTS node B of the joints to be open
func connect_to_objects(object1, object2):
	rope_start_piece.get_node("joint2").node_a = rope_start_piece.get_path()
	rope_start_piece.get_node("joint2").node_b = object1.get_path()
	
	rope_end_piece.get_node("joint2").node_a = rope_end_piece.get_path()
	rope_end_piece.get_node("joint2").node_b = object2.get_path()
	
func spawn_rope(start_pos : Vector2, end_pos : Vector2):
	# Set the end pieces positions to the given coords
	rope_start_piece.global_position = start_pos
	rope_end_piece.global_position = end_pos
	
	# Then change the coords to the position of the joints
	start_pos = rope_start_joint.global_position
	end_pos = rope_end_joint.global_position
	
	var distance = start_pos.distance_to(end_pos)
	var pieces_amount = round(distance / piece_length)
	var spawn_angle = (end_pos-start_pos).angle() - PI/2
	
	create_rope(pieces_amount, rope_start_piece, end_pos, spawn_angle)
	
	# pin rope to given pins
#	start_joint.node_b = start_joint.get_path_to(rope_start_piece)
#	end_joint.node_b = end_joint.get_path_to(rope_end_piece)

func create_rope(pieces_amount:int, first_piece:Object, end_pos:Vector2, spawn_angle:float):
	# Keep track of pieces so we can link the next piece we make to the previous
	var current_piece : Object = first_piece;
	
	for i in pieces_amount:
		# Add a piece, passing it the piece it should attach to, then keep track of it
		current_piece = add_piece(current_piece, i, spawn_angle)
		current_piece.set_name("rope_piece_"+str(i))
		rope_parts.append(current_piece)
		
		# If this piece's joint is too close to the rope end, break the loop
		var joint_pos = current_piece.get_node("Collision/Joint").global_position
		if joint_pos.distance_to(end_pos) < rope_close_tolerance:
			break
	
	# Link last piece to end piece's node
	rope_end_joint.node_a = rope_parts[-1].get_path()
	# And we have to link the joint to it's own parent piece
	rope_end_joint.node_b = rope_end_piece.get_path()
	
# Add another piece to the end of the given piece
func add_piece(prev:Object, id:int, spawn_angle:float) -> Object:
	var prev_joint : PinJoint2D = prev.get_node("Collision/Joint") as PinJoint2D
	var new_piece : Object = RopePiece.instance() as Object
	
	new_piece.global_position = prev_joint.global_position
	new_piece.rotation = spawn_angle
	new_piece.parent = self # All pieces are children of the rope
	new_piece.id = id
	
	add_child(new_piece)
	
	# Link pieces with joint (prev joint isn't linked to prev until now)
	prev_joint.node_a = prev.get_path()
	prev_joint.node_b = new_piece.get_path()
	
	return new_piece

# Update the list of joint positions
func update_points():
	rope_points = []
	
	# Add the start, all the joint, and the end positions to the array
	rope_points.append(rope_start_joint.global_position)
	for i in rope_parts:
		rope_points.append(i.global_position)
	rope_points.append(rope_end_joint.global_position)

func change_elasticity(new_softness:int):
	var joint : PinJoint2D
	
	for i in rope_parts:
		joint = i.get_node("Collision/Joint") as PinJoint2D
		joint.softness = new_softness

func _draw():
	draw_polyline(rope_points, Color.black)

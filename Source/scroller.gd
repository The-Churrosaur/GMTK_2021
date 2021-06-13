class_name scroller
extends Node2D

export var starting_scroll_speed : float = 1
export var scroll_delta = 0.1
export var spawn_timer : float = 1
export var spawn_table = []
export var max_x = 150 # left or right of camera
export var max_y = 300 # above camera
# spawn radius will increase to max over time
export var max_delta = 2
export var x_limit = 200
export var y_limit = 400
# spawns a new box for every x amount of progress
export var progress_height = 150

export var camera_path : NodePath
export var climber1_path : NodePath
export var climber2_path : NodePath

onready var score_label = $CanvasLayer/UI/MarginContainer/VBoxContainer/ScoreLabel
onready var timer = $SpawnTimer
onready var floor_area = $FloorArea
onready var camera = get_node(camera_path)
onready var climber1 = get_node(climber1_path)
onready var climber2 = get_node(climber2_path)

var scroll_speed = starting_scroll_speed
var scroll_elements = {}
var score = 0
var spawn_time : float = 1

# spawn 
onready var player_last_height = camera.position.y

func _ready():
#	spawn_table.append(preload("res://Scenes/Environment/grab_area.tscn"))
	spawn_table.append(preload("res://Scenes/Environment/grab_area_small.tscn"))
	
#	timer.connect("timeout", self, "spawn_platform")
	floor_area.connect("grab_area_entered", self, "on_area_exited")
	
	spawn_platform()
	spawn_platform()
	spawn_platform()
	
	climber1.try_set_grabbing()
	climber2.try_set_grabbing()

func _physics_process(delta):
	floor_area.position.y -= scroll_speed * delta
	floor_area.position.x = camera.position.x
	
#	score += 1 * delta
	score_label.text = "Score: " + String(int(score)) + " Speed: " + String(int(scroll_speed))
	
	scroll_speed += scroll_delta * delta
	
	# spawn blocks, award points after height progress
	if camera.position.y - player_last_height <= progress_height * -1:
		new_level()

func new_level():
	spawn_platform()
	score += 100
	player_last_height = camera.position.y
	max_x += max_delta
	max_y += max_delta
	if max_x >= x_limit : max_x = x_limit
	if max_y >= y_limit : max_y = y_limit

func on_area_exited(area):
	
	area.get_parent().remove_child(area)
	area.queue_free()
	scroll_elements.erase(area.name)

func spawn_platform():
	print("platform spawning")
	var i = randi() % spawn_table.size()
	print(i)
	var platform = spawn_table[i].instance()
	add_child(platform)
	
	# random pos
	platform.position.x = camera.position.x + rand_range(-max_x, max_x)
	platform.position.y = camera.position.y + rand_range(-max_y, -300)
	
	scroll_elements[platform.name] = platform
	

extends KinematicBody2D

onready var leader = get_parent().get_node("Snake")
onready var sprite = get_node("Sprite")
var arrayPosition
var bodyTexture = load("res://Sprites/SnakeBody.png")
var tailTexture = load("res://Sprites/SnakeTail.png")
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	var colour1 = rng.randf_range(0, 1)
	var colour2 = rng.randf_range(0, 1)
	var colour3 = rng.randf_range(0, 1)
	sprite.set_self_modulate(Color(colour1, colour2, colour3, 1))
	
func SetArrayPosition(var pos):
	arrayPosition = pos
	
func SetTexture():
	if (arrayPosition == leader.snakeArray.size() - 1 && sprite.texture != tailTexture):
		sprite.texture = tailTexture
	elif(arrayPosition != leader.snakeArray.size() - 1 && sprite.texture != bodyTexture):
		sprite.texture = bodyTexture

func _physics_process(delta):
	SetTexture()
	global_position = leader.snakeArray[arrayPosition]

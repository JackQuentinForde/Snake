extends StaticBody2D

onready var snake = get_parent().get_node("Snake")
	
func _process(delta):
	global_position = snake.applePosition
	visible = !snake.appleSpawning

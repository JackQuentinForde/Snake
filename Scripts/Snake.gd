extends KinematicBody2D

var speed = 16
var delay = 0.15
var timer = Timer.new()
var swipeStart = null
var minimum_drag = 100
var direction = "up"
var queuedDirection = "up"
var lastPosition
var newPosition
var applePosition
var appleSpawning = true
var snakeArray = []
var rng = RandomNumberGenerator.new()
var snakeBody = load("res://Scenes/SnakeBody.tscn")
onready var globalScript = get_node("/root/Global")
onready var score = get_parent().get_node("Score")
onready var highScore = get_parent().get_node("Highscore")
onready var appleSound = get_node("AppleSound")

func _ready():
	highScore.text = "HI: " + globalScript.ReadHighScore()
	snakeArray.append(global_position)
	SpawnApple()
	AddSegment()
	AddSegment()
	AddSegment()
	timer.wait_time = delay
	timer.one_shot = true
	add_child(timer)
	timer.start()
	
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			swipeStart = event.get_position()
		else:
			_calculate_swipe(event.get_position())
			
func _calculate_swipe(swipeEnd):
	if (swipeStart == null or queuedDirection != null): 
		return
	var swipeDirection = (swipeEnd - swipeStart).normalized()
	if (abs(swipeDirection.x) > abs(swipeDirection.y)):
		if (swipeDirection.x > 0):
			if (direction != "left"):
				queuedDirection = "right"
		else:
			if (direction != "right"):
				queuedDirection = "left"
	else:
		if (swipeDirection.y > 0):
			if (direction != "up"):
				queuedDirection = "down"
		else:
			if (direction != "down"):
				queuedDirection = "up"

func GetInput():
	if (queuedDirection == null):
		if (Input.is_action_pressed("right") && direction != "left"):
			queuedDirection = "right"
		if (Input.is_action_pressed("left") && direction != "right"):
			queuedDirection = "left"
		if (Input.is_action_pressed("down") && direction != "up"):
			queuedDirection = "down"
		if (Input.is_action_pressed("up") && direction != "down"):
			queuedDirection = "up"
		if (Input.is_action_pressed("ui_cancel")):
			GameOver()
		
func SetDirection():
	if (queuedDirection != null):
		direction = queuedDirection

func Move():
	match direction:
		"up":
			get_node("Sprite").rotation_degrees = 0
			newPosition = Vector2(lastPosition.x, lastPosition.y - speed)
		"right":
			get_node("Sprite").rotation_degrees = 90
			newPosition = Vector2(lastPosition.x + speed, lastPosition.y)
		"down":
			get_node("Sprite").rotation_degrees = 180
			newPosition = Vector2(lastPosition.x, lastPosition.y + speed)
		"left":
			get_node("Sprite").rotation_degrees = -90
			newPosition = Vector2(lastPosition.x - speed, lastPosition.y)
			
	if (newPosition.x < 0):
		newPosition.x = 320
	elif (newPosition.x > 320):
		newPosition.x = 0
		
	if (newPosition.y < 0):
		newPosition.y = 320
	elif (newPosition.y > 320):
		newPosition.y = 0
			
func SetPositions():
	var i = snakeArray.size() - 1
	while i > 0:
		var segment = get_parent().get_node("SnakeBody" + str(i))
		if (snakeArray[i].x != snakeArray[i-1].x):
			if (snakeArray[i].x > snakeArray[i-1].x):
				segment.rotation_degrees = -90
			else:
				segment.rotation_degrees = 90
		else:
			if (snakeArray[i].y > snakeArray[i-1].y):
				segment.rotation_degrees = 0
			else:
				segment.rotation_degrees = 180
		snakeArray[i] = snakeArray[i-1]
		i = i-1
	
	if (WillCollide()):
		GameOver()
	else:
		snakeArray[0] = newPosition
		if (newPosition == applePosition):
			AddSegment()
			SpawnApple()
			
func WillCollide():
	if (snakeArray.has(newPosition)):
		return true
	return false
	
func AddSegment():
	snakeArray.append(snakeArray[snakeArray.size() - 1])
	var newSegment = snakeBody.instance()
	newSegment.set_name("SnakeBody" + str(snakeArray.size() - 1))
	newSegment.arrayPosition = snakeArray.size() - 1
	get_parent().call_deferred("add_child", newSegment)
	score.text = str(snakeArray.size() - 4)
	if (int(score.text) > int(globalScript.ReadHighScore())):
		highScore.text = "HI: " + score.text
	
func SpawnApple():
	appleSpawning = true
	var newSpawn = snakeArray[0]
	while (snakeArray.has(newSpawn)):
		rng.randomize()
		var x = rng.randi_range(16, 304)
		if (x % 16 != 0):
			x = x - (x % 16)
		var y = rng.randi_range(16, 304)
		if (y % 16 != 0):
			y = y - (y % 16)
		newSpawn = Vector2(x, y)
	appleSound.play()
	applePosition = newSpawn
	appleSpawning = false
		
func GameOver():
	globalScript.SaveScore(score.text)
	get_tree().change_scene("res://Scenes/Game Over.tscn")

func _physics_process(delta):
	lastPosition = snakeArray[0]
	GetInput()
	if (timer.time_left == 0):
		SetDirection()
		Move()
		SetPositions()
		global_position = snakeArray[0]
		queuedDirection = null
		timer.start()

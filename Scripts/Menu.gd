extends Control

onready var globalScript = get_node("/root/Global")
onready var highScore = get_node("Highscore")

func _ready():
	highScore.text = "HI: " + globalScript.ReadHighScore()

func _input(event):
	if (event is InputEventKey or event is InputEventJoypadButton or event is InputEventScreenTouch) and event.pressed:
		get_tree().change_scene("res://Scenes/Game.tscn")

extends Node

var saveGame = File.new()
var savePath = "user://highscore.save"

func ReadHighScore():
	saveGame.open(savePath, File.READ)
	var data = saveGame.get_as_text()
	saveGame.close()
	if(data != null && data):
		return data
	return "0"

func SaveScore(score):
	var highScore = ReadHighScore()
	if (int(score) > int(highScore)):
		saveGame.open(savePath, File.WRITE)
		saveGame.store_string(score)
		saveGame.close()

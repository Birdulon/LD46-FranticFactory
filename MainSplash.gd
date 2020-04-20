extends Control

signal start_pressed

func _ready():
	pass

func _on_StartButton_pressed():
	emit_signal("start_pressed")

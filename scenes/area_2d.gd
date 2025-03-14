extends Area2D

@export var sceneName: String = "Level"

func _on_body_entered(body):
	if body.get_name() == "Player2":
		get_tree().change_scene_to_file(str("res://scenes/" + sceneName + ".tscn"))

extends Node2D

@onready var Player = $"../Player/CharacterBody2D"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Player:
		print("exit")
		$"../AnimationPlayer".play("fade_in")
		await $"../AnimationPlayer".animation_finished
		get_tree().change_scene_to_file("res://scenes/levels/level_01/level_01.tscn")

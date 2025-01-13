extends Node2D

@onready var Player = $"../../../Player/CharacterBody2D"
var is_open = false
var detected = 0

func _on_open_range_body_entered(body: Node2D) -> void:
	print(body)
	if body == Player:
		print("Gracz otwiera drzwi.")
		detected += 1
		open_door()


func _on_open_range_body_exited(body: Node2D) -> void:
	if body == Player:
		detected -= 1
		close_door()


func open_door():
	if($StaticBody2D/AnimationPlayer.is_playing()):
		await $StaticBody2D/AnimationPlayer.animation_finished
	$StaticBody2D/AnimationPlayer.play("open")
	
	
func close_door():
	if($StaticBody2D/AnimationPlayer.is_playing()):
		await $StaticBody2D/AnimationPlayer.animation_finished
	$StaticBody2D/AnimationPlayer.play("close")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

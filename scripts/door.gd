extends Node2D

@onready var Player = $"../../../Player/CharacterBody2D"
@onready var AudioOpen = $StaticBody2D/AudioStreamPlayerOpen
var is_open = false
var detected = 0

func _on_open_range_body_entered(body: Node2D) -> void:
	print(body)
	if body == Player or body.name.contains("Enemy"):
		print("Gracz otwiera drzwi.")
		detected += 1
		if !is_open:
			open_door()


func _on_open_range_body_exited(body: Node2D) -> void:
	if body == Player or body.name.contains("Enemy"):
		detected -= 1
		if detected <= 0:
			close_door()


func open_door():
	if($StaticBody2D/AnimationPlayer.is_playing()):
		await $StaticBody2D/AnimationPlayer.animation_finished
	$StaticBody2D/AnimationPlayer.play("open")
	AudioOpen.play()
	is_open = true;
	
	
func close_door():
	if($StaticBody2D/AnimationPlayer.is_playing()):
		await $StaticBody2D/AnimationPlayer.animation_finished
	$StaticBody2D/AnimationPlayer.play("close")
	AudioOpen.play()
	is_open = false;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node2D

@onready var Player = $"/root/Main/Player/CharacterBody2D"
@onready var Enemy = $"/root/Main/Enemy01/CharacterBody2D"
var is_open = false
var detected = 0


func _on_open_range_body_entered(body: Node2D) -> void:
	print(body)
	if body == Player or body == Enemy:
		print("Gracz otwiera drzwi.")
		detected += 1
		open_door()


func _on_open_range_body_exited(body: Node2D) -> void:
	if body == Player or body == Enemy:
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

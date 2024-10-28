extends CharacterBody2D

@export var speed = 500

var direction = 0.0
var spawnPos = Vector2.ZERO
var spawnRot = 0.0

func _ready():
	global_position = spawnPos
	rotation = spawnRot

func _physics_process(delta):
	velocity = Vector2.RIGHT.rotated(direction) * speed
	move_and_slide()

func _on_area_2D_body_entered(body):
	print("HIT!")
	queue_free()

func _on_life_timeout():
	queue_free()

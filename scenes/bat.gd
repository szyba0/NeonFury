extends "res://scenes/weapon_base.gd"
var can_attack: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage = 5
	ammo = -1
	weapon_type = "Bat"
	is_melee = true
	fire_rate = 0.4

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		$CollisionShape2D.disabled = true

func _on_melee_weapon_base_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)

func hit() -> void:
	if can_attack:
		$CollisionShape2D.disabled = false
		$AnimationPlayer.play("hit")
		can_attack = false
		await get_tree().create_timer(fire_rate).timeout
		can_attack = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.get_parent().name == "Player":
		global_position = get_parent().global_position
		self.rotation = (get_global_mouse_position() - global_position).normalized().angle()		



func _on_tree_entered() -> void:
	if self.get_parent().name == "CharacterBody2D":
		$CollisionShape2D.set_deferred("disabled",true)

extends Control
var music = AudioServer.get_bus_index("Music")
var sfx = AudioServer.get_bus_index("SFX")

var sfx_volume = 1
var music_volume = 1

var options_save_path = "res://options.save"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_data()
	$HSlider_sfx.value = sfx_volume
	$HSlider_music.value = music_volume
	#$AnimationPlayer.play("fade_out")
	#await $AnimationPlayer.animation_finished


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_return_button_pressed() -> void:
	self.visible = false
	self.get_parent().get_node("MainMenuNode").visible = true


func _on_h_slider_sfx_mouse_exited() -> void:
	release_focus()


func _on_h_slider_music_mouse_exited() -> void:
	release_focus()


func _on_h_slider_sfx_value_changed(value: float) -> void:
	sfx_volume = $HSlider_sfx.value
	AudioServer.set_bus_volume_db(sfx,linear_to_db(value))
	save()


func _on_h_slider_music_value_changed(value: float) -> void:
	music_volume = $HSlider_music.value
	AudioServer.set_bus_volume_db(music,linear_to_db(value))
	save()

func save():
	var file = FileAccess.open(options_save_path,FileAccess.WRITE)
	file.store_var(sfx_volume)
	file.store_var(music_volume)

func load_data():
	if FileAccess.file_exists(options_save_path):
		var file = FileAccess.open(options_save_path,FileAccess.READ)
		sfx_volume = file.get_var(sfx_volume)
		music_volume = file.get_var(music_volume)
	else:
		print("No data saved")
		sfx_volume = 1
		music_volume = 1

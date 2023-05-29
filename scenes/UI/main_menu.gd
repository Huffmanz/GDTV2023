extends CanvasLayer

@onready var how_to_play: PackedScene = preload("res://scenes/UI/how_to_play.tscn")

func _ready():
	$%PlayButton.pressed.connect(on_play_pressed)
	$%HowToPlayButton.pressed.connect(on_how_play_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)
	MusicPlayer.play_normal()

func on_play_pressed():
	LevelManager.change_levels()
	
func on_how_play_pressed():
	var how_to_play_instance = how_to_play.instantiate()
	add_child(how_to_play_instance)
	how_to_play_instance.back_pressed.connect(on_how_closed.bind(how_to_play_instance))

func _process(delta):
	if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func on_quit_pressed():
	get_tree().quit()

func on_how_closed(how_to_play_instance: Node):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	how_to_play_instance.queue_free()
	
func on_options_closed(options_instance: Node):
	options_instance.queue_free()
	

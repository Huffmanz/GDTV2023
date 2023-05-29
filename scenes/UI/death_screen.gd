extends CanvasLayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$%MainMenu.pressed.connect(on_menu_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)
	MusicPlayer.play_normal()
	%LevelsCleared.text = "You cleared " + str(LevelManager.current_level - 1) + " Levels" 
	
func on_menu_pressed():
	LevelManager.main_menu()
	
func on_quit_pressed():
	get_tree().quit()


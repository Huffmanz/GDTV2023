extends CanvasLayer

signal back_pressed

@onready var back_button = $%BackButton
var is_closing = false

func _ready():
	back_button.pressed.connect(on_back_pressed)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func close():
	if is_closing:
		return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	is_closing = true
	get_tree().paused = false
	back_pressed.emit()
	queue_free()

func on_back_pressed():
	close()

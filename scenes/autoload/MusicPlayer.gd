extends AudioStreamPlayer

@export var normal_music: AudioStream
@export var pandemonium_music: AudioStream

func _ready():
	play_normal()
	finished.connect(on_finished)
	$Timer.timeout.connect(on_timer_timeout)
	
func on_finished():
	$Timer.start()

func on_timer_timeout():
	play()

func play_normal():
	stop()
	stream = normal_music
	play()

func play_pandemonium():
	stop()
	stream = pandemonium_music
	play()

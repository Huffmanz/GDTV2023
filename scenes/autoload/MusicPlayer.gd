extends AudioStreamPlayer

@export var normal_music: AudioStreamMP3
@export var pandemonium_music: AudioStreamOggVorbis

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

func pandemonium_normal():
	stop()
	stream = pandemonium_music
	play()

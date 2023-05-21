extends CanvasLayer

@onready var damage_texture : TextureRect = $DamageTexture
@onready var animation_player = $AnimationPlayer

func _ready():
	PlayerStats.PlayerDamaged.connect(on_player_damaged)
	animation_player.play("RESET")

func Damaged():
	$AnimationPlayer.play("Pain")
	
func DisplayOverlay(percent):
	var alpha = percent * 255
	damage_texture.modulate.a = alpha
	
func on_player_damaged():
	animation_player.play("Pain")

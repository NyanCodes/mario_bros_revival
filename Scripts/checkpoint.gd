class_name Checkpoint
extends Area2D

## Moves the player's respawn point. Without these a 400-tile troll stage
## sends you back to tile 3 every single death, which is punishment rather
## than difficulty.

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D

var _armed := true


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_anim.play("idle")


func _on_body_entered(body: Node2D) -> void:
	if not _armed or not body.has_method("set_spawn"):
		return
	_armed = false
	body.set_spawn(global_position)
	Audio.sfx(&"checkpoint", 0.0, 0.0)
	_anim.play("out")

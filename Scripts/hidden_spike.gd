class_name HiddenSpike
extends Area2D

## A spike with no sprite showing - until it kills you once, after which it
## stays visible. Deliberately NOT in the "resettable" group: the reveal has
## to survive your death, or the level is just unfair rather than cruel.

@export var reveal_after_kill := true

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_sprite.visible = false


func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("die"):
		return
	if reveal_after_kill:
		_sprite.visible = true
	body.die()

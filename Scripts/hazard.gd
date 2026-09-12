class_name Hazard
extends Area2D

## Touch it and you die. Spikes, saws, fire - anything lethal on contact.
## Stateless, so it needs no reset().


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()

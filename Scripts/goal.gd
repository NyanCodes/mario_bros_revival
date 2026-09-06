class_name Goal
extends Area2D

## The end-of-stage flag.

signal reached

var _done := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _done or not body.has_method("die"):
		return
	_done = true
	reached.emit()

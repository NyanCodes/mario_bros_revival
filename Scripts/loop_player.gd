extends AudioStreamPlayer2D

## A positional ambient loop for saws and fire. Restarting on `finished`
## avoids depending on the WAV's import-time loop flag, which is easy to lose
## on a reimport.
##
## Being positional is the point: a saw you cannot see yet is audible, which
## in a level this cluttered is a fair warning rather than a nasty surprise.

func _ready() -> void:
	bus = &"SFX"
	finished.connect(play)
	play()

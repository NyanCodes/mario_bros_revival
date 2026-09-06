extends Node

## Global sound, autoloaded as `Audio`. Call it from anywhere: Audio.sfx("coin")
##
## Sounds play from a pool owned by this singleton, never from the node that
## triggered them. A coin that hides itself, an enemy that frees itself or a
## projectile that despawns would otherwise cut its own sound off mid-play.
##
## Every call is pitch-randomised. In a stage with 189 fruit and ten invisible
## spikes you hear these hundreds of times a run, and identical repeats are
## what make game audio grating.

const POOL_SIZE := 14

const SOUNDS := {
	&"jump": preload("res://Assets/Audio/jump.wav"),
	&"land": preload("res://Assets/Audio/land.wav"),
	&"coin": preload("res://Assets/Audio/coin.wav"),
	&"block_bump": preload("res://Assets/Audio/block_bump.wav"),
	&"crumble": preload("res://Assets/Audio/crumble.wav"),
	&"stomp": preload("res://Assets/Audio/stomp.wav"),
	&"cannon": preload("res://Assets/Audio/cannon.wav"),
	&"death": preload("res://Assets/Audio/death.wav"),
	&"checkpoint": preload("res://Assets/Audio/checkpoint.wav"),
	&"stage_clear": preload("res://Assets/Audio/stage_clear.wav"),
}

const MUSIC := {
	&"stage1": preload("res://Assets/Audio/solstice.ogg"),
}

var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _music: AudioStreamPlayer
var _music_name := &""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = &"SFX"
		add_child(p)
		_pool.append(p)
	_music = AudioStreamPlayer.new()
	_music.bus = &"Music"
	add_child(_music)


## `spread` is the pitch jitter, ±fraction. Pass 0.0 for sounds that must
## sound identical every time (a fanfare, say).
func sfx(name: StringName, volume_db := 0.0, spread := 0.08) -> void:
	var stream: AudioStream = SOUNDS.get(name)
	if stream == null:
		push_warning("Audio.sfx: no sound named '%s'" % name)
		return
	var p := _pool[_next]
	_next = (_next + 1) % _pool.size()
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = 1.0 + randf_range(-spread, spread)
	p.play()


func set_bus_volume(bus: StringName, linear: float) -> void:
	var i := AudioServer.get_bus_index(bus)
	if i >= 0:
		AudioServer.set_bus_volume_db(i, linear_to_db(clampf(linear, 0.0, 1.0)))


## Starts a looping track on the Music bus. Each stage can name its own, so
## Stage 2 and 3 only need a different key here.
func play_music(name: StringName, volume_db := -11.0) -> void:
	var stream: AudioStream = MUSIC.get(name)
	if stream == null:
		push_warning("Audio.play_music: no track named '%s'" % name)
		return
	# Menu to stage, and stage to stage, share a track. Restarting it there
	# would snap the music back to bar one on every scene change.
	if _music.playing and _music_name == name:
		return
	_music_name = name
	_music.stream = _looped(stream)
	_music.volume_db = volume_db
	_music.play()


func stop_music() -> void:
	_music_name = &""
	_music.stop()


## Godot only loops a WAV if its import flag says so, and that flag is easy to
## lose on a reimport. Setting it on a duplicate of the stream keeps the loop
## working regardless of how the file was imported.
##
## loop_end is derived from length x mix_rate rather than from the byte count,
## so it stays correct whether the importer produced plain PCM or a compressed
## format.
func _looped(stream: AudioStream) -> AudioStream:
	if stream is AudioStreamWAV:
		var w: AudioStreamWAV = stream.duplicate()
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = int(w.get_length() * w.mix_rate)
		return w
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		var c: AudioStream = stream.duplicate()
		c.set("loop", true)
		return c
	return stream

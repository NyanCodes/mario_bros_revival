extends Control

## Title screen: Start Game / Controls / Settings / Quit.
##
## The controls list is built from the InputMap at runtime rather than typed
## out here, so rebinding a key in Project Settings updates this screen too
## instead of quietly making it a lie.

const STAGE := "res://Scenes/Stage1.tscn"

## Action name -> the label the player should see, in the order shown.
const ACTIONS: Array[Array] = [
	[&"move_left", "Move left"],
	[&"move_right", "Move right"],
	[&"jump", "Jump"],
]

@onready var _menu: Control = $Menu
@onready var _controls: Control = $ControlsPanel
@onready var _keys: GridContainer = $ControlsPanel/Box/Keys
@onready var _start_button: Button = $Menu/Buttons/Start
@onready var _settings: Control = $SettingsPanel


func _ready() -> void:
	$Menu/Buttons/Start.pressed.connect(_on_start)
	$Menu/Buttons/Controls.pressed.connect(_show_controls)
	$Menu/Buttons/Settings.pressed.connect(_show_settings)
	$SettingsPanel/Box/Back.pressed.connect(_leave_settings)
	for bus in Audio.VOLUME_BUSES:
		var row := _settings.get_node("Box/" + str(bus))
		var slider := row.get_node("Slider") as HSlider
		var value_label := row.get_node("Value") as Label
		slider.value = roundf(Audio.get_bus_volume(bus) * 100.0)
		value_label.text = "%d%%" % slider.value
		slider.value_changed.connect(func(value: float) -> void:
			Audio.set_bus_volume(bus, value / 100.0)
			value_label.text = "%d%%" % value
		)
	$Menu/Buttons/Quit.pressed.connect(_on_quit)
	$ControlsPanel/Box/Back.pressed.connect(_show_menu)

	_fill_controls()
	_show_menu()

	# A stage reload leaves the tree paused if the player quit from a menu.
	get_tree().paused = false
	Audio.play_music(&"stage1")


## Escape backs out of the controls page, and quits from the title itself.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	if _settings.visible:
		_leave_settings()
	elif _controls.visible:
		_show_menu()
	else:
		_on_quit()


## Two labels per action, filling the two-column grid.
func _fill_controls() -> void:
	for child in _keys.get_children():
		_keys.remove_child(child)
		child.queue_free()
	for entry in ACTIONS:
		var what := Label.new()
		what.text = entry[1]
		_keys.add_child(what)

		var keys := Label.new()
		keys.text = _keys_for(entry[0])
		keys.modulate = Color(1, 0.898, 0.529)
		keys.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		keys.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_keys.add_child(keys)


## Every key bound to an action, joined - "A  /  Left".
func _keys_for(action: StringName) -> String:
	if not InputMap.has_action(action):
		return "unbound"
	var names: Array[String] = []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			names.append(event.as_text_physical_keycode())
	return "  /  ".join(names) if names.size() > 0 else "unbound"


func _show_menu() -> void:
	_menu.visible = true
	_controls.visible = false
	_settings.visible = false
	_start_button.grab_focus()


func _show_controls() -> void:
	_menu.visible = false
	_controls.visible = true
	$ControlsPanel/Box/Back.grab_focus()


func _show_settings() -> void:
	_menu.visible = false
	_controls.visible = false
	_settings.visible = true
	$SettingsPanel/Box/Master/Slider.grab_focus()


func _leave_settings() -> void:
	Audio.save_volume_settings()
	_show_menu()
	$Menu/Buttons/Settings.grab_focus()


func _on_start() -> void:
	get_tree().change_scene_to_file(STAGE)


func _on_quit() -> void:
	get_tree().quit()

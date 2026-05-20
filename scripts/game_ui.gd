extends Control

@export var debug_force_touch_ui_visible: bool = false

@onready var points_label: Label = $Control/img/Label
@onready var touch_controls: Control = $TouchControls
@onready var up_button: BaseButton = $TouchControls/LeftPad/UpButton
@onready var left_button: BaseButton = $TouchControls/LeftPad/LeftButton
@onready var down_button: BaseButton = $TouchControls/LeftPad/DownButton
@onready var right_button: BaseButton = $TouchControls/LeftPad/RightButton
@onready var action_button: BaseButton = $TouchControls/ActionButton

@onready var upbutton: Button = $TouchControls/LeftPad/UpButton/Button
@onready var leftbutton: Button = $TouchControls/LeftPad/LeftButton/Button2
@onready var downbutton: Button = $TouchControls/LeftPad/DownButton/Button3
@onready var rightbutton: Button = $TouchControls/LeftPad/RightButton/Button4


func _ready() -> void:
	var level := get_parent()
	if level == null:
		return

	if level.has_signal("points_changed"):
		level.points_changed.connect(_on_points_changed)

	if level.has_method("get_points"):
		_on_points_changed(level.get_points())

	_setup_touch_controls()


func _on_points_changed(points: int) -> void:
	if points_label == null:
		return
	points_label.text = str(points)


func _setup_touch_controls() -> void:
	if touch_controls == null:
		return

	var touch_available := DisplayServer.is_touchscreen_available() or debug_force_touch_ui_visible
	touch_controls.visible = touch_available
	touch_controls.mouse_filter = Control.MOUSE_FILTER_IGNORE if not touch_available else Control.MOUSE_FILTER_PASS
	if not touch_available:
		return

	_bind_touch_button(up_button, "up")
	_bind_touch_button(left_button, "left")
	_bind_touch_button(down_button, "down")
	_bind_touch_button(right_button, "right")
	_bind_touch_button(action_button, "action")
	
	_bind_touch_button(upbutton, "up")
	_bind_touch_button(leftbutton, "left")
	_bind_touch_button(downbutton, "down")
	_bind_touch_button(rightbutton, "right")


func _bind_touch_button(button: BaseButton, action_name: String) -> void:
	if button == null:
		return

	button.button_down.connect(_emit_touch_action.bind(action_name, true))
	button.button_up.connect(_emit_touch_action.bind(action_name, false))


func _emit_touch_action(action_name: String, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action_name
	event.pressed = pressed
	Input.parse_input_event(event)

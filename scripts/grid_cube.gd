extends Node3D

@export var tile_size: float = 1.0
@export var move_duration: float = 0.2

var _grid_position := Vector2i.ZERO
var _is_moving := false


func _ready() -> void:
	_grid_position = Vector2i(roundi(position.x / tile_size), roundi(position.z / tile_size))
	_snap_to_grid()
	_notify_hover_tile()


func set_tile_size(value: float) -> void:
	tile_size = value
	_grid_position = Vector2i(roundi(position.x / tile_size), roundi(position.z / tile_size))
	_snap_to_grid()
	_notify_hover_tile()


func _unhandled_input(event: InputEvent) -> void:
	if _is_moving:
		return

	if event.is_action_pressed("action"):
		_handle_action_on_current_tile()
		return

	var direction := _direction_from_input(event)
	if direction != Vector2i.ZERO:
		_attempt_move(direction)


func _direction_from_input(event: InputEvent) -> Vector2i:
	if event.is_action_pressed("up"):
		return Vector2i(0, -1)
	if event.is_action_pressed("down"):
		return Vector2i(0, 1)
	if event.is_action_pressed("left"):
		return Vector2i(-1, 0)
	if event.is_action_pressed("right"):
		return Vector2i(1, 0)
	return Vector2i.ZERO


func _attempt_move(direction: Vector2i) -> void:
	var target := _grid_position + direction
	if not _can_enter(target):
		return

	_grid_position = target
	_move_to_grid_position()


func _can_enter(cell: Vector2i) -> bool:
	var level := get_parent()
	if level != null and level.has_method("is_cell_walkable"):
		return level.call("is_cell_walkable", cell)
	return true


func _snap_to_grid() -> void:
	position.x = _grid_position.x * tile_size
	position.z = _grid_position.y * tile_size


func _move_to_grid_position() -> void:
	_is_moving = true
	var target_position := Vector3(_grid_position.x * tile_size, position.y, _grid_position.y * tile_size)
	var tween := create_tween()
	tween.tween_property(self, "position", target_position, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func() -> void:
		_notify_hover_tile()
		_is_moving = false
	)


func _notify_hover_tile() -> void:
	var level := get_parent()
	if level != null and level.has_method("update_tile_hover"):
		level.call("update_tile_hover", _grid_position)


func _handle_action_on_current_tile() -> void:
	var level := get_parent()
	if level == null:
		return

	if level.has_method("is_cell_end") and level.call("is_cell_end", _grid_position):
		_trigger_end_tile_action()
		return

	if level.has_method("is_cell_special") and level.call("is_cell_special", _grid_position):
		if level.has_method("complete_minigame"):
			var was_completed: bool = level.call("complete_minigame", _grid_position)
			if was_completed:
				print("Minispiel gemeistert auf Feld:", _grid_position)
			else:
				print("Minispiel auf diesem Feld bereits gewertet:", _grid_position)
		else:
			print("Special-Tile Aktion ausgelost auf Feld:", _grid_position)


func _trigger_end_tile_action() -> void:
	var level := get_parent()
	if level != null and level.has_method("load_next_level"):
		level.call("load_next_level")
		return
	get_tree().reload_current_scene()

extends Node3D

@export var tile_size: float = 2.0
@export var move_duration: float = 0.2

var _grid_position := Vector2i.ZERO
var _is_moving := false


func _ready() -> void:
	_grid_position = Vector2i(roundi(position.x / tile_size), roundi(position.z / tile_size))
	_snap_to_grid()


func set_tile_size(value: float) -> void:
	tile_size = value
	_snap_to_grid()


func _unhandled_input(event: InputEvent) -> void:
	if _is_moving:
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
		_is_moving = false
	)

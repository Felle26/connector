extends Node3D

const TILE_SCENE := preload("res://lvl/Tile.tscn")
const CYAN_NO_NEON_MATERIAL := preload("res://lvl/player-mesh/Cyan_no_neon.tres")
const CYAN_PLAYER_MATERIAL := preload("res://lvl/player-mesh/Cyan_Player.tres")
const HIGHLIGHT_SURFACE_INDEX := 1

signal points_changed(points: int)

@export var base_tile_scene: PackedScene = TILE_SCENE
@export var base_tiles_enabled: bool = true
@export var start_tile_scene: PackedScene = TILE_SCENE
@export var start_tile_enabled: bool = true
@export var end_tile_scene: PackedScene = TILE_SCENE
@export var end_tile_enabled: bool = true
@export var special_tiles_enabled: bool = true
@export var special_tile_scene_1: PackedScene = TILE_SCENE
@export var special_tile_1_enabled: bool = true
@export var special_tile_scene_2: PackedScene
@export var special_tile_2_enabled: bool = true
@export var grid_size_x: int = 10
@export var grid_size_z: int = 10
@export var tile_size: float = 1.0
@export var tile_height: float = 0.2
@export var tile_gap: float = 0.05
@export_range(0.0, 1.0) var fill_chance: float = 0.8
@export var random_seed: int = 0
@export var show_point_logs: bool = true

@onready var tiles_root: Node3D = $Tiles
@onready var player_cube: Node3D = $Cube

var _step: float = 1.0
var _walkable: Dictionary = {}
var _special_cells: Dictionary = {}
var _end_cell: Vector2i = Vector2i.ZERO
var _tile_meshes: Dictionary = {}
var _hovered_cell: Vector2i = Vector2i(-1, -1)
var _activated_base_cells: Dictionary = {}
var _completed_minigames: Dictionary = {}
var _points_counter: int = 0


func _ready() -> void:
	_build_grid()
	_configure_player()


func _get_mesh_size(node: Node) -> Vector3:
	for child in node.get_children():
		if child is MeshInstance3D:
			return child.get_aabb().size
		var s := _get_mesh_size(child)
		if s != Vector3.ZERO:
			return s
	return Vector3.ZERO


func _cell_to_world(cell: Vector2i) -> Vector3:
	return Vector3(cell.x * _step, -tile_height * 0.5, cell.y * _step)


func _build_main_path(rng: RandomNumberGenerator) -> Array[Vector2i]:
	var path: Array[Vector2i] = [Vector2i.ZERO]
	var current := Vector2i.ZERO
	var target := Vector2i(grid_size_x - 1, grid_size_z - 1)

	while current != target:
		var directions: Array[Vector2i] = []
		if current.x < target.x:
			directions.append(Vector2i(1, 0))
		if current.y < target.y:
			directions.append(Vector2i(0, 1))

		if directions.is_empty():
			break

		current += directions[rng.randi_range(0, directions.size() - 1)]
		path.append(current)

	return path


func _build_grid() -> void:
	for child in tiles_root.get_children():
		child.queue_free()
	_walkable.clear()
	_special_cells.clear()
	_tile_meshes.clear()
	_hovered_cell = Vector2i(-1, -1)
	_activated_base_cells.clear()
	_completed_minigames.clear()

	var default_tile_scene := _get_default_tile_scene()
	var mesh_size := Vector3.ZERO
	if default_tile_scene != null:
		var probe: Node3D = default_tile_scene.instantiate()
		tiles_root.add_child(probe)
		mesh_size = _get_mesh_size(probe)
		probe.queue_free()
	_step = (mesh_size.x if mesh_size.x > 0.0 else tile_size) + tile_gap

	var rng := RandomNumberGenerator.new()
	if random_seed != 0:
		rng.seed = random_seed
	else:
		rng.randomize()

	var path_cells := {}
	for cell in _build_main_path(rng):
		path_cells[cell] = true
	var connected_cells := _build_connected_cells(path_cells, rng)

	_end_cell = Vector2i(grid_size_x - 1, grid_size_z - 1)

	var candidate_special_cells: Array[Vector2i] = []
	for cell in path_cells.keys():
		if cell != Vector2i.ZERO and cell != Vector2i(grid_size_x - 1, grid_size_z - 1):
			candidate_special_cells.append(cell)

	var special_cells: Dictionary = {}
	if special_tiles_enabled and not candidate_special_cells.is_empty():
		candidate_special_cells.shuffle()
		if special_tile_1_enabled and special_tile_scene_1 != null:
			special_cells[candidate_special_cells.pop_back()] = special_tile_scene_1
		if special_tile_2_enabled and special_tile_scene_2 != null and not candidate_special_cells.is_empty():
			special_cells[candidate_special_cells.pop_back()] = special_tile_scene_2

	for x in range(grid_size_x):
		for z in range(grid_size_z):
			var cell := Vector2i(x, z)
			var is_start := cell == Vector2i.ZERO
			var is_end := cell == _end_cell and not is_start
			var is_special := special_cells.has(cell)
			if not connected_cells.has(cell):
				continue
			var tile_scene: PackedScene = default_tile_scene
			if is_start and start_tile_enabled and start_tile_scene != null:
				tile_scene = start_tile_scene
			elif is_end and end_tile_enabled and end_tile_scene != null:
				tile_scene = end_tile_scene
			elif is_special:
				tile_scene = special_cells[cell]
				_special_cells[cell] = true
			if tile_scene == null:
				continue
			_walkable[cell] = true
			var tile: Node3D = tile_scene.instantiate()
			tile.position = _cell_to_world(cell)
			tiles_root.add_child(tile)
			if not is_start and not is_end and not is_special:
				_register_tile_mesh(cell, tile)


func _build_connected_cells(path_cells: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var connected := path_cells.duplicate()
	if fill_chance <= 0.0:
		return connected

	var candidates: Array[Vector2i] = []
	for x in range(grid_size_x):
		for z in range(grid_size_z):
			var cell := Vector2i(x, z)
			if not path_cells.has(cell):
				candidates.append(cell)

	candidates.shuffle()
	for cell in candidates:
		if rng.randf() > fill_chance:
			continue
		if _has_neighbor_in_set(cell, connected):
			connected[cell] = true

	return connected


func _has_neighbor_in_set(cell: Vector2i, cell_set: Dictionary) -> bool:
	var neighbors: Array[Vector2i] = [
		cell + Vector2i(1, 0),
		cell + Vector2i(-1, 0),
		cell + Vector2i(0, 1),
		cell + Vector2i(0, -1)
	]
	for neighbor in neighbors:
		if cell_set.has(neighbor):
			return true
	return false


func _get_default_tile_scene() -> PackedScene:
	if base_tiles_enabled and base_tile_scene != null:
		return base_tile_scene
	if base_tiles_enabled:
		return TILE_SCENE
	return null


func _configure_player() -> void:
	if player_cube == null:
		return

	player_cube.position = _cell_to_world(Vector2i.ZERO) + Vector3(0.0, 0.6, 0.0)

	if player_cube.has_method("set_tile_size"):
		player_cube.call("set_tile_size", _step)


func _register_tile_mesh(cell: Vector2i, tile_root: Node) -> void:
	var mesh := _find_first_mesh(tile_root)
	if mesh == null:
		return
	_tile_meshes[cell] = mesh
	_apply_base_tile_material(mesh)


func _find_first_mesh(node: Node) -> MeshInstance3D:
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
		var nested := _find_first_mesh(child)
		if nested != null:
			return nested
	return null


func _apply_base_tile_material(mesh: MeshInstance3D) -> void:
	# Clear override so the material from the selected tile scene is shown.
	mesh.set_surface_override_material(HIGHLIGHT_SURFACE_INDEX, null)


func _apply_activated_base_tile_material(mesh: MeshInstance3D) -> void:
	mesh.set_surface_override_material(HIGHLIGHT_SURFACE_INDEX, CYAN_PLAYER_MATERIAL)


func _apply_hover_tile_material(mesh: MeshInstance3D) -> void:
	_apply_activated_base_tile_material(mesh)


func update_tile_hover(cell: Vector2i) -> void:
	if _hovered_cell == cell:
		return

	if _tile_meshes.has(_hovered_cell):
		if _activated_base_cells.has(_hovered_cell):
			_apply_activated_base_tile_material(_tile_meshes[_hovered_cell])
		else:
			_apply_base_tile_material(_tile_meshes[_hovered_cell])

	if _tile_meshes.has(cell):
		if not _activated_base_cells.has(cell):
			_activated_base_cells[cell] = true
			_add_points(1, "Base-Tile betreten")
		_apply_hover_tile_material(_tile_meshes[cell])

	_hovered_cell = cell


func is_cell_walkable(cell: Vector2i) -> bool:
	return _walkable.has(cell)


func is_cell_special(cell: Vector2i) -> bool:
	return _special_cells.has(cell)


func is_cell_end(cell: Vector2i) -> bool:
	return cell == _end_cell


func complete_minigame(cell: Vector2i) -> bool:
	if not _special_cells.has(cell):
		return false
	if _completed_minigames.has(cell):
		return false

	_completed_minigames[cell] = true
	_add_points(1, "Minispiel gemeistert")
	return true


func get_points() -> int:
	return _points_counter


func _add_points(amount: int, reason: String) -> void:
	if amount <= 0:
		return

	_points_counter += amount
	emit_signal("points_changed", _points_counter)
	if show_point_logs:
		print("Punkte +", amount, " (", reason, ") => Gesamt: ", _points_counter)


func load_next_level() -> void:
	# Dummy next level: generate a fresh grid and reset player to start.
	random_seed = 0
	_build_grid()
	_configure_player()

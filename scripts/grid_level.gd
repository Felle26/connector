extends Node3D

const TILE_SCENE := preload("res://lvl/Tile.tscn")

@export var start_tile_scene: PackedScene = TILE_SCENE
@export var end_tile_scene: PackedScene = TILE_SCENE
@export var grid_size_x: int = 10
@export var grid_size_z: int = 10
@export var tile_size: float = 1.0
@export var tile_height: float = 0.2
@export var tile_gap: float = 0.05
@export_range(0.0, 1.0) var fill_chance: float = 0.8
@export var random_seed: int = 0

@onready var tiles_root: Node3D = $Tiles
@onready var player_cube: Node3D = $Cube

var _step: float = 1.0
var _walkable: Dictionary = {}


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

	var probe: Node3D = TILE_SCENE.instantiate()
	tiles_root.add_child(probe)
	var mesh_size := _get_mesh_size(probe)
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

	for x in range(grid_size_x):
		for z in range(grid_size_z):
			var cell := Vector2i(x, z)
			var is_start := cell == Vector2i.ZERO
			var is_end := cell == Vector2i(grid_size_x - 1, grid_size_z - 1) and not is_start
			if not path_cells.has(cell) and rng.randf() > fill_chance:
				continue
			_walkable[cell] = true
			var tile_scene: PackedScene = TILE_SCENE
			if is_start and start_tile_scene != null:
				tile_scene = start_tile_scene
			elif is_end and end_tile_scene != null:
				tile_scene = end_tile_scene
			var tile: Node3D = tile_scene.instantiate()
			tile.position = _cell_to_world(cell)
			tiles_root.add_child(tile)


func _configure_player() -> void:
	if player_cube == null:
		return

	if player_cube.has_method("set_tile_size"):
		player_cube.call("set_tile_size", _step)

	player_cube.position = _cell_to_world(Vector2i.ZERO) + Vector3(0.0, 0.6, 0.0)


func is_cell_walkable(cell: Vector2i) -> bool:
	return _walkable.has(cell)

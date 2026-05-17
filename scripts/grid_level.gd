extends Node3D

const TILE_SCENE := preload("res://lvl/Tile.tscn")

@export var grid_size_x: int = 10
@export var grid_size_z: int = 10
@export var tile_size: float = 1.0
@export var tile_height: float = 0.2
@export var tile_gap: float = 0.05

@onready var tiles_root: Node3D = $Tiles
@onready var player_cube: Node3D = $Cube

var _step: float = 1.0


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


func _build_grid() -> void:
	for child in tiles_root.get_children():
		child.queue_free()

	# Tile-Größe automatisch aus dem Mesh auslesen
	var probe: Node3D = TILE_SCENE.instantiate()
	tiles_root.add_child(probe)
	var mesh_size := _get_mesh_size(probe)
	probe.queue_free()
	_step = (mesh_size.x if mesh_size.x > 0.0 else tile_size) + tile_gap

	for x in range(grid_size_x):
		for z in range(grid_size_z):
			var tile: Node3D = TILE_SCENE.instantiate()
			tile.position = Vector3(x * _step, -tile_height * 0.5, z * _step)
			tiles_root.add_child(tile)


func _configure_player() -> void:
	if player_cube == null:
		return

	if player_cube.has_method("set_tile_size"):
		player_cube.call("set_tile_size", _step)

	player_cube.position = Vector3(0.0, 0.6, 0.0)


func is_cell_walkable(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < grid_size_x and cell.y >= 0 and cell.y < grid_size_z

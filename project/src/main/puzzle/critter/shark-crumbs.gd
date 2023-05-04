extends GPUParticles2D
## Emits crumb particles as a piece is eaten.

## Tile map for the pieces the shark is eating.
var tile_map: PuzzleTileMap: set = set_tile_map

func set_tile_map(new_tile_map: PuzzleTileMap) -> void:
	tile_map = new_tile_map
	
	refresh()


## Updates our particle properties based on the pieces the shark is eating.
##
## If the shark is eating an especially wide chunk of food, we will emit more particles over a wider area.
func refresh() -> void:
	if not tile_map or tile_map.get_used_cells(0).is_empty():
		amount = 2
		return
	
	# assign color
	var used_cell: Vector2i = tile_map.get_used_cells(0)[0]
	modulate = Utils.rand_value(tile_map.crumb_colors_for_cell(used_cell))
	
	# assign width, position, scale
	process_material.emission_box_extents.x = max(1.0, tile_map.get_used_rect().size.x) * tile_map.tile_set.tile_size.x * 0.5
	position.x = tile_map.get_used_rect().get_center().x
	process_material.scale_max = tile_map.global_scale.x
	process_material.scale_min = process_material.scale_max * 0.5
	
	# assign particle count (6 * cell width)
	amount = 6 * max(1.0, tile_map.get_used_rect().size.x)

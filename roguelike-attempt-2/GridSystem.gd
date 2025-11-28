class_name GridSystem 
extends System

var default_entity_data: EntityData = EntityData.new()

var grid_data: GridData

var game_reference: Game
var grid_visual_instance: GridInstance

func set_reference_to_parent(_parent: Game) -> void:
	game_reference = _parent

func get_location_data(_position: Vector2i):
	var _location_data: LocationData = grid_data.grid_cell_dictionary.get(_position)
	return _location_data


func add_entity_to_cell(_position: Vector2i, _entity: EntityData) -> void:
	if get_location_data(_position) != null:
		get_location_data(_position).entity_array.append(_entity)

func remove_entity_from_cell(_position: Vector2i, _entity: EntityData) -> void:
	if get_location_data(_position) != null:
		get_location_data(_position).entity_array.erase(_entity)

func create_grid_data(_default_entity_data: EntityData = EntityData.new(), 
	_default_grid_data: GridData = GridData.new(), 
	_default_location_data: LocationData = LocationData.new()) -> void:
	var _grid_data: GridData = _default_grid_data.duplicate()
	var _cell_position: Vector2i
	var _location_data: LocationData

	for y in Global.GRID_SIZE.y:
		for x in Global.GRID_SIZE.x:
			_cell_position = Vector2i(x, y) * Global.CELL_SIZE
			_location_data = _default_location_data.duplicate()
			_location_data.entity_array.append(_default_entity_data.duplicate())
			_grid_data.grid_cell_dictionary.set(_cell_position, _location_data)
	
	grid_data = _grid_data

func create_grid_instance(_data: GridData = grid_data) -> void:
	
	grid_visual_instance = GridInstance.new(_data)
	var _cell_dictionary: Dictionary[Vector2i, LocationData] = grid_visual_instance.grid_data.grid_cell_dictionary
	var _location_data: LocationData
	
	for cell_position in _cell_dictionary:
		_location_data = _cell_dictionary.get(cell_position)
		for entity in _location_data.entity_array:
			for component in entity.component_array:
				component.set_variables(cell_position, game_reference)
				component.execute()

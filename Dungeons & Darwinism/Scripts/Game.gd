class_name Game
extends Node2D

### Variables
## Enumerators
enum GAME_STATE { active, menu_open }

## OnReady
@onready var floor_sprite: Sprite2D = $TiledFloorBG
@onready var camera: Camera2D = $Camera
## Export
@export var length_height: Vector2i = Vector2i(16, 8)
## Vectors
var input_direction: Vector2i
var desired_cell_to_move_to: Vector2i
var current_position: Vector2i 
var input_direction_last_frame: Vector2i
var selected_entity_pos: Vector2i
var menu_cursor_position: Vector2i
## Bools
var can_walk: bool
var input_attempted: bool 
## Nodes
var inventory_node: Node2D
var inventory_cell_sprite: Sprite2D
var cursor_sprite: Sprite2D
var inventory_background_sprite: Sprite2D
var hp_bar: ProgressBar
## Systems
var grid_system: GridSystem
var sfx: SFX
var music: SFX
var current_state: GAME_STATE 
var previous_state: GAME_STATE
## Data
var location_data: LocationData
var drinker_location: LocationData
var selected_entity: EntityData
var potion_entity: PotionEntityData
## Components
var selected_entity_texture: TextureComponent
var texture_component: TextureComponent
var player_hp_component: HpComponent
var solid_component: SolidComponent
### Functions
## Entities and components
func find_component(_entity: EntityData, _id: String) -> Component:
	if _entity:
		for _component in _entity.component_array:
			if _component.id == _id:
				return _component
	return null
func find_entity(_location_data: LocationData, _id: String) -> EntityData:
	for _entity in _location_data.entity_array:
		if _entity.id == _id:
			return _entity
	return null
## Inventory
func pick_up_item(_inventory: Dictionary[Vector2i, EntityData], _entity_position: Vector2i) -> void:
	var _location_data: LocationData = grid_system.get_location_data(_entity_position)
	for _entity in _location_data.entity_array:
		if find_component(_entity, ComponentId.CAN_PICK_UP):
			for _y in Global.INVENTORY_SIZE.y:
				for _x in Global.INVENTORY_SIZE.x:
					var _pos: Vector2i = Vector2i(_x, _y).clamp(Vector2i.ZERO, Global.INVENTORY_SIZE)
					if !_inventory.get(_pos * Global.CELL_SIZE):
						_inventory[_pos * Global.CELL_SIZE] = _entity
						add_to_inventory(_pos * Global.CELL_SIZE,_entity,_inventory)
						grid_system.remove_entity_from_cell(_entity_position, _entity)
						return
func add_to_inventory(_position: Vector2i, _entity: EntityData, _inventory: Dictionary[Vector2i, EntityData]) -> void:
	_position.clamp(Vector2i.ZERO, Global.INVENTORY_SIZE)
	if !_inventory.get(_position):
		_inventory.set(_position, _entity)
func remove_from_inventory(_position: Vector2i, _entity: EntityData, _inventory: Dictionary[Vector2i, EntityData]) -> void:
	_position.clamp(Vector2i.ZERO, Global.INVENTORY_SIZE)
	if _inventory.has(_position):
		_inventory.erase(_position)
func show_inventory(_inventory: Dictionary[Vector2i, EntityData]) -> void:
	if inventory_node: inventory_node.queue_free()
	inventory_node = Node2D.new()
	inventory_node.position -= Vector2(Global.DEFAULT_INVENTORY_POSITION) 
	for _y in Global.INVENTORY_SIZE.y:
		for _x in Global.INVENTORY_SIZE.x:
			inventory_background_sprite = Sprite2D.new()
			inventory_background_sprite.texture = Textures.INVENTORY_SLOT
			inventory_background_sprite.z_index = Global.INVENTORY_BG_SPRITE_Z_INDEX
			inventory_background_sprite.position = Vector2i(_x, _y) * Global.CELL_SIZE
			inventory_node.add_child(inventory_background_sprite)
	for cell in _inventory:
		inventory_cell_sprite = Sprite2D.new()
		texture_component = find_component(_inventory[cell],ComponentId.TEXTURE)
		if texture_component:
			inventory_cell_sprite.texture = texture_component.texture
		inventory_cell_sprite.position = cell
		inventory_cell_sprite.z_index = Global.INVENTORY_CELL_SPRITE_Z_INDEX
		inventory_node.add_child(inventory_cell_sprite)
	if camera and inventory_node:
		camera.add_child(inventory_node)
		change_state(GAME_STATE.menu_open)
func close_inventory() -> void:
	if camera:
		for node in camera.get_children():
			if node is not AudioStreamPlayer2D:
				node.queue_free()
		change_state(GAME_STATE.menu_open)
func create_cursor() -> void:
	menu_cursor_position = Global.MENU_CURSOR_DEFAULT_POSITION
	cursor_sprite = Sprite2D.new()
	cursor_sprite.texture = Textures.MENU_CURSOR
	cursor_sprite.position = menu_cursor_position * Global.CELL_SIZE
	cursor_sprite.z_index = Global.INVENTORY_CURSOR_SPRITE_Z_INDEX
	camera.add_child(cursor_sprite)
func remove_cursor() -> void:
	if cursor_sprite and camera:
		camera.remove_child(cursor_sprite)
func access_inventory() -> void:
	match current_state:
		GAME_STATE.active:
			var _inv_com = find_component(selected_entity, ComponentId.INVENTORY)
			if _inv_com:
				show_inventory(_inv_com.inventory)
				create_cursor()
			change_state(GAME_STATE.menu_open)
		GAME_STATE.menu_open:
			close_inventory()
			remove_cursor()
			change_state(GAME_STATE.active)
## Drawing functions
func delete_all_visual_instance_sprites() -> void:
	for child in get_children():
		if (child is Sprite2D) and (child != floor_sprite):
			child.queue_free()
func redraw() -> void:
	player_hp_component = find_component(selected_entity, ComponentId.HP)
	if hp_bar: 
		remove_child(hp_bar)
		hp_bar.queue_free()
	if grid_system.grid_visual_instance: 
		grid_system.grid_visual_instance.queue_free()
	delete_all_visual_instance_sprites()
	grid_system.create_grid_instance()
	if player_hp_component:
		hp_bar = ProgressBar.new()
		hp_bar.set_value(player_hp_component.current_hp)
		hp_bar.set_max(player_hp_component.max_hp)
		add_child(hp_bar)
## Entity Functions
func attack(attacker: EntityData, defender: EntityData) -> void:
	var _damage: int = find_component(attacker, ComponentId.STATS).stat_dict.get(StatsComponent.stat.dmg)
	defender.take_damage(_damage)
	TurnCounterAutoload.increment_turn()
func drink(_drinking_entity: EntityData) -> void:
	if _drinking_entity:
		drinker_location = grid_system.get_location_data(_drinking_entity.get_texture_component().cell_position)
		potion_entity = find_entity(drinker_location, EntityId.POTION_ENTITY_DATA)
		if potion_entity: 
			potion_entity.drink(_drinking_entity, potion_entity.potion_effect)
			sfx.play_sfx(Audio.DRINK_POTION, Audio.DRINK_SFX_DEFAULT_VOLUME)
		grid_system.remove_entity_from_cell(_drinking_entity.get_texture_component().cell_position, potion_entity)
		TurnCounterAutoload.increment_turn()
## Player functions
func create_new_player_entity(_username: String = "", _entity: EntityData = PlayerEntityData.new(_username)) -> void:
	if selected_entity:
		var _pos: Vector2i = selected_entity.get_texture_component().cell_position
		var _location: LocationData = grid_system.get_location_data(_pos)
		var _entity_array: Array[EntityData] = _location.entity_array
		var _player: PlayerEntityData = find_entity(_location, EntityId.PLAYER_ENTITY_DATA)
		_entity_array.remove_at(_entity_array.find(_player))
	selected_entity = _entity
	grid_system.add_entity_to_cell(Global.DEFAULT_POSITION * Global.CELL_SIZE, selected_entity)
	current_position = Global.DEFAULT_POSITION
## Map Generation
func surround_perimeter_of_map_with_dense_walls() -> void:
	for _x in Global.GRID_SIZE.x: 
		grid_system.add_entity_to_cell(Vector2i(0 + _x, 0) * Global.CELL_SIZE, DenseWallEntity.new())
		grid_system.add_entity_to_cell(Vector2i(0 + _x, Global.GRID_SIZE.y) * Global.CELL_SIZE, DenseWallEntity.new())
	for _y in Global.GRID_SIZE.y: 
		grid_system.add_entity_to_cell(Vector2i(0, 0 + _y) * Global.CELL_SIZE, DenseWallEntity.new())
		grid_system.add_entity_to_cell(Vector2i(Global.GRID_SIZE.x, 0  + _y) * Global.CELL_SIZE, DenseWallEntity.new())
## State Machine
func change_state(_to_state: GAME_STATE) -> void:
	previous_state = current_state
	current_state = _to_state
### Control flow
## Start up
func _init() -> void:
	grid_system = GridSystem.new()
	music = SFX.new()
	sfx = SFX.new()
	current_position = Global.DEFAULT_POSITION
	grid_system.set_reference_to_parent(self)
	grid_system.create_grid_data()
	create_new_player_entity()
	surround_perimeter_of_map_with_dense_walls()
	change_state(GAME_STATE.active)
func _ready() -> void:
	floor_sprite.offset -= Vector2(Global.CELL_SIZE / 2)
	floor_sprite.region_rect.size = Global.GRID_SIZE * Global.CELL_SIZE
	camera.add_child(sfx.audio)
	camera.add_child(music.audio)
	## Huh?
	for cell in float(length_height.x):
		if (((cell) < (float(length_height.x) / 2.0)) or ((cell) > (float(length_height.x) / 2.0) + (float(length_height.x) / 4.0))): 
			grid_system.add_entity_to_cell(Vector2i(1 + int(roundf(cell)), length_height.y) * Global.CELL_SIZE, WallEntityData.new())
		else:
			grid_system.add_entity_to_cell(Vector2i(1 + int(roundf(cell)), length_height.y) * Global.CELL_SIZE, PhasePotion.new())
## Game loop
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(Keys.CREATE_NEW_PLAYER_KEY):
		create_new_player_entity()
		redraw()
	if selected_entity:
		selected_entity_texture = selected_entity.get_texture_component()
		selected_entity_pos = selected_entity_texture.cell_position 
		if grid_system:
			if Input.is_action_just_pressed(Keys.SPAWN_ENEMY_KEY):
				var _enemy: EnemyEntityData = HalfwitEntity.new()
				var _distance: Vector2i = Vector2i(2, 0)
				grid_system.add_entity_to_cell((_distance * Global.CELL_SIZE) + selected_entity_pos, _enemy)
			if Input.is_action_just_pressed(Keys.BECOME_MONSTER_KEY):
				grid_system.remove_entity_from_cell(current_position * Global.CELL_SIZE, selected_entity)
				var _enemy: EnemyEntityData = HalfwitEntity.new()
				selected_entity = _enemy
				grid_system.add_entity_to_cell(selected_entity_pos, selected_entity)
	if hp_bar:
		hp_bar.position = selected_entity_pos - Global.HP_BAR_OFFSET
	match current_state:
		GAME_STATE.active:
			if find_component(selected_entity, ComponentId.MOVEMENT):
				if Input.is_action_just_pressed(Keys.INVENTORY_KEY):
					access_inventory()
			if Input.is_action_just_pressed(Keys.TAKE_DAMAGE_KEY):
				if selected_entity:
					var _test_dmg: int = 5 
					selected_entity.take_damage(_test_dmg)
			if Input.is_action_just_pressed(Keys.PICK_UP_KEY):
				var _inv_com: InventoryComponent = find_component(selected_entity, ComponentId.INVENTORY)
				if _inv_com: 
					pick_up_item(_inv_com.inventory, selected_entity_pos)
			if Input.is_action_just_pressed(Keys.DRINK_KEY):
				drink(selected_entity)
			input_direction = Input.get_vector(Keys.LEFT_KEY, Keys.RIGHT_KEY, Keys.UP_KEY, Keys.DOWN_KEY)
			input_attempted = (input_direction) and (input_direction_last_frame != input_direction)
			can_walk = false
			if input_attempted: 
				desired_cell_to_move_to = selected_entity_pos + (input_direction * Global.CELL_SIZE)
				location_data = grid_system.get_location_data(desired_cell_to_move_to)
				if find_component(selected_entity, ComponentId.MOVEMENT) and (location_data):
					can_walk = true
					for entity_at_next_cell in location_data.entity_array:
						var _enemy: EntityData = find_entity(location_data, EntityId.ENEMY_ENTITY_DATA)
						var _attackable: Component = find_component(_enemy, ComponentId.CAN_ATTACK)
						solid_component = find_component(entity_at_next_cell, ComponentId.SOLID)
						if _enemy:
							if _attackable:
								attack(selected_entity, _enemy)
						if solid_component:
							if !find_component(selected_entity, ComponentId.PHASE) or solid_component.dense:
								can_walk = false
			if can_walk:
				grid_system.remove_entity_from_cell(current_position * Global.CELL_SIZE, selected_entity)
				current_position += input_direction
				grid_system.add_entity_to_cell(current_position * Global.CELL_SIZE, selected_entity)
				TurnCounterAutoload.increment_turn()
			input_direction_last_frame = input_direction
		GAME_STATE.menu_open:
			input_direction = Input.get_vector(Keys.LEFT_KEY, Keys.RIGHT_KEY, Keys.UP_KEY, Keys.DOWN_KEY)
			if (input_direction) and (input_direction_last_frame != input_direction) and cursor_sprite:
				cursor_sprite.position += Vector2(input_direction * Global.CELL_SIZE)
				## Huh?
				@warning_ignore("integer_division")
				cursor_sprite.position = cursor_sprite.position.clamp(-Global.CELL_SIZE, (Global.INVENTORY_SIZE * Global.CELL_SIZE)/((Global.INVENTORY_SIZE.x + Global.INVENTORY_SIZE.y)/2))
			input_direction_last_frame = input_direction
			if Input.is_action_just_pressed(Keys.DRINK_KEY):
				var _inventory_component: InventoryComponent = find_component(selected_entity,ComponentId.INVENTORY)
				if _inventory_component: 
					if _inventory_component.inventory.has(Vector2i(cursor_sprite.position) + Global.CELL_SIZE):
						grid_system.add_entity_to_cell(current_position * Global.CELL_SIZE, _inventory_component.inventory[(Vector2i(cursor_sprite.position) + Global.CELL_SIZE)])
						remove_from_inventory(Vector2i(cursor_sprite.position) + Global.CELL_SIZE, _inventory_component.inventory[Vector2i(cursor_sprite.position)+ Global.CELL_SIZE], _inventory_component.inventory)
						access_inventory()
						TurnCounterAutoload.increment_turn()
			if Input.is_action_just_pressed(Keys.INVENTORY_KEY):
				access_inventory()
func _input(_event: InputEvent) -> void:
	if !music.audio.playing:
		music.play_sfx(Audio.KM)
	match current_state:
		GAME_STATE.active:
			redraw()
			camera.position = selected_entity_pos
		GAME_STATE.menu_open: 
			show_inventory(find_component(selected_entity,ComponentId.INVENTORY).inventory)

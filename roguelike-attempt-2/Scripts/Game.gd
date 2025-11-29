class_name Game
extends Node2D

### Variables
## Enumerators
enum GAME_STATE { active, menu_open }

## Constants
const INVENTORY_KEY: String = "ui_home"
const TAKE_DAMAGE_KEY: String = "ui_page_up"
const CREATE_NEW_PLAYER_KEY: String = "ui_page_down"
const DRINK_KEY: String = "ui_accept"
const UP: String = "ui_up"
const DOWN: String = "ui_down"
const LEFT: String = "ui_left"
const RIGHT: String = "ui_right"

## OnReady
@onready var floor_sprite: Sprite2D = $TiledFloorBG
@onready var camera: Camera2D = $Camera
@export var length_height: Vector2i = Vector2i(16, 8)

## Vectors
var input_direction: Vector2i
var desired_cell_to_move_to: Vector2i
var current_position: Vector2i 
var input_direction_last_frame: Vector2i
var selected_entity_pos: Vector2i

## Bools
var can_walk_to: bool

## Dictionaries
var player_inventory: Dictionary[Vector2i, EntityData] = { }

## Nodes
var inventory_node: Node2D
var inventory_cell_sprite: Sprite2D

var hp_bar: ProgressBar

var cursor_sprite: Sprite2D
var menu_cursor_sprite: Texture2D = Textures.MENU_CURSOR
var menu_cursor_position: Vector2i = Vector2i.ZERO
var menu_cursor_default_position: Vector2i = Vector2i.ZERO

## Systems
var current_state: GAME_STATE = GAME_STATE.active
var previous_state: GAME_STATE

var grid_system: GridSystem

var sfx: SFX
var music: SFX

## Data
var location_data: LocationData
var drinker_location: LocationData
var player_location: LocationData

var selected_entity: EntityData
var potion_entity: PotionEntityData
var player: PlayerEntityData

## Components
var damaged_entity_texture_component: TextureComponent
var selected_entity_texture: TextureComponent
var texture_component: TextureComponent

var player_hp_component: HpComponent
var damaged_entity_hp_component: HpComponent

var solid_component: SolidComponent

var player_movement_component: MovementComponent

### Functions
## Entities and components
func find_component(_entity: EntityData, _id: String) -> Component:
	for component in _entity.component_array:
		if component.id == _id:
			return component
	return null

func find_entity(_location_data: LocationData, _id: String) -> EntityData:
	for entity in _location_data.entity_array:
		if entity.id == _id:
			return entity
	return null

## Inventory
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
	inventory_node.position -= Vector2(Vector2i(1, 1)) * Vector2(Global.CELL_SIZE)
	var _inv_bg: Sprite2D = Sprite2D.new()
	_inv_bg.texture = Textures.INVENTORY_SLOT
	_inv_bg.z_index = 996
	for _y in Global.INVENTORY_SIZE.y:
		for _x in Global.INVENTORY_SIZE.x:
			var a = _inv_bg.duplicate()
			a.position = Vector2i(_x, _y) * Global.CELL_SIZE
			inventory_node.add_child(a)
	for cell in _inventory:
		inventory_cell_sprite = Sprite2D.new()
		texture_component = find_component(_inventory[cell],ComponentId.TEXTURE)
		if texture_component:
			inventory_cell_sprite.texture = texture_component.texture
		inventory_cell_sprite.position = cell
		
		inventory_cell_sprite.z_index = 998
		
		inventory_node.add_child(inventory_cell_sprite)
	
	if camera and inventory_node:
		camera.add_child(inventory_node)
		change_state(GAME_STATE.menu_open)

func close_inventory() -> void:
	if camera:
		for node in camera.get_children():
			if node is not AudioStreamPlayer2D:
				node.queue_free()
		current_state = GAME_STATE.active

func create_cursor() -> void:
	menu_cursor_position = menu_cursor_default_position
	cursor_sprite = Sprite2D.new()
	cursor_sprite.texture = Textures.MENU_CURSOR
	cursor_sprite.position = menu_cursor_position * Global.CELL_SIZE
	cursor_sprite.z_index = 999
	camera.add_child(cursor_sprite)

func remove_cursor() -> void:
	if cursor_sprite and camera:
		camera.remove_child(cursor_sprite)

func access_inventory() -> void:
	match current_state:
		GAME_STATE.active:
			show_inventory(player_inventory)
			create_cursor()
		GAME_STATE.menu_open:
			close_inventory()
			remove_cursor()

## Drawing functions
func delete_all_visual_instance_sprites() -> void:
	for child in get_children():
		if (child is Sprite2D) and (child != floor_sprite):
			child.queue_free()

func redraw() -> void:
	player_hp_component = find_component(player, ComponentId.HP)
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
func drink(_drinking_entity: EntityData) -> void:
	drinker_location = grid_system.get_location_data(_drinking_entity.get_texture_component().cell_position)
	potion_entity = find_entity(drinker_location, EntityId.POTION_ENTITY_DATA)
	if potion_entity: 
		potion_entity.drink(_drinking_entity, potion_entity.potion_effect)
		sfx.play_sfx(Audio.DRINK_POTION, Audio.DRINK_SFX_DEFAULT_VOLUME)
	grid_system.remove_entity_from_cell(_drinking_entity.get_texture_component().cell_position, potion_entity)
	TurnCounterAutoload.increment_turn()

func take_damage(_entity: EntityData, _damage: int, _corpse: CorpseEntityData) -> void:
	damaged_entity_texture_component = find_component(_entity, ComponentId.TEXTURE)
	damaged_entity_hp_component = find_component(_entity, ComponentId.HP)
	damaged_entity_hp_component.current_hp -= _damage
	if damaged_entity_hp_component.current_hp < 1:
		if _entity.id == EntityId.PLAYER_ENTITY_DATA:
			player_location = grid_system.get_location_data(_entity.get_texture_component().cell_position)
			player_movement_component = find_component(_entity, ComponentId.MOVEMENT)
			if player_movement_component: 
				player_movement_component.remove_component(_entity)
			player_location.entity_array.erase(_entity)
		grid_system.remove_entity_from_cell(damaged_entity_texture_component.cell_position, _entity)
		grid_system.add_entity_to_cell(damaged_entity_texture_component.cell_position, _corpse)

## Player functions
func create_new_player() -> void:
	if player:
		var _pos: Vector2i = player.get_texture_component().cell_position
		var _location: LocationData = grid_system.get_location_data(_pos)
		var _entity_array: Array[EntityData] = _location.entity_array
		var _player: PlayerEntityData = find_entity(_location, EntityId.PLAYER_ENTITY_DATA)
		_entity_array.remove_at(_entity_array.find(_player))
	player = PlayerEntityData.new()
	grid_system.add_entity_to_cell(Global.DEFAULT_POSITION * Global.CELL_SIZE, player)
	current_position = Global.DEFAULT_POSITION

## Map Generation
func surround_perimeter_of_map_with_dense_walls() -> void:
	for _x in Global.GRID_SIZE.x: 
		grid_system.add_entity_to_cell(Vector2i(0 + _x, 0) * Global.CELL_SIZE, DenseWallEntity.new())
		grid_system.add_entity_to_cell(Vector2i(0 + _x, Global.GRID_SIZE.y) * Global.CELL_SIZE, DenseWallEntity.new())
	for _y in Global.GRID_SIZE.y: 
		grid_system.add_entity_to_cell(Vector2i(0, 0 + _y) * Global.CELL_SIZE, DenseWallEntity.new())
		grid_system.add_entity_to_cell(Vector2i(Global.GRID_SIZE.x, 0  + _y) * Global.CELL_SIZE, DenseWallEntity.new())

### Control flow
## Start up
func _init() -> void:
	grid_system = GridSystem.new()
	music = SFX.new()
	sfx = SFX.new()
	current_position = Global.DEFAULT_POSITION
	grid_system.set_reference_to_parent(self)
	grid_system.create_grid_data()
	create_new_player()
	selected_entity = player
	surround_perimeter_of_map_with_dense_walls()

func _ready() -> void:

	
	floor_sprite.offset -= Vector2(Global.CELL_SIZE.x, Global.CELL_SIZE.y) / 2.0
	floor_sprite.region_rect.size = Global.GRID_SIZE * Global.CELL_SIZE
	camera.add_child(sfx.audio)
	camera.add_child(music.audio)
	
	for cell in float(length_height.x):
		if (((cell) < (float(length_height.x) / 2.0)) or ((cell) > (float(length_height.x) / 2.0) + (float(length_height.x) / 4.0))): 
			grid_system.add_entity_to_cell(Vector2i(1 + int(roundf(cell)), length_height.y) * Global.CELL_SIZE, WallEntityData.new())
		else:
			grid_system.add_entity_to_cell(Vector2i(1 + int(roundf(cell)), length_height.y) * Global.CELL_SIZE, PhasePotion.new())

## Game loop
func _process(_delta: float) -> void:
	if selected_entity:
		selected_entity_texture = selected_entity.get_texture_component()
		selected_entity_pos = selected_entity_texture.cell_position 
	
	if !music.audio.playing:
		music.play_sfx(Audio.KM)
	
	camera.position = selected_entity_pos
	if hp_bar:
		hp_bar.position = selected_entity_pos - Global.HP_BAR_OFFSET

	match current_state:
		GAME_STATE.active:
			if find_component(selected_entity, ComponentId.MOVEMENT):
				if Input.is_action_just_pressed(INVENTORY_KEY):
					access_inventory()
			
			if Input.is_action_just_pressed(TAKE_DAMAGE_KEY):
				take_damage(selected_entity, 5, PlayerCorpse.new())
			
			if Input.is_action_just_pressed(CREATE_NEW_PLAYER_KEY):
				create_new_player()
				selected_entity = player
			
			if Input.is_action_just_pressed("ui_text_delete"):
				var _location_data = grid_system.get_location_data(selected_entity_pos)
				for _entity in _location_data.entity_array:
					if find_component(_entity, ComponentId.CAN_PICK_UP):
						for _y in Global.INVENTORY_SIZE.y:
							for _x in Global.INVENTORY_SIZE.x:
								var pos: Vector2i = Vector2i(_x, _y)
								if player_inventory.get(pos) == null:
									player_inventory[pos] = _entity
									add_to_inventory(pos * Global.CELL_SIZE,_entity,player_inventory)
									grid_system.remove_entity_from_cell(selected_entity_pos, _entity)
									access_inventory()
									return
									
			
			if Input.is_action_just_pressed(DRINK_KEY):
				drink(selected_entity)
			
			input_direction = Input.get_vector(LEFT, RIGHT, UP, DOWN)
			
			can_walk_to = false
			
			if (input_direction) and (input_direction_last_frame != input_direction): 
				desired_cell_to_move_to = selected_entity_pos + (input_direction * Global.CELL_SIZE)
				location_data = grid_system.get_location_data(desired_cell_to_move_to)
				if find_component(selected_entity, ComponentId.MOVEMENT) and (location_data != null):
					can_walk_to = true
					for entity_at_next_cell in location_data.entity_array:
						solid_component = find_component(entity_at_next_cell, ComponentId.SOLID)
						if solid_component:
							if !find_component(selected_entity, ComponentId.PHASE) or solid_component.dense:
								can_walk_to = false
				else:
					can_walk_to = false
			
			if can_walk_to:
				grid_system.remove_entity_from_cell(current_position * Global.CELL_SIZE, selected_entity)
				current_position += input_direction
				grid_system.add_entity_to_cell(current_position * Global.CELL_SIZE, selected_entity)
				TurnCounterAutoload.increment_turn()
			
			input_direction_last_frame = input_direction
			
		GAME_STATE.menu_open:
			input_direction = Input.get_vector(LEFT, RIGHT, UP, DOWN)
			if (input_direction) and (input_direction_last_frame != input_direction):
				cursor_sprite.position += Vector2(input_direction) * Vector2(Global.CELL_SIZE)
				@warning_ignore("integer_division")
				cursor_sprite.position = cursor_sprite.position.clamp(-Global.CELL_SIZE, (Global.INVENTORY_SIZE * Global.CELL_SIZE)/((Global.INVENTORY_SIZE.x + Global.INVENTORY_SIZE.y)/2))
			input_direction_last_frame = input_direction
			
			if Input.is_action_just_pressed(DRINK_KEY):
				if player_inventory.has(Vector2i(cursor_sprite.position)+ Global.CELL_SIZE):
					grid_system.add_entity_to_cell(current_position * Global.CELL_SIZE, player_inventory[(Vector2i(cursor_sprite.position) + Global.CELL_SIZE)])
					remove_from_inventory(Vector2i(cursor_sprite.position) + Global.CELL_SIZE, player_inventory[Vector2i(cursor_sprite.position)+ Global.CELL_SIZE], player_inventory)
					access_inventory()
					TurnCounterAutoload.increment_turn()
			
			if Input.is_action_just_pressed(INVENTORY_KEY):
				access_inventory()

func change_state(_to_state: GAME_STATE) -> void:
	previous_state = current_state
	current_state = _to_state

func _input(_event: InputEvent) -> void:
	match current_state:
		GAME_STATE.active:
			redraw()
		GAME_STATE.menu_open: 
			show_inventory(player_inventory)

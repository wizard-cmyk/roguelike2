class_name Game
extends Node2D

var grid_system: GridSystem

var player: PlayerEntityData
var visual_array: Array[VisualInstance]

var wall: WallEntityData = WallEntityData.new()
var phase_potion: PhasePotion = PhasePotion.new()
var corpse: PlayerCorpse = PlayerCorpse.new()

@onready var floor_sprite: Sprite2D = $TiledFloorBG

@onready var music: AudioStreamPlayer2D = $Camera/Music

@onready var camera_2d: Camera2D = $Camera
const DEFAULT_POSITION: Vector2i = Vector2i(5, 5)
var current_position: Vector2i 

var sfx: SFX

var hp_bar: ProgressBar

var turn_timer: int = 0

func _init() -> void:
	
	
	sfx = SFX.new()
	add_child(sfx.audio)
	
	current_position = DEFAULT_POSITION
	
	grid_system = GridSystem.new()
	grid_system.set_reference_to_parent(self)
	grid_system.create_grid_data()
	
	create_new_player()
	
	grid_system.add_entity_to_cell(Vector2i(8, 8) * Global.CELL_SIZE, wall)
	grid_system.add_entity_to_cell(Vector2i(9, 8) * Global.CELL_SIZE, wall)
	grid_system.add_entity_to_cell(Vector2i(10, 8) * Global.CELL_SIZE, wall)
	grid_system.add_entity_to_cell(Vector2i(11, 8) * Global.CELL_SIZE, wall)
	
	grid_system.add_entity_to_cell(Vector2i(7, 8) * Global.CELL_SIZE, phase_potion)
	
	
	grid_system.create_grid_instance()
	
	for component in player.component_array:
		if component is HpComponent:
			hp_bar = ProgressBar.new()
			hp_bar.set_value(float(component.current_hp))
			hp_bar.set_max(float(component.max_hp)) 
			add_child(hp_bar)
			print(hp_bar)
	

func _ready() -> void:
	floor_sprite.offset -= Vector2(Global.CELL_SIZE.x, Global.CELL_SIZE.y)/2
	floor_sprite.region_rect.size = Global.GRID_SIZE * Global.CELL_SIZE

var input_direction_last_frame: Vector2i

func delete_all_visual_instance_sprites() -> void:
	for child in get_children():
		if child is Sprite2D:
			if child != floor_sprite:
				child.queue_free()

func redraw() -> void:
	if grid_system.grid_visual_instance != null:
		grid_system.grid_visual_instance.queue_free()
	delete_all_visual_instance_sprites()
	grid_system.create_grid_instance()
	if player != null:
		for component in player.component_array:
			if component is HpComponent:
				if hp_bar != null:
					hp_bar.set_value(float(component.current_hp))

func _unhandled_input(_event: InputEvent) -> void:
	redraw()

func drink(_drinking_entity: EntityData) -> void:
	var location_data: LocationData = grid_system.get_location_data(_drinking_entity.get_texture_component().cell_position)
	for entity in location_data.entity_array:
		if entity is PotionEntityData:
			entity.drink(_drinking_entity, entity.potion_effect)
			grid_system.remove_entity_from_cell(_drinking_entity.get_texture_component().cell_position, entity)
			sfx.play_sfx("uid://bx4wsmophttr", 15.0)

func take_damage(_entity: EntityData, _damage: int) -> void:
	var texture_component: TextureComponent
	for component in _entity.component_array:
		if component is TextureComponent:
			texture_component = component
		if component is HpComponent:
			component.current_hp -= _damage
			if component.current_hp < 1:
				if _entity is PlayerEntityData:
					var location_data: LocationData = grid_system.get_location_data(_entity.get_texture_component().cell_position)
					for entity in location_data.entity_array:
						if entity is PlayerEntityData:
							
							location_data.entity_array.erase(entity)
					for _component in _entity.component_array:
						if _component is MovementComponent:
							_component.remove_component(_entity, _component)
				grid_system.remove_entity_from_cell(texture_component.cell_position, _entity)
				grid_system.add_entity_to_cell(texture_component.cell_position, corpse)

func create_new_player() -> void:
	if player != null:
		var pos: Vector2i = player.get_texture_component().cell_position
		for entity in grid_system.get_location_data(pos).entity_array:
			if entity is PlayerEntityData:
				grid_system.get_location_data(pos).entity_array.remove_at(grid_system.get_location_data(pos).entity_array.find(entity))
	player = PlayerEntityData.new()
	grid_system.add_entity_to_cell(DEFAULT_POSITION * Global.CELL_SIZE, player)
	current_position = DEFAULT_POSITION
	redraw()


func _process(_delta: float) -> void:
	if !music.playing:
		music.playing = true
	
	camera_2d.position = player.get_texture_component().cell_position 
	hp_bar.position = player.get_texture_component().cell_position - Vector2i(0,64)
	
	var input_direction: Vector2i = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if Input.is_action_just_pressed("ui_accept"):
		drink(player)
	
	if Input.is_action_just_pressed("ui_page_up"):
		take_damage(player, 1)
	
	if Input.is_action_just_pressed("ui_page_down"):
		create_new_player()
	
	if (input_direction) and (input_direction_last_frame != input_direction): 
		var desired_cell_to_move_to: Vector2i = (current_position + input_direction) * Global.CELL_SIZE
		var location_data: LocationData = grid_system.get_location_data(desired_cell_to_move_to)
		var can_walk_to: bool = true
		for _component in player.component_array:
			if _component is MovementComponent:
				if location_data:
					for entity in location_data.entity_array:
						for component in entity.component_array:
							if component is SolidComponent:
								can_walk_to = false
								for player_component in player.component_array:
									if player_component is PhaseComponent:
										can_walk_to = true
					if can_walk_to:
						grid_system.remove_entity_from_cell(current_position * Global.CELL_SIZE, player)
						current_position += input_direction
						grid_system.add_entity_to_cell(current_position * Global.CELL_SIZE, player)
						Singleton.increment_turn()
		
				
	input_direction_last_frame = input_direction

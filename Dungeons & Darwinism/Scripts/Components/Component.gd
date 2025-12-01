class_name Component
extends Data

var id: String

var game_reference: Game
var entity_reference: EntityData

var cell_position: Vector2i

var initial_turn: int
var effect_length: int

func set_variables(_cell_position: Vector2i, _game_reference: Game) -> void:
	cell_position = _cell_position
	game_reference = _game_reference

func remove_component(_entity: EntityData, _component: Component = self) -> void:
	if _component: 
		_entity.component_array.remove_at(_entity.component_array.find(_component))

func check_to_remove_component() -> void:
	if effect_length > 0:
		if TurnCounterAutoload.turn_counter == (initial_turn + effect_length):
			remove_component(entity_reference)
			TurnCounterAutoload.turn_complete.disconnect(check_to_remove_component)

func execute() -> void:
	pass

func _init(_this_entity: EntityData) -> void:
	initial_turn = TurnCounterAutoload.turn_counter
	entity_reference = _this_entity

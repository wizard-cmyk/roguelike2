@abstract
class_name Component
extends Data

@abstract
func execute() -> void

var cell_position: Vector2i
var game_reference: Game

var initial_turn: int
var effect_length: int

var entity_reference: EntityData

func _init(_this_entity: EntityData) -> void:
	initial_turn = Singleton.turn_counter
	entity_reference = _this_entity

func set_variables(_cell_position: Vector2i, _game_reference: Game) -> void:
	cell_position = _cell_position
	game_reference = _game_reference

func remove_component(_entity: EntityData, _component: Component) -> void:
	if _component != null:
		var e = _entity.component_array.find(_component)
		_entity.component_array.remove_at(e)

func check_to_remove_component() -> void:
	if effect_length > 0:
		if Singleton.turn_counter == (initial_turn + effect_length):
			remove_component(entity_reference, self)
			Singleton.turn_complete.disconnect(check_to_remove_component)

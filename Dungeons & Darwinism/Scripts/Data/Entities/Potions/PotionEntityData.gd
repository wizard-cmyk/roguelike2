class_name PotionEntityData
extends EntityData

var potion_effect: Component
var length: int
var potion_texture: TextureComponent
var pick_up_component: CanPickUpComponent

func _init() -> void:
	id = EntityId.POTION_ENTITY_DATA
	potion_texture = TextureComponent.new(self)
	pick_up_component = CanPickUpComponent.new(self)
	potion_texture.texture = Textures.GENERIC_POTION
	component_array.append(potion_texture)
	component_array.append(pick_up_component)

func drink(_entity: EntityData, _effect: Component) -> void:
	if potion_effect:
		potion_effect.initial_turn = TurnCounterAutoload.turn_counter
		potion_effect.effect_length = length
		_entity.component_array.append(potion_effect)
		for component in _entity.component_array:
			if component == _effect:
				TurnCounterAutoload.turn_complete.connect(component.check_to_remove_component)

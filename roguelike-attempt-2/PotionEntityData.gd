class_name PotionEntityData
extends EntityData

var potion_effect: Component
var length: int

func _init() -> void:
	var potion_texture: TextureComponent = TextureComponent.new(self)
	potion_texture.texture = preload("uid://d30oyhqk10wde")
	component_array.append(potion_texture)

func drink(_entity: EntityData, _effect: Component) -> void:
	if potion_effect != null:
		potion_effect.initial_turn = Singleton.turn_counter
		potion_effect.effect_length = length
		_entity.component_array.append(potion_effect)
		for component in _entity.component_array:
			if component == _effect:
				Singleton.turn_complete.connect(component.check_to_remove_component)

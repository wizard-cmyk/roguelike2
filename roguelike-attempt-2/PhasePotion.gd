class_name PhasePotion
extends PotionEntityData

func drink(_entity: EntityData, _effect: Component) -> void:
	potion_effect = PhaseComponent.new(_entity)
	length = 5
	super.drink(_entity, potion_effect)

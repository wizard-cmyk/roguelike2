class_name TransformPotion
extends PotionEntityData

func drink(_entity: EntityData, _effect: Component) -> void:
	potion_effect = PhaseComponent.new(_entity)
	length = Potions.PHASE_POTION_LENGTH
	super.drink(_entity, potion_effect)

func _transform() -> void:
	pass

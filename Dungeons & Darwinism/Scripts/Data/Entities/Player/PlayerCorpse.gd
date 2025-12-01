class_name PlayerCorpse
extends CorpseEntityData

func _init() -> void:
	texture = Textures.PLAYER_CORPSE
	component_array.append(CanPickUpComponent.new(self))
	super._init()

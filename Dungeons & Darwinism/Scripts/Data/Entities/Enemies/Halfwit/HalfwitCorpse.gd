class_name HalfwitCorpse
extends CorpseEntityData

func _init() -> void:
	texture = Textures.HALFWIT_CORPSE
	component_array.append(CanPickUpComponent.new(self))
	super._init()

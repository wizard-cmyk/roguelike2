class_name CorpseEntityData
extends EntityData

var texture: CompressedTexture2D

var corpse_texture: TextureComponent

func _init() -> void:
	id = EntityId.CORPSE_ENTITY_DATA
	corpse_texture = TextureComponent.new(self)
	corpse_texture.texture = texture
	component_array.append(corpse_texture)

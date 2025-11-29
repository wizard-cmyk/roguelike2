class_name CorpseEntityData
extends EntityData

var texture: CompressedTexture2D

func _init() -> void:
	id = EntityId.CORPSE_ENTITY_DATA
	var corpse_texture: TextureComponent = TextureComponent.new(self)
	var hp: HpComponent = HpComponent.new(1, self)
	var solid: SolidComponent = SolidComponent.new(self)
	
	corpse_texture.texture = texture
	
	component_array.append(corpse_texture)
	component_array.append(hp)
	component_array.append(solid)

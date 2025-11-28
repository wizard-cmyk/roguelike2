class_name CorpseEntityData
extends EntityData

var texture: String

func _init() -> void:
	var corpse_texture: TextureComponent = TextureComponent.new(self)
	var hp: HpComponent = HpComponent.new(1, self)
	var solid: SolidComponent = SolidComponent.new(self)
	
	corpse_texture.texture = load(texture)
	
	component_array.append(corpse_texture)
	component_array.append(hp)
	component_array.append(solid)

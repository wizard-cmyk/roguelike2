class_name EntityData 
extends Data

var id: String

var corpse: CorpseEntityData

var component_array: Array[Component]

func get_texture_component(_component_array: Array[Component] = component_array) -> TextureComponent:
	for component in _component_array:
		if component is TextureComponent:
			return component
	return null

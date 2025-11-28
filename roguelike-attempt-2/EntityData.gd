class_name EntityData 
extends Data

var component_array: Array[Component]

func get_texture_component(_component_array: Array[Component] = component_array) -> TextureComponent:
	for i in _component_array:
		if i is TextureComponent:
			return i
	return 

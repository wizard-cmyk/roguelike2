class_name EntityData 
extends Data

var id: String

var corpse: CorpseEntityData

var component_array: Array[Component]

func take_damage(_damage: int) -> void:
	for i in component_array:
		if i is HpComponent:
			i.current_hp -= _damage
			if i.current_hp <= 0:
				perish()

func perish() -> void: 
	id = EntityId.BLANK
	component_array.clear()
	if corpse:
		corpse = corpse.duplicate()
		for i in corpse.component_array:
			component_array.append(i)

func get_texture_component(_component_array: Array[Component] = component_array) -> TextureComponent:
	for component in _component_array:
		if component is TextureComponent:
			return component
	return null

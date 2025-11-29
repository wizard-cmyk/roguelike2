class_name TextureComponent 
extends Component

var texture: Texture2D

func _init(_this_entity: EntityData) -> void:
	id = ComponentId.TEXTURE
	super._init(_this_entity)

func execute() -> void:
	var entity_visual: Sprite2D = Sprite2D.new()
	entity_visual.texture = texture
	entity_visual.position = cell_position
	game_reference.add_child(entity_visual)
	

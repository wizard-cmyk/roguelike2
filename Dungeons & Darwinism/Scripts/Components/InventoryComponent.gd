class_name InventoryComponent
extends Component

var inventory: Dictionary[Vector2i, EntityData] = { }

func _init(_this_entity: EntityData) -> void:
	id = ComponentId.INVENTORY
	super._init(_this_entity)

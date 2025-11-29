class_name SolidComponent
extends Component

var dense: bool

func _init(_this_entity: EntityData, _dense: bool = false) -> void:
	dense = _dense
	id = ComponentId.SOLID
	super._init(_this_entity)

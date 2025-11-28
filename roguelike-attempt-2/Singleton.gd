extends Node

signal turn_complete

var turn_counter: int = 0

func increment_turn() -> void:
	turn_counter += 1
	turn_complete.emit()

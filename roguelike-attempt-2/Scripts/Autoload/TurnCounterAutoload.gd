## TurnCounterAutoload
extends Node

signal turn_complete

var turn_counter: int

func _init() -> void:
	turn_counter = 0
	increment_turn()

func increment_turn() -> void:
	turn_counter += 1
	turn_complete.emit()

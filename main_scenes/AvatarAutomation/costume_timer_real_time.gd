extends Node

signal timeout

@export var wait_time_seconds: int = 300

var target_time: int = 0
var running: bool = false

func start():
	target_time = Time.get_ticks_msec() + int(wait_time_seconds * 1000)
	running = true
	
func stop():
	running = false
	
func is_stopped():
	return not running
	
func time_left():
	if not running:
		return 0
		
	return (target_time - Time.get_ticks_msec()) / 1000
	
func _process(delta: float) -> void:
	if not running:
		return
		
	if Time.get_ticks_msec() >= target_time:
		running = false
		timeout.emit()

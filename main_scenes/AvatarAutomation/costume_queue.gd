extends Node2D

var queue = []
@onready var timer: Timer = $CostumeTimer

func enqueue(costume):
	queue.push_back(costume)
	if timer.is_stopped():
		next_costume()

func dequeue():
	return queue.pop_front()
	
func is_empty():
	return queue.is_empty()

func next_costume():
	if is_empty():
		timer.stop()
		default()
		return
	var costume = dequeue()
	if Global.current_avatar != get_costume_path(costume):
		change_costume(costume)
	timer.start()
	
func change_costume(costume):
	var file_path = get_costume_path(costume)
	Global.loadAvatar(file_path)
	
func default():
	change_costume("default")
	
func get_costume_path(costume):
	var file: String = Global.redemptions.get(costume, "")
	return file
	

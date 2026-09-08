extends LineEdit


func _on_text_submitted(path: String):
	
	Global.loadAvatar(path)

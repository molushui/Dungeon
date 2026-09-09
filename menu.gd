extends CanvasLayer

func _ready() -> void:
	# 游戏开始时暂停，显示菜单
	get_tree().paused = true
	
func _on_play_button_pressed() -> void:
	get_tree().paused = false
	queue_free() # 删除菜单
	 
func _on_quit_button_pressed() -> void:
	get_tree().quit()

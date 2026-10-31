class_name GameMenu
extends CanvasLayer

static var skip_menu:bool = false

func _ready() -> void:
	if skip_menu:
		skip_menu = false
		visible = false
		get_tree().paused = false
	else:
		# 第一次游戏开始时暂停，进入菜单
		visible = true
		get_tree().paused = true
	
	
func _on_play_button_pressed() -> void:
	get_tree().paused = false
	queue_free() # 删除菜单
	 
func _on_quit_button_pressed() -> void:
	get_tree().quit()

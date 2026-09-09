extends CanvasLayer

@onready var restart_label = get_node("/root/Main/UI/GameOverBg/RestartLabel")
@onready var exp_bar_fill: ColorRect = $ExpBarBg/ExpBarFill
@onready var level_label: Label = $LevelLabel
@onready var hp_label: Label = $HP
@onready var win_bg: ColorRect = $WinBg
@onready var state_label: Label = $WinBg/StateLabel


var flash_time: float = 0 # 重新游戏闪烁间隔秒数

@warning_ignore("unused_parameter")
func update_player_ui(hp:int,max_hp:int,level:int,exp_val:int,max_exp:int) -> void:
	# 更新HP
	hp_label.text = "❤".repeat(hp)
	
	# 更新等级
	level_label.text = "Lv." + str(level)
	
	#更新经验条
	var percent = float(exp_val) / float(max_exp)
	if percent > 1.0:
		percent = 1.0
	exp_bar_fill.size.x = 200 * percent # 经验值增长（经验条总宽200像素）
	

# 接收R键输入
func _unhandled_input(event: InputEvent) -> void:
	#print("⚡ 收到输入事件: ", event) 
	# 如果游戏处于暂停且按下了 R 键
	if event.is_action_pressed("ui_restart"):
		# 恢复游戏
		get_tree().paused = false
		# 重新加载场景
		get_tree().reload_current_scene()
		
func _process(delta: float) -> void:
	# 只在GAME OVER里闪烁
	if get_tree().paused and restart_label.visible:
		
		# 累加时间（每过一帧就加一次时间）
		flash_time += delta
		
		# 频率设为 3.0 看起来更从容
		# 核心数学公式：利用正弦波在 -1 到 1 之间变化，我们将其映射到 0 到 1 之间
		# 这里的 3.0 控制闪烁速度（数字越大，闪烁越快）
		#var alpha = (sin(flash_time * 3.0) + 1.0) / 2.0
		# 第二个版本：最少保留0.3的亮度
		var alpha = 0.3 + (sin(flash_time * 3.0) + 1.0) / 2.0
		
		# 将计算出的透明度应用到标签的颜色上
		# 保持原来的颜色不变，只改透明度
		# .modulate是颜色调制器
		restart_label.modulate.a = alpha
		
func win(time: float , enemies_killed:int , level:int) ->void:
	print("win")
	# 显示 GAME OVER 界面
	win_bg.visible = true
	#restart_label.visible = true
	state_label.text = "通关用时：" + str(round(time)) + \
					   "s\n杀敌数：" + str(enemies_killed) + \
					   "\n等级：" + str(level)
	# 暂停游戏(所有物理和输入都停止)
	get_tree().paused = true
	
	

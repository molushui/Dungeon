# 让玩家能WASD移动
extends CharacterBody2D

@export var speed: float = 300.0 # 移速(像素/秒)
# @export var speed让这个变量在检查器中调节（方便调试）


# ============  生命值系统 =============
var hp: int = 3
var max_hp: int = 3
var is_invincible: bool = false # 掉血后的无敌状态（防止被秒）

# ============  成长系统 =============
var level: int = 1
var exp_val:int = 0
var max_exp:int = 8    # 升级所需经验
var attack_power:int = 1   # 基础攻击力


@onready var bullet_scene = preload("res://bullet.tscn")
@onready var hp_label = get_node("/root/Main/UI/HP")
@onready var game_over_bg = get_node("/root/Main/UI/GameOverBg")
#@onready var restart_label = get_node("/root/Main/UI/GameOverBg/RestartLabel")
@onready var ui: CanvasLayer = $"../UI"



func _ready() -> void:
	# 等一帧，确保 UI 节点已经完全初始化
	await get_tree().process_frame
	update_ui()
	
# 每帧更新
func _physics_process(_delta: float) -> void:
	# _physics_process是每帧调用，用于物理更新
	# 获取输入方向：WASD
	
	
	var direction = Vector2.ZERO
	# 这里的input是Godot内置的输入动作，默认WASD为移动，所以不用定义
	# Vector2是二维向量，direction存储方向
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
		
		
	## 🚨 新增这一行：打印方向值
	#print("方向值: ", direction)
	
	# 归一化（防止斜向移速更快）
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		# normalized()让斜向移速保持恒定，否则对角线速度会变成1.414倍
		
	#设置速度
	velocity = direction * speed
	# 调用move_and_slide() 来处理碰撞和移动（这是CharacterBody2D的自带方法，他会根据velocity移动并自动处理碰撞）
	move_and_slide()
	
	# 射击逻辑：点击鼠标左键
	if Input.is_action_just_pressed("left_click"):
		shoot()
		
# 射击函数
func shoot():
	# 1. 创建一颗子弹
	var bullet = bullet_scene.instantiate()
	# 2. 把子弹放到当前场景Main下
	get_parent().add_child(bullet)
	# 3. 子弹出生在玩家位置
	bullet.global_position = global_position
	# 4. 把玩家当前攻击力传给子弹
	bullet.damage = attack_power
	# 5. 计算从玩家执行鼠标的方向
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	bullet.direction = dir
	
# 受伤函数
func take_damage(damage: int = 1) -> void:
	# 如果处于无敌状态，则不掉血
	if  is_invincible:
		return
		
	hp -= damage
	print("❤️ 剩余血量：",hp) # 在控制台显示
	
	# 更新UI文字
	#hp_label.text = "❤".repeat(hp)
	
	
	# 受伤后进入无敌状态(0.5s)
	is_invincible = true
	await get_tree().create_timer(0.5).timeout
	is_invincible = false
	
	# 血量归零时，游戏结束
	if hp <= 0:
		game_over()
		
# 获取经验值
func gain_exp(amount:int) -> void:
	exp_val += amount
	# 循环判断是否能升多级（防止经验溢出太多）
	while exp_val >= max_exp:
		level_up()
	
	update_ui()
		
func level_up() -> void:
	exp_val -= max_exp
	level += 1
	
	# 成长数值
	attack_power += 1 # 每级攻击力 +1
	max_hp += 1 # 每级血条 +1
	hp = max_hp # 升级自动满血
	
	max_exp = int(max_exp * 2)  # 下一级所需经验值为当前等级所需的1.5倍
	
	# 打印升级信息
	print("🎉 升级！当前等级: ", level, " 攻击力: ", attack_power, " 最大HP: ", max_hp)
	
	# 更新UI
	update_ui()
	
func update_ui() -> void:
	if ui:
		ui.update_player_ui(hp,max_hp,level,exp_val,max_exp)
	
		
# 游戏结束函数
func game_over() ->void:
	print("💀 GAME OVER")
	# 显示 GAME OVER 界面
	game_over_bg.visible = true
	#restart_label.visible = true
	
	# 暂停游戏(所有物理和输入都停止)
	get_tree().paused = true

# 重新游戏函数
func _unhandled_input(event: InputEvent) -> void:
	# 如果游戏处于暂停且按下了 R 键
	if get_tree().paused and event.is_action_pressed("ui_restart"):
		# 恢复游戏
		get_tree().paused = false
		# 重新加载场景
		get_tree().reload_current_scene()

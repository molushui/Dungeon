extends Node

# 引用敌人场景
@export var enemy_scene: PackedScene
@onready var room_label: Label = $"../UI/RoomLabel"
@export var boss_scene: PackedScene
# 应用主场景和玩家
@onready var main: Node2D = $".."
@onready var player: CharacterBody2D = $"../Player"

# 当前房间层数
var current_room: int = 0

# 当前房间剩余敌人数
var enemies_alive: int = 0

# 统计变量
var game_start_time: float = 0.0
var total_kills: int = 0



# 生成敌人用的随机数生成器
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	# 等到下一帧再进入第一层，确保场景完全加载
	print("开始")
	await get_tree().process_frame
	print("一帧结束，准备调用nextroom")
	# 记录开局时间（秒）
	game_start_time = Time.get_ticks_msec() / 1000.0
	# 直接进入第一层
	next_room()
	
func next_room() -> void:
	
	# 层数 +1
	current_room += 1
	print("nextroom被调用，当前层数",current_room)
	
	# 更新右上角楼层显示
	if room_label:
		room_label.text = "第" + str(current_room) + "层"
		
	await get_tree().process_frame   #  延迟一帧
	
	# 清理上一层残留敌人
	for child in main.get_children():
		if child is CharacterBody2D and child != player and child.is_in_group("enemies"):
			child.queue_free()
	
	await get_tree().process_frame   #  延迟一帧
	
	# 清理上一层残留子弹
	for child in main.get_children():
		if child is Area2D and child.is_in_group("bullets"):
			child.queue_free()
	 
	await get_tree().create_timer(0.3).timeout   # 延迟0.3秒
	
	# 若进入第 5 层，判断为 BOSS 层，退出函数
	if current_room == 5:
		spawn_boss()
		return
	
	# 否则为 普通 层
	# 计算这一层要出多少敌人
	var count = 2 + current_room * 3
	
	# 若层数太高，限制一下，防止卡死
	if count > 15:
		count = 15
		
	
	# 生成敌人
	spawn_enemies(count)
	


# 生敌函数		
func spawn_enemies(count:int) -> void:
	enemies_alive = count
	print("开始生敌👾，数量：",count)
	
	for i in range(count):
		# 实例化一个敌人
		var enemy = enemy_scene.instantiate()
		enemy.add_to_group("enemies")
		# 添加到主场景Main下
		main.add_child.call_deferred(enemy)
		#main.add_child(enemy)
		
		var enemy_hp = 1 + (current_room-1)
		if enemy_hp >= 5:
			enemy_hp = 5
		enemy.hp = enemy_hp
		enemy.max_hp = enemy_hp
		
		print("尝试生成位置🗺️")
		# 在地图内部随机找一个位置
		var x = rng.randf_range(150,1000)
		var y = rng.randf_range(25,225)
		# var y = rng.randf_range(25,625)
		enemy.global_position = Vector2(x,y)
		
		# 根据层数增加敌人移速（增加难度）
		# 基础速度 120 ，每层 +20
		enemy.speed = 100 + current_room * 20
		# 封顶 350，保证游戏平衡
		if enemy.speed > 350:
			enemy.speed = 350
			
			
func spawn_boss() -> void:
	var boss = boss_scene.instantiate()
	main.add_child.call_deferred(boss)
	boss.global_position = Vector2(600 , 200)
	# BOSS 不计入普通敌人数，单独管理
	enemies_alive = 1  # 这里用enemies_alive = 1作为 BOSS 是否存活的标志
	#update_room_label() ??????
	
	
			
# 这个计数器函数被敌人调用，每次敌人死亡时通知manager(该函数只在非BOSS层处理）
# 功能：1、计数场上剩余敌人
#      2、无敌人时，进入下一关
func on_enemy_died() -> void:
	if current_room >= 5:
		return
		
	enemies_alive -= 1
	total_kills += 1 # 杀敌计数器
	# 给玩家加经验(基础1点，随层数增加）
	if player:
		var exp_reward = 1 + ( current_room - 1 )
		player.gain_exp(exp_reward)
	
	# 敌人死光时
	if enemies_alive <= 0:
		# 等待一秒后（模拟门开），进入下一层
		await get_tree().create_timer(1.0).timeout
		next_room()
		
func on_boss_defeated() -> void:
	# 给玩家大量经验
	if player:
		player.gain_exp(50 + current_room * 10)
		
	var end_time = Time.get_ticks_msec() / 1000.0
	var time = end_time - game_start_time
	
	var ui = get_node("/root/Main/UI")
	# 进入胜利状态
	await  get_tree().create_timer(1.0).timeout
	
	# 触发胜利画面
	if ui and ui.has_method("win"):
		ui.win(time , total_kills , player.level)



		
			
	

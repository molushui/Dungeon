extends CharacterBody2D

@export var speed: float = 150 # 敌人移速

# 这里通过路径找到玩家（假设玩家是Main场景的下的Player）
@onready var player = get_node("/root/Main/Player")
@onready var room_manager: Node = $"../RoomManager"

# 怪物血量
var hp:int = 1
var max_hp:int = 1



func _physics_process(delta: float) -> void:
	
	# 如果玩家死了/不存在，就停下来
	if player == null:
		return
		
	# 计算指向玩家的方向向量
	var direction = (player.global_position - global_position).normalized()
	# player.global_position - global_position就是“玩家位置减去敌人位置”，得到的是一个指向玩家的向量
	# normalized()就是把它压缩成“方向”（长度为1）
	
	# 设置速度并移动
	velocity = direction * speed
	move_and_slide()
	
	#检测是否碰撞到玩家
	for i in get_slide_collision_count():
		# get_slide_collision_count()获取本次移动发生的所有碰撞
		
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		# 如果撞到的是玩家
		if collider.name == "Player":
			# 调用玩家的受伤函数
			collider.take_damage(1)
			# 敌人消失（牺牲）
			queue_free()

# 掉血函数
func take_damage(damage:int) -> void:
	hp -= damage
	# 受伤闪白效果（视觉反馈，先留个借口）
	if hp <= 0:
		die()
		
func die() -> void:
	if room_manager:
		room_manager.on_enemy_died()
		# 销毁自己
		queue_free()

## 当敌人从场景中被移除，自动调用该函数	
#func _exit_tree() ->void:
	##确保管理器还存在（防止游戏关闭时报错）
	#if room_manager:
		#room_manager.on_enemy_died()

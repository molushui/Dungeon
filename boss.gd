extends CharacterBody2D

@export var speed: float = 100.0
@export var max_hp: int = 20
@export var attack_damage: int = 2

var hp: int
var player: Node
var room_manager: Node

# 攻击状态
enum AttackState { IDLE , CHASE , DASH , AOE}
var current_state:AttackState = AttackState.IDLE
var state_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var dash_speed: float = 400.0
var is_dashing:bool = false

@onready var health_bar_fill: ColorRect = $HealthBarBg/HealthBarFill
@onready var sprite: Sprite2D = $Sprite2D

@onready var bullet_scene = preload("res://bossbullet.tscn")


func _ready() -> void:
	add_to_group("enemies")  # 给 Boss 加入怪物分组，不然子弹打不到
	hp = max_hp
	player = get_node("/root/Main/Player")
	#player = get_node("$Player/Sprite2D")
	room_manager = get_node("/root/Main/RoomManager")
	# 初始状态：追踪玩家
	current_state = AttackState.CHASE
	update_health_bar()
	
func _physics_process(delta: float) -> void:
	if not player:
		return
	
	# 如果 BOSS 死亡，就什么也不做
	if hp <= 0 :
		return
		
	# 状态机
	state_timer += delta
	
	match current_state:
		AttackState.CHASE:
			chase_player(delta)
			# 每 2-3 秒切换一次攻击
			if state_timer > randf_range(2.0,4.0):
				choose_next_attack()
				state_timer = 0.0
		
		AttackState.DASH:
			if not is_dashing:
				# 启动冲刺
				is_dashing = true
				dash_direction = (player.global_position - global_position).normalized()
			# 冲刺移动
			var collision = move_and_collide(dash_direction * dash_speed * delta)
			if collision:
				# 如果撞到玩家或墙壁，结束冲刺
				if collision.get_collider() == player:
					player.take_damage(attack_damage)	
				is_dashing = false
				current_state = AttackState.IDLE
				state_timer = 0.0
				
				# 冲刺最多持续 0.5s
				if state_timer > 0.5:
					is_dashing = false
					current_state = AttackState.IDLE
					state_timer = 0.0
				
		AttackState.AOE:
			# 范围攻击:生成一圈子弹 或 直接对玩家造成伤害
			if state_timer < 0.1:
				# 在BOSS周围生成8颗子弹（复用bullet.tscn）
				for i in range(8):
					var angle = i * PI / 4
					var bullet = bullet_scene.instantiate()
					get_parent().add_child(bullet)
					bullet.global_position = global_position
					bullet.direction = Vector2(cos(angle),sin(angle))
					bullet.speed = 150
					bullet.damage = 1
					# 让子弹变为“敌方子弹”，需要单独处理
				current_state = AttackState.IDLE
				print("boss发射了子弹")
				state_timer = 0.0
				
		AttackState.IDLE:
			# 短暂休息(后摇）
			if state_timer > 0.8:
				current_state = AttackState.CHASE
				state_timer = 0.0
				
				
func chase_player(delta:float) -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
func choose_next_attack() -> void:
	# 攻击随机选择 冲刺 or 范围攻击
	var rng = RandomNumberGenerator.new()
	var choice = rng.randi_range(0,1)
	if choice == 0:
		current_state = AttackState.DASH
	else:
		current_state = AttackState.AOE
	state_timer = 0.0
	
func take_damage(damage:int) -> void:
	hp -= damage
	update_health_bar()
	if hp <= 0:
		die()

	
# 渲染 boss 头顶血条
func update_health_bar() -> void:
	var percent = float(hp) / float(max_hp)
	health_bar_fill.size.x = 120 * percent
	
func die() -> void:
	# 通知房间管理器 BOSS 死亡
	if room_manager:
		room_manager.on_boss_defeated()
	queue_free()
	

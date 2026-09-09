extends Area2D

@export var speed : int =  500 # 子弹飞的快点

# 这个变量用来接收发射时的方向
var direction: Vector2 = Vector2.ZERO
var damage:int = 1 # 默认伤害（会被玩家攻击力覆盖）

func _ready() -> void:
	
	# 2秒后如果子弹没撞到东西，自动消失（防止内存泄漏）
	await get_tree().create_timer(2.0).timeout
	queue_free()
	
func _physics_process(delta: float) -> void:
	# 按照发射时的方向移动
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	# 🚨 第一行：打印它撞到的节点名字和类型
	print("子弹撞到了: ", body.name, " 类型: ", body.get_class())
	# 如果撞到的是敌人
	if body is CharacterBody2D and body.is_in_group("enemies"):
		body.take_damage(damage) # 计算怪物掉血
		queue_free() 	  # 子弹也消失
		
	# 如果撞到的是墙壁
	elif body is StaticBody2D:
		queue_free() 	  # 子弹消失
		
		
		

extends CharacterBody2D

@export var speed : int =  300 # 子弹飞的快点

var direction: Vector2 = Vector2.ZERO
var damage: int = 1
var bounce_left: int = 3  # 最多反弹 3 次

func _ready() -> void:
	# 3 s后子弹自动消失
	await get_tree().create_timer(3.0).timeout   # 延迟 3 秒
	queue_free()
	
func _physics_process(delta: float) -> void:
	var  collision = move_and_collide(direction * speed * delta)
	if collision:
		print("💥 子弹撞到了: ", collision.get_collider().name, " 法线: ", collision.get_normal())
		var collider = collision.get_collider()
		
		# 撞到玩家，扣血and消失
		if collider.name == "Player":
			collider.take_damage(damage)
			queue_free()
			return
			
		# 撞到墙壁，反弹
		var normal = collision.get_normal()
		direction = direction.bounce(normal)
		
		bounce_left -= 1
		if bounce_left <= 0:
			queue_free()

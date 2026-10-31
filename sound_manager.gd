extends Node

# 预加载所有音效，播放时就零延迟
var sounds = {
	"victory":preload("res://sound/victory.mp3")
}

# 用一个 AudioStreamPlayer 节点来播放音效
var player: AudioStreamPlayer

func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	# 音量调小点
	player.volume_db = -5.0
	print("🎧 SoundManager 初始化完成，player 是否在场景树中: ", player.is_inside_tree())
# 播放音乐函数
func play(sound_name:String , pitch:float = 1.0) -> void:
	if not sounds.has(sound_name):
		return
	player.stream = sounds[sound_name]
	player.pitch_scale = pitch #音调（1.0 是原调。大于 1 变尖 ，反之变沉）
	player.play()
	print("✅ 播放中: ", player.playing, " 音量: ", player.volume_db)
	

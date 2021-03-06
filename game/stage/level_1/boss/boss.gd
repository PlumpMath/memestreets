extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var STAGE
var EFFECTS
var PLAYER

export var ACTIVE = false
export var MAX_HEALTH = 200
export var HEALTH = 100
var RAYCAST_ATTACK
export var ATTACK_DAMAGE = 10
export var ATTACK_DELAY = 1
var ATTACK_TIMER = ATTACK_DELAY
export var KILL_SCORE = 100
export var FIND_PLAYER_RADIUS = 400

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	STAGE = self.get_node("/root/Stage")
	EFFECTS = self.get_node("SamplePlayer")
	RAYCAST_ATTACK = self.get_node("RayCastAttack")
	PLAYER = self.get_node("/root/Stage/Player")
	
	STAGE.connect(STAGE.SIGNAL_PLAYER_DIED, self, "handle_player_died")
	
	HEALTH = MAX_HEALTH
	self.speech_off()
	self.set_process(ACTIVE)

func _process(delta):
	if(self.get_global_pos().distance_to(PLAYER.get_global_pos()) <= FIND_PLAYER_RADIUS):
		self.move(-(self.get_global_pos() - PLAYER.get_global_pos()).normalized())
		
	ATTACK_TIMER += delta
	
	if(ATTACK_TIMER >= ATTACK_DELAY):
		RAYCAST_ATTACK.set_enabled(true)
		RAYCAST_ATTACK.force_raycast_update()
		if(RAYCAST_ATTACK.is_colliding()):
			var obj = RAYCAST_ATTACK.get_collider()
			if(obj.is_in_group('player')):
				EFFECTS.play("sfx_damage_hit10")
				ATTACK_TIMER = 0
				obj.take_damage(ATTACK_DAMAGE)
		RAYCAST_ATTACK.set_enabled(false)
	

func take_damage(amount):
	HEALTH -= amount
	if(HEALTH <= 0):
		STAGE.emit_signal_enemy_died(KILL_SCORE)
		self.get_tree().change_scene("res://you_win/you_win.tscn")
		self.set_process(false)
		self.hide()
		self.queue_free()

func handle_player_died():
	self.set_process(false);

func speech_on():
	self.get_node("SpeechBubble").show()

func speech_off():
	self.get_node("SpeechBubble").hide()

func set_active():
	ACTIVE = true
	self.set_process(ACTIVE)
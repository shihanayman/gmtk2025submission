extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -200.0
enum Phase {
	NEUTRAL,
	BLACK,
	WHITE
}
var current_phase = Phase.NEUTRAL

var ability_counter = 0
var dash_direction = 0
var direction_last_facing = -1
var can_coyote_jump = false
func _ready():
	$AnimatedSprite2D.play("both")
func _phase_change():
	if Input.is_action_just_pressed("left_click"):
		if $AnimatedSprite2D.get_animation() == "black":
			$AnimatedSprite2D.play("both")
			current_phase = Phase.NEUTRAL
		else:
			$AnimatedSprite2D.play("black")
			current_phase = Phase.BLACK
	if Input.is_action_just_pressed("right_click"):
		if $AnimatedSprite2D.get_animation() == "white":
			$AnimatedSprite2D.play("both")
			current_phase = Phase.NEUTRAL
		else:
			$AnimatedSprite2D.play("white")
			current_phase = Phase.WHITE
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 6
		if can_coyote_jump:
			$coyote_timer.start()
			can_coyote_jump = false
	if is_on_floor():
		ability_counter = 0
		can_coyote_jump = true
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or !$coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
		$jump_timer.start()
	if !$jump_timer.is_stopped():
		if Input.is_action_pressed("jump"):
			velocity.y += JUMP_VELOCITY
	var direction := Input.get_axis("left", "right")
	if Input.is_action_just_pressed("jump") and current_phase == Phase.WHITE and !is_on_floor():
				if ability_counter <1 and !is_on_floor():
					velocity.y = JUMP_VELOCITY * 6
					ability_counter+=1
				
	if Input.is_action_just_pressed("ability"):
		if ability_counter <1:
					$dash_timer.start()
					ability_counter +=1
					dash_direction = direction_last_facing
	if !$dash_timer.is_stopped():
		velocity.x = dash_direction * 2000
		velocity.y = 0
	if direction and $dash_timer.is_stopped():
		velocity.x = direction * SPEED
		direction_last_facing = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) 
	_phase_change()
	move_and_slide()

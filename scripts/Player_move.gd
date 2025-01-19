extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -380.0

var is_crouching = false
var stuck_under_object = false
@onready var crouch_raycast1 = $CrouchRayCast_1
@onready var crouch_raycast2 = $CrouchRayCast_2


func _ready():
	$CrouchingHitbox.disabled = true  # Start with standing hitbox enabled

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		$AnimatedSprite2D.animation = "jump"
	
	# Handle crouch input.
	if Input.is_action_just_pressed("crouch"):
		crouch()
	elif Input.is_action_just_released("crouch"):
		if above_head_is_empty():
			stand()
		else:
			if stuck_under_object != true:
				stuck_under_object = true
	if stuck_under_object && above_head_is_empty():
		stand()
		stuck_under_object = false

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY

	# Handle crouch animation.
	if is_crouching:
		$AnimatedSprite2D.animation = "crouch"
		# Allow movement while crouching
		var crouch_direction := Input.get_axis("ui_left", "ui_right")
		if crouch_direction:
			velocity.x = crouch_direction * (SPEED * 0.5)  # Reduce speed while crouching
			$AnimatedSprite2D.flip_h = crouch_direction < 0  # Flip sprite based on direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * 0.5)  # Slow down while crouching
	else:
		# Get the input direction and handle the movement/deceleration.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			$AnimatedSprite2D.animation = "run"
			$AnimatedSprite2D.flip_h = direction < 0  # Flip sprite based on direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor():
				$AnimatedSprite2D.animation = "idle"

	# Apply gravity and move the character
	move_and_slide()
	
func above_head_is_empty():
	var result = !crouch_raycast1.is_colliding() && !crouch_raycast2.is_colliding()
	return result

func crouch():
	if is_crouching:
		return
	is_crouching = true
	$StandingHitbox.disabled = true  # Disable standing hitbox
	$CrouchingHitbox.disabled = false  # Enable crouching hitbox

func stand(): 
	if not is_crouching:
		return
	is_crouching = false
	$StandingHitbox.disabled = false  # Enable standing hitbox
	$CrouchingHitbox.disabled = true  # Disable crouching hitbox

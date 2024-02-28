extends KinematicBody2D

var velocity = Vector2()
var canJump = true

var doubleTap := 0.25
var timeout := false

var dir = 1
var isChangeDir = false
var DTL = false
var DTR = false

export (int) var movespeed = 400
export (int) var jump = -600
export (int) var GRAVITY = 1200

export (int) var movementState := 0
enum moveStates {
	idle,
	walking,
	jumping,
	falling,
	crouching,
	dashing,
	sliding
}

onready var ap = $AnimationPlayer
onready var sprite = $Sprite

signal movementState_changed(old_value, new_value)

const UP = Vector2(0,-1)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_input():
	var speed = movespeed
	
	#print(movementState)
	
	var prevMoveState = movementState
	
	if velocity.x == 0 and is_on_floor():
		movementState = 0
		dir = 0
	
	if velocity.y > 0 and !is_on_floor():
		movementState = 3
		
		if prevMoveState != movementState:
			print("falling")
	
	# Sprint Left
	if is_on_floor() and Input.is_action_just_pressed("move_left"):
		if !DTL:
			DTL = true
			$DTT.start()
		elif is_on_floor() and DTL:
			movementState = 5
			print("sprinting")
			velocity.y = -100
		elif timeout or isChangeDir:
			DTL = false
	
	# Sprint Right
	if is_on_floor() and Input.is_action_just_pressed("move_right"):
		if !DTR:
			DTR = true
			$DTT.start()
		elif is_on_floor() and DTR:
			movementState = 5
			print("sprinting")
			velocity.y = -100
		elif timeout or isChangeDir:
			DTR = false
	
	if is_on_floor():
		velocity.x -= 0.5 * velocity.x
	else:
		velocity.x -= 0.02 * velocity.x
	
	if Input.is_action_just_pressed("crouch"):
		if movementState == 5 and is_on_floor(): # Check if dashing
			velocity.x += dir * movespeed
			speed = movespeed * 1.5
			print("sliding")
			movementState = 6 # Set sliding
		else:
			speed = movespeed/2
			velocity.y += 200
			print("crouching")
			movementState = 4 # Set crouching
	elif Input.is_action_pressed("crouch"):
		speed = movespeed/2
		movementState = 4 # Set crouching
	
	if movementState == 5:
		speed *= 5
	
	if velocity.y > 0:
		movementState = 3
	
	if Input.is_action_pressed('move_right'):
		velocity.x = speed
		
		if dir != 1:
			dir = 1
			isChangeDir = true
			
		if movementState == 0:
			movementState = 1
		
	if Input.is_action_pressed('move_left'):
		velocity.x = -speed
		
		if dir != 1:
			dir = -1
			isChangeDir = true
			
		if movementState == 0:
			movementState = 1
	
	if is_on_floor() and Input.is_action_just_pressed('jump'):
		velocity.y = jump
		canJump = true
		movementState = 2 # Set jumping
		print("jumping")
	
	if !is_on_floor() and canJump and Input.is_action_just_pressed('jump'):
		velocity.y = jump
		canJump = false
		movementState = 2 # Set jumping
		print("jumping x2")
	
	if velocity.x == 0 and velocity.y == 0:
		movementState = 0
	elif velocity.y > 0:
		movementState = 3
		
	if movementState != prevMoveState:
		emit_signal("movementState_changed", prevMoveState, movementState)
		toggle_animation(movementState)
		#print("change!")
	
	if dir == 0:
		sprite.flip_h = (dir == -1)
	
func _physics_process(delta):
	velocity.y += delta * GRAVITY
	
	get_input()
	
	velocity.normalized()
	
	velocity = move_and_slide(velocity, UP)
	
func toggle_animation(state):
	if velocity.x == 0:
		ap.play("idle")
	elif movementState == 5:
		ap.play("running")
	elif movementState == 4:
		ap.play("crouching")
	elif movementState == 6:
		ap.play("sliding")
	elif movementState == 1:
		ap.play("walking")
	elif movementState == 2:
		ap.play("jumping")
	else:
		ap.play("falling")


func _on_DTT_timeout():
	pass # Replace with function body.

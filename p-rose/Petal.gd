extends CharacterBody3D




var  SPEED = 5.0




const  SPRINT_SPEED = 9.0
const  WALK_SPEED = 5.0

const JUMP_VELOCITY = 8

const TIMER_LIMIT = 0.1
var timer = 0.0

func get_perspective_spring() -> SpringArm3D:
	if Global.PERSPECTIVE == Global.camera_perspective.third:
		var spring: SpringArm3D = get_node("third_person_arm")
		return spring
	elif Global.PERSPECTIVE == Global.camera_perspective.first:
		var spring: SpringArm3D =get_node("first_person_arm")
		return spring
	else:
		return get_node("third_person_arm")


@onready
var spring_arm: SpringArm3D = get_perspective_spring()
@onready
var model : MeshInstance3D = get_node("MeshInstance3D")
@onready
var fps_counter : Label = spring_arm.get_node("camera/Panel/Label")
@onready
var speed_counter : Label = spring_arm.get_node("camera/Panel/Label3")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var look_direction: Vector2 = Vector2.ZERO





func get_direction() -> Vector3:
	var input_direction: Vector2 = Input.get_vector("left", "right", "forward", "back" )
	var direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_arm.rotation.y).normalized()

	return direction

func decide_speed(boost, delta):
	if Input.is_action_pressed("sprint") and is_on_floor():#) and is_on_floor()) :#or ((not is_on_floor() and SPEED == SPRINT_SPEED) and Input.is_action_pressed("sprint")) :
		SPEED = SPRINT_SPEED * boost
	elif (SPEED > WALK_SPEED) and not is_on_floor(): 
		SPEED -= WALK_SPEED * 0.25 * delta
	elif not is_on_floor() and (SPEED > WALK_SPEED/1.5):
		SPEED -= WALK_SPEED * 0.25 * delta
	else:
		SPEED = WALK_SPEED 

func diagnostics(delta):
	timer += delta
	if timer > TIMER_LIMIT: # Prints every 1 seconds
		timer = 0.0
		fps_counter.text = "FPS: " + str(Engine.get_frames_per_second())
		speed_counter.text = "Speed:"  + str(snapped(velocity.length(), 0.01)) 

	
func _ready():
	var camera: Camera3D = spring_arm.get_node("camera")
	camera.set_current(true)

func change_perspective():
	if Global.PERSPECTIVE == Global.camera_perspective.first:
		Global.PERSPECTIVE = Global.camera_perspective.third

		spring_arm = get_perspective_spring();
		spring_arm.get_node("camera").set_current(true)
		
		
	elif Global.PERSPECTIVE == Global.camera_perspective.third:
		Global.PERSPECTIVE = Global.camera_perspective.first
		spring_arm = get_perspective_spring();
		
		spring_arm.get_node("camera").set_current(true)

	

func _physics_process(delta):
	diagnostics(delta)
	
	if Input.is_action_just_pressed("change_perspective"):
		change_perspective()

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
		decide_speed(1.25, delta)
	else:
		decide_speed(1, delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: Vector3 = get_direction()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	if Global.PERSPECTIVE == Global.camera_perspective.third:
		if velocity.length() > 0.2 :
			if direction:
				look_direction= Vector2(velocity.z, velocity.x)
				model.rotation.y = look_direction.angle()
		

		

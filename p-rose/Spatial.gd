extends SpringArm3D

var mouse_sensitivity = 0.05; 

@onready
var parent: CharacterBody3D = get_parent();

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.PERSPECTIVE == Global.camera_perspective.third:
		if Input.is_action_just_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.is_action_just_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



	


func _input(event):
	#if Global.PERSPECTIVE == Global.camera_perspective.third:
		if event is InputEventMouseMotion:
			
			rotation_degrees.x -= event.relative.y * mouse_sensitivity
			rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)

			rotation_degrees.y -= event.relative.x *mouse_sensitivity
			rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360)

	

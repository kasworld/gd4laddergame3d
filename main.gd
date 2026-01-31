extends Node3D

const WorldSize := Vector3(160,90,80)

func on_viewport_size_changed() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var 짧은길이 :float = min(vp_size.x, vp_size.y)
	var panel_size := Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$"왼쪽패널".size = panel_size
	$"왼쪽패널".custom_minimum_size = panel_size
	$오른쪽패널.size = panel_size
	$"오른쪽패널".custom_minimum_size = panel_size
	$오른쪽패널.position = Vector2(vp_size.x/2 + 짧은길이/2, 0)

func label_demo() -> void:
	if $"오른쪽패널/LabelPerformance".visible:
		$"오른쪽패널/LabelPerformance".text = """%d FPS (%.2f mspf)
Currently rendering: occlusion culling:%s
%d objects
%dK primitive indices
%d draw calls""" % [
		Engine.get_frames_per_second(),1000.0 / Engine.get_frames_per_second(),
		get_tree().root.use_occlusion_culling,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) * 0.001,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		]
	if $"오른쪽패널/LabelInfo".visible:
		$"오른쪽패널/LabelInfo".text = "%s" % [ MovingCameraLight.GetCurrentCamera() ]

func _ready() -> void:
	on_viewport_size_changed()
	get_viewport().size_changed.connect(on_viewport_size_changed)

	$OmniLight3D.omni_range = WorldSize.length()*3
	$FixedCameraLight.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	$MovingCameraLightHober.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	$MovingCameraLightAround.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	$AxisArrow3D.set_colors().set_size(WorldSize.length()/20)

	$GlassCabinet.init(WorldSize)
	ladder_demo($GlassCabinet)

func _process(delta: float) -> void:
	var now := Time.get_unix_time_from_system()
	if $MovingCameraLightHober.is_current_camera():
		$MovingCameraLightHober.move_hober_around_z(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )
	elif $MovingCameraLightAround.is_current_camera():
		$MovingCameraLightAround.move_wave_around_y(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )

	label_demo()
	ladder.rotate_y(delta/2)

func _on_카메라변경_pressed() -> void:
	MovingCameraLight.NextCamera()
func _on_끝내기_pressed() -> void:
	get_tree().quit()
func _on_fov_inc_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().camera_fov_inc()
func _on_fov_dec_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().camera_fov_dec()

var key2fn = {
	KEY_ESCAPE:_on_끝내기_pressed,
	KEY_ENTER:_on_카메라변경_pressed,
	KEY_PAGEUP:_on_fov_inc_pressed,
	KEY_PAGEDOWN:_on_fov_dec_pressed,
}
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var fn = key2fn.get(event.keycode)
		if fn != null:
			fn.call()
		if $FixedCameraLight.is_current_camera():
			var fi = FlyNode3D.Key2Info.get(event.keycode)
			if fi != null:
				FlyNode3D.fly_node3d($FixedCameraLight, fi)
	elif event is InputEventMouseButton and event.is_pressed():
		pass

var ladder :사다리게임
var 길번호 :int
var 밝은색목록 :ListIter = ListIter.new(NamedColors.filter_light_color_list())
func ladder_demo(gc :GlassCabinet) -> void:
	gc.show_wall_box(false)
	var 참가자정보 :Array
	for i in 8:
		참가자정보.append( ["출발%d" % [i+1], 밝은색목록.get_current_and_step_next(), "도착%d" % [i+1] ] )

	ladder = preload("res://사다리게임/사다리게임.tscn").instantiate(
		).init(WorldSize, 참가자정보)
	gc.add_child(ladder)
	ladder.사다리풀이그리기()
	$"Timer깜빡이".start(3.0)

func _on_timer깜빡이_timeout() -> void:
	ladder.길하나보기(길번호)
	길번호 = (길번호+1) % ladder.참가자정보.size()

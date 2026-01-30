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

	$"왼쪽패널/Scroll출발".get_v_scroll_bar().scrolling.connect(_on_참가자_scroll_scroll_started)
	$"오른쪽패널/Scroll도착".get_v_scroll_bar().scrolling.connect(_on_도착지점_scroll_scroll_started)
	for i in Settings.시작칸수:
		참가자추가하기()

func _process(_delta: float) -> void:
	var now := Time.get_unix_time_from_system()
	if $MovingCameraLightHober.is_current_camera():
		$MovingCameraLightHober.move_hober_around_z(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )
	elif $MovingCameraLightAround.is_current_camera():
		$MovingCameraLightAround.move_wave_around_y(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )

	label_demo()

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

	KEY_INSERT:참가자추가하기,
	KEY_DELETE:마지막참가자제거하기,
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


############################

@onready var 참가자들 = $"왼쪽패널/Scroll출발/출발목록"
@onready var 도착지점들 = $"오른쪽패널/Scroll도착/도착목록"


func _on_참가자추가_pressed() -> void:
	$"사다리게임".참가자추가하기()

func _on_참가자제거_pressed() -> void:
	$"사다리게임".마지막참가자제거하기()

func _on_참가자_scroll_scroll_started() -> void:
	$"오른쪽패널/Scroll도착".scroll_vertical = $"왼쪽패널/Scroll출발".scroll_vertical

func _on_도착지점_scroll_scroll_started() -> void:
	$"왼쪽패널/Scroll출발".scroll_vertical = $"오른쪽패널/Scroll도착".scroll_vertical

func _on_만들기_pressed() -> void:
	$"사다리게임".사다리문제그리기()

func _on_풀기_pressed() -> void:
	$"사다리게임".사다리풀이그리기()

func _on_깜빡이기_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$"Timer깜빡이".start(1.0)
	else:
		$"Timer깜빡이".stop()
		$"사다리게임".깜빡이기_종료()

func _on_timer깜빡이_timeout() -> void:
	$"사다리게임".깜빡이기()

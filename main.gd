extends Node3D

@onready var 참가자들 = $"왼쪽패널/Scroll출발/출발목록"
@onready var 도착지점들 = $"오른쪽패널/Scroll도착/도착목록"

var 화살표 = preload("res://arrow3d/arrow3d.tscn")

var 참가자색 :Array[Color]
var camera_move = false
var 사다리자료 :사다리Lib

func 사다리칸수() -> Vector2i:
	var n = 참가자들.get_child_count()
	return Vector2i(n, n*3 )

func _ready() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	var r = min(vp_size.x,vp_size.y)/2
	RenderingServer.set_default_clear_color( GlobalLib.colors.default_clear)
	$DirectionalLight3D.position = Vector3(r,r,r)
	$DirectionalLight3D.look_at(Vector3.ZERO)
	$OmniLight3D.position = Vector3(r,-r,r)
	reset_camera_pos()
	$"왼쪽패널".size = Vector2(vp_size.x/2 -r, vp_size.y)
	$오른쪽패널.size = Vector2(vp_size.x/2 -r, vp_size.y)
	$오른쪽패널.position = Vector2(vp_size.x/2 + r, 0)
	$"왼쪽패널/Scroll출발".get_v_scroll_bar().scrolling.connect(_on_참가자_scroll_scroll_started)
	$"오른쪽패널/Scroll도착".get_v_scroll_bar().scrolling.connect(_on_도착지점_scroll_scroll_started)
	for i in Settings.시작칸수:
		참가자추가하기()

func 위치3D정리하기() -> void:
	var n := $"사다리/세로기둥".get_child_count()
	var r := 10 * n
	for i in n:
		var o = $"사다리/세로기둥".get_child(i)
		o.position = GlobalLib.make_pos_by_rad_r_3d(2*PI*i/n, r)
		o.mesh.height = n * 30
		o = $"사다리/출발목록".get_child(i)
		o.position = GlobalLib.make_pos_by_rad_r_3d(2*PI*i/n, r, n * 15 + 10)
		o = $"사다리/도착목록".get_child(i)
		o.position = GlobalLib.make_pos_by_rad_r_3d(2*PI*i/n, r, -n * 15 - 10)

func 참가자추가하기() -> void:
	var i = 참가자들.get_child_count()
	if i >= Settings.최대칸수:
		return
	참가자색.append(NamedColorList.color_list.pick_random()[0])
	var 참가자 = GlobalLib.LineEdit만들기("출발%d" % [i+1], 참가자색[i])
	참가자.text_changed.connect(
		func(t :String):
			$"사다리/출발목록".get_child(i).text = t
	)
	참가자.text_submitted.connect(
		func(t :String):
			참가자.release_focus()
	)
	참가자들.add_child(참가자)
	var 도착점 = GlobalLib.LineEdit만들기("도착%d" % [i+1], 참가자색[i])
	도착점.text_changed.connect(
		func(t :String):
			$"사다리/도착목록".get_child(i).text = t
	)
	도착점.text_submitted.connect(
		func(t :String):
			도착점.release_focus()
	)
	도착지점들.add_child(도착점)
	$"사다리/세로기둥".add_child(GlobalLib.기둥만들기(300, 5, 참가자색[i]))
	$"사다리/출발목록".add_child(GlobalLib.Label3D만들기("출발%d" % [i+1], 참가자색[i]))
	$"사다리/도착목록".add_child(GlobalLib.Label3D만들기("도착%d" % [i+1], 참가자색[i]))
	위치3D정리하기()

func 마지막참가자제거하기() -> void:
	var 현재참가자수 = 참가자들.get_child_count()
	if 현재참가자수 <= Settings.최소칸수:
		return
	참가자색.pop_back()
	참가자들.remove_child(참가자들.get_child(현재참가자수-1))
	도착지점들.remove_child(도착지점들.get_child(현재참가자수-1))
	$"사다리/세로기둥".remove_child($"사다리/세로기둥".get_child(현재참가자수-1))
	$"사다리/출발목록".remove_child($"사다리/출발목록".get_child(현재참가자수-1))
	$"사다리/도착목록".remove_child($"사다리/도착목록".get_child(현재참가자수-1))
	위치3D정리하기()

func reset_camera_pos()->void:
	var vp_size = get_viewport().get_visible_rect().size
	var r = min(vp_size.x,vp_size.y)/2
	$Camera3D.position = Vector3(1,1,r*1)
	$Camera3D.look_at(Vector3.ZERO)

func _process(_delta: float) -> void:
	var t = Time.get_unix_time_from_system() /-3.0
	if camera_move:
		var vp_size = get_viewport().get_visible_rect().size
		var r = min(vp_size.x,vp_size.y)/2
		$Camera3D.position = Vector3(sin(t)*r, cos(t)*r, r*0.6  )
		$Camera3D.look_at(Vector3(sin(t)*r/2, cos(t)*r/2, 0) )
		#$Camera3D.look_at(Vector3.ZERO)

# esc to exit
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_끝내기_pressed()
		elif event.keycode == KEY_ENTER:
			_on_시야바꾸기_pressed()
		elif event.keycode == KEY_INSERT:
			참가자추가하기()
		elif event.keycode == KEY_DELETE:
			마지막참가자제거하기()

func _on_시야바꾸기_pressed() -> void:
	camera_move = !camera_move
	if camera_move == false:
		reset_camera_pos()

func _on_끝내기_pressed() -> void:
	get_tree().quit()

func _on_참가자추가_pressed() -> void:
	참가자추가하기()

func _on_참가자제거_pressed() -> void:
	마지막참가자제거하기()

func _on_참가자_scroll_scroll_started() -> void:
	$"오른쪽패널/Scroll도착".scroll_vertical = $"왼쪽패널/Scroll출발".scroll_vertical

func _on_도착지점_scroll_scroll_started() -> void:
	$"왼쪽패널/Scroll출발".scroll_vertical = $"오른쪽패널/Scroll도착".scroll_vertical

func _on_만들기_pressed() -> void:
	사다리자료 = 사다리Lib.new().만들기(사다리칸수())

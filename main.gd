extends Node3D

@onready var 참가자들 = $"왼쪽패널/Scroll출발/출발목록"
@onready var 도착지점들 = $"오른쪽패널/Scroll도착/도착목록"

var 화살표 = preload("res://arrow3d/arrow3d.tscn")

class 사다리구성자료:
	var 왼쪽연결길 :bool # 존재여부
	var 왼쪽가는길 :int # 참가자번호
	var 오른쪽가는길 :int # 참가자번호
	func _init() -> void:
		왼쪽연결길 = false # 없음
		왼쪽가는길 = -1 # 미사용
		오른쪽가는길 = -1 # 미사용
	func _to_string() -> String:
		return "[%s %d %d]" % [왼쪽연결길,왼쪽가는길,오른쪽가는길]

# Array[참가자수][참가자수*4]사다리구성자료
var 사다리자료 :Array
var 참가자색 :Array[Color]
var 참가자위치 :Array # [참가자] = 도착지
var 풀이이동좌표 :Array  # [참가자][vector2]
func 사다리칸수() -> Vector2i:
	var n = 참가자들.get_child_count()
	return Vector2i(n, n*3 )

func 사다리자료_보기():
	var 칸수 = 사다리칸수()
	for y in 칸수.y:
		var ss :String = ""
		for x in 칸수.x:
			ss += str(사다리자료[x][y]) + " "
		print(ss)
	for i in 칸수.x:
		print(i, "->", 참가자위치[i])

func 사다리자료_만들기() -> void:
	# 초기화
	var 칸수 = 사다리칸수()
	풀이이동좌표 = []
	참가자위치 = []
	사다리자료 = []
	for i in 칸수.x:
		참가자위치.append(i)
		풀이이동좌표.append([])
		사다리자료.append([])
		for j in 칸수.y:
			사다리자료[i].append(사다리구성자료.new())

	# 문제 만들기
	for y in 칸수.y:
		for x in 칸수.x:
			if randf() < 0.5:
				continue
			if 사다리자료[(x-1+칸수.x)%칸수.x][y].왼쪽연결길 == true or 사다리자료[(x+1)%칸수.x][y].왼쪽연결길 == true:
				continue
			if y > 0 and 사다리자료[x][y-1].왼쪽연결길 == true:
				continue
			사다리자료[x][y].왼쪽연결길 = true

	# 풀이 만들기
	# 각 줄을 순서대로 타고
	for 참가자번호 in 칸수.x:
		var 현재줄번호 = 참가자번호
		# 아래로 내려가면서 좌우로 이동
		for y in 칸수.y:
			if 사다리자료[현재줄번호][y].왼쪽연결길 == true:
				# 왼쪽으로 한칸 이동
				사다리자료[현재줄번호][y].왼쪽가는길 = 참가자번호
				현재줄번호 = (현재줄번호-1 + 칸수.x) %칸수.x
				참가자위치[참가자번호] = 현재줄번호
				continue
			if 사다리자료[(현재줄번호+1)%칸수.x][y].왼쪽연결길 == true:
				# 오른쪽으로 한칸 이동
				사다리자료[현재줄번호][y].오른쪽가는길 = 참가자번호
				현재줄번호 = (현재줄번호+1) % 칸수.x
				참가자위치[참가자번호] = 현재줄번호
				continue


var camera_move = false

func _ready() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	var r = min(vp_size.x,vp_size.y)/2
	RenderingServer.set_default_clear_color( Global3d.colors.default_clear)

	$DirectionalLight3D.position = Vector3(r,r,r)
	$DirectionalLight3D.look_at(Vector3.ZERO)
	$OmniLight3D.position = Vector3(r,-r,r)
	reset_camera_pos()

	$"왼쪽패널".size = Vector2(vp_size.x/2 -r, vp_size.y)
	$오른쪽패널.size = Vector2(vp_size.x/2 -r, vp_size.y)
	$오른쪽패널.position = Vector2(vp_size.x/2 + r, 0)

	$"왼쪽패널/Scroll출발".get_v_scroll_bar().scrolling.connect(_on_참가자_scroll_scroll_started)
	$"오른쪽패널/Scroll도착".get_v_scroll_bar().scrolling.connect(_on_도착지점_scroll_scroll_started)
	#$"사다리_Scroll".get_h_scroll_bar().scrolling.connect(_on_사다리_scroll_scroll_started)

	for i in 4:
		참가자추가하기()

func LineEdit만들기(t :String, co :Color) -> LineEdit:
	var rtn = LineEdit.new()
	rtn.text = t
	rtn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	rtn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rtn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rtn.max_length = 10
	rtn.add_theme_color_override("font_color", co)
	rtn.add_theme_color_override("font_outline_color",Color.WHITE)
	rtn.add_theme_constant_override("outline_size",1)
	return rtn

func 기둥만들기(h :float, r :float, co :Color)->MeshInstance3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = co
	var mesh = CylinderMesh.new()
	mesh.height = h
	mesh.bottom_radius = r
	mesh.top_radius = r
	mesh.radial_segments = 8 #clampi( int(r*4) , 64, 360)
	mesh.material = mat
	var sp = MeshInstance3D.new()
	sp.mesh = mesh
	return sp

func 기둥위치정리하기() -> void:
	var n := $"사다리".get_child_count()
	var r := 10 * n
	for i in n:
		var o = $"사다리".get_child(i)
		o.position = make_pos_by_rad_r_3d(2*PI*i/n, r)
		o.mesh.height = n * 30

func make_pos_by_rad_r_3d(rad:float, r :float, y :float =0)->Vector3:
	return Vector3(sin(rad)*r, y, cos(rad)*r)

func 참가자추가하기() -> void:
	var i = 참가자들.get_child_count()
	참가자색.append(NamedColorList.color_list.pick_random()[0])
	var 참가자 = LineEdit만들기("출발%d" % [i+1], 참가자색[i])
	참가자.text_changed.connect(
		func(t :String):
			참가자이름변경됨(i, t)
	)
	참가자.text_submitted.connect(
		func(t :String):
			참가자.release_focus()
	)
	참가자들.add_child(참가자)

	var 도착점 = LineEdit만들기("도착%d" % [i+1], 참가자색[i])
	도착점.text_changed.connect(
		func(t :String):
			도착점이름변경됨(i, t)
	)
	도착점.text_submitted.connect(
		func(t :String):
			도착점.release_focus()
	)
	도착지점들.add_child(도착점)
	var 기둥 := 기둥만들기(300, 5, 참가자색[i])
	$"사다리".add_child(기둥)
	기둥위치정리하기()

func 참가자이름변경됨(i :int, t :String) -> void:
	pass
func 도착점이름변경됨(i :int, t :String) -> void:
	pass

func 마지막참가자제거하기() -> void:
	var 현재참가자수 = 참가자들.get_child_count()
	if 현재참가자수 <= 3:
		return
	참가자색.pop_back()
	var 마지막참가자 = 참가자들.get_child(현재참가자수-1)
	참가자들.remove_child(마지막참가자)
	var 마지막도착지 = 도착지점들.get_child(현재참가자수-1)
	도착지점들.remove_child(마지막도착지)
	var 마지막기둥 = $"사다리".get_child(현재참가자수-1)
	$"사다리".remove_child(마지막기둥)
	기둥위치정리하기()

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

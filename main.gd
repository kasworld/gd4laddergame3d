extends Node3D

@onready var 참가자수 = $"왼쪽패널/참가자수"
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
	return Vector2i(참가자수.get_value(), 참가자수.get_value()*3 )

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

	var fsize = preload("res://사다리타기.tres").default_font_size
	참가자수.init(0,"참가자수 ",fsize)
	참가자수변경()

func 참가자수변경() -> void:
	참가자색 = []
	for n in 참가자들.get_children():
		참가자들.remove_child(n)
	for n in 도착지점들.get_children():
		도착지점들.remove_child(n)
	for n in $"사다리".get_children():
		$"사다리".remove_child(n)
	for i in 참가자수.get_value():
		참가자추가하기()

func 참가자추가하기() -> void:
	var i = 참가자들.get_child_count()
	참가자색.append(NamedColorList.color_list.pick_random()[0])
	var 참가자 = LineEdit.new()
	참가자.text = "출발%d" % [i+1]
	참가자.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	참가자.size_flags_vertical = Control.SIZE_EXPAND
	참가자.add_theme_color_override("font_color",참가자색[i])
	참가자.add_theme_color_override("font_outline_color",Color.WHITE)
	참가자.add_theme_constant_override("outline_size",1)
	참가자들.add_child(참가자)
	var 도착지점 = LineEdit.new()
	도착지점.text = "도착%d" % [i+1]
	도착지점.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	도착지점.size_flags_vertical = Control.SIZE_EXPAND
	도착지점.add_theme_color_override("font_color",참가자색[i])
	도착지점.add_theme_color_override("font_outline_color",Color.WHITE)
	도착지점.add_theme_constant_override("outline_size",1)
	도착지점들.add_child(도착지점)

	var 기둥 := 기둥만들기(300, 10, 참가자색[i])
	$"사다리".add_child(기둥)
	기둥.position = make_pos_by_rad_r_3d(2*PI*i/참가자색.size(), 100)

func 기둥만들기(h :float, r :float, co :Color)->MeshInstance3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = co
	var mesh = CylinderMesh.new()
	mesh.height = h
	mesh.bottom_radius = r
	mesh.top_radius = r
	mesh.radial_segments = clampi( int(r*4) , 64, 360)
	mesh.material = mat
	var sp = MeshInstance3D.new()
	sp.mesh = mesh
	return sp

func make_pos_by_rad_r_3d(rad:float, r :float, y :float =0)->Vector3:
	return Vector3(sin(rad)*r, y, cos(rad)*r)

func 마지막참가자제거하기() -> void:
	var 현재참가자수 = 참가자들.get_child_count()
	if 현재참가자수 <= 0:
		return
	참가자색.pop_back()
	var 마지막참가자 = 참가자들.get_child(현재참가자수-1)
	참가자들.remove_child(마지막참가자)
	var 마지막도착지 = 도착지점들.get_child(현재참가자수-1)
	도착지점들.remove_child(마지막도착지)
	var 마지막기둥 = $"사다리".get_child(현재참가자수-1)
	$"사다리".remove_child(마지막기둥)

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

func _on_시야바꾸기_pressed() -> void:
	camera_move = !camera_move
	if camera_move == false:
		reset_camera_pos()

func _on_끝내기_pressed() -> void:
	get_tree().quit()

func _on_참가자수_value_changing(_idx: int) -> void:
	참가자수변경()

func _on_참가자_scroll_scroll_started() -> void:
	$"오른쪽패널/Scroll도착".scroll_vertical = $"왼쪽패널/Scroll출발".scroll_vertical

func _on_도착지점_scroll_scroll_started() -> void:
	$"왼쪽패널/Scroll출발".scroll_vertical = $"오른쪽패널/Scroll도착".scroll_vertical

extends Node3D
class_name 사다리게임

var 참가자정보 :Array # [출발이름, 색, 도착이름]
var 사다리자료 :사다리Lib
var 기본색 : Color = Color.DIM_GRAY

var 깜빡이는중 :bool
var 현재깜빡이는그룹번호 :int # group_name =  "%d" % 참가자번호

var 기둥반지름 := 1.0
var 화살표반지름 := 3.0
var 가로길칸배수 :int = 3
var 세로줄수 :int
var 가로줄수 :int
var 중심과의거리 :float
var 기둥간각도 :float
var 기둥길이 :float
var 가로줄간거리 :float
var 세로줄간거리 :float
var 가로화살표위치보정 :Vector3
var 세로화살표위치보정 :Vector3

func init(참가자정보_a :Array) -> 사다리게임:
	참가자정보 = 참가자정보_a
	세로줄수 = 참가자정보.size()
	가로줄수 = 세로줄수 *가로길칸배수
	중심과의거리 = 50.0 * sqrt(세로줄수)
	기둥간각도 = 2.0*PI/세로줄수
	기둥길이 = 세로줄수 * 50.0
	가로줄간거리 = 기둥길이/가로줄수
	세로줄간거리 = 중심과의거리 * sin(기둥간각도/2) *2
	가로화살표위치보정 = Vector3(0, 화살표반지름 *1.0, 0)
	세로화살표위치보정 = Vector3(0, 화살표반지름, 0)
	return self

func 참가자추가하기() -> void:
	var i = 세로줄수
	$"세로기둥".add_child(기둥만들기(30, 기둥반지름, 기본색))
	$"출발목록".add_child(Label3D만들기(참가자정보[i][0], 참가자정보[i][1]))
	$"도착목록".add_child(Label3D만들기(참가자정보[i][2], 기본색))
	위치3D정리하기()


func 위치3D정리하기() -> void:
	for i in 세로줄수:
		var 각도 = 기둥간각도*i
		var o = $"세로기둥".get_child(i)
		o.position = make_pos_by_rad_r_3d(각도, 중심과의거리,0)
		o.mesh.height = 기둥길이
		$"출발목록".get_child(i).position = make_pos_by_rad_r_3d(각도, 중심과의거리, 기둥길이/2 + 10)
		$"도착목록".get_child(i).position = make_pos_by_rad_r_3d(각도, 중심과의거리, -기둥길이/2 - 10)
	$"문제길".visible = false
	$"풀이길".visible = false

# 중점을 돌려준다.
func 가로기둥위치(x :int, y :int) -> Vector3:
	var p = make_pos_by_rad_r_3d(
		기둥간각도 * (x-0.5),
		중심과의거리 * cos(기둥간각도/2),
		기둥길이/2 - 가로줄간거리 * (y +0.5)   )
	return p

func 사다리문제그리기() -> void:
	사다리자료 = 사다리Lib.new().만들기( Vector2i(세로줄수, 가로줄수 ) )
	for n in $"문제길".get_children():
		$"문제길".remove_child(n)

	for y in 가로줄수:
		for x in 세로줄수:
			if 사다리자료.자료[x%세로줄수][y].왼쪽연결길:
				var 가로줄 = 기둥만들기(세로줄간거리, 기둥반지름, Color.WHITE)
				가로줄.rotate_z(PI/2)
				가로줄.rotate_y(기둥간각도 * (x-0.5))
				가로줄.position = 가로기둥위치(x,y)
				$"문제길".add_child(가로줄)
	$"문제길".visible = true
	$"풀이길".visible = false

func 사다리풀이그리기() -> void:
	#이름들백업 = []
	for i in 세로줄수:
		#이름들백업.append([s1,s2])
		$"도착목록".get_child(사다리자료.참가자위치[i]).modulate = 참가자정보[i][1]
	for n in $"풀이길".get_children():
		$"풀이길".remove_child(n)

	# 각 줄을 순서대로 타고
	for 참가자번호 in 세로줄수:
		var 현재줄번호 = 참가자번호
		# 아래로 내려가면서 좌우로 이동
		var oldy = 0
		# 시작 세로줄 그리기
		화살표추가_아래쪽(참가자번호,현재줄번호,0, 1)
		for y in 가로줄수:
			if 사다리자료.자료[현재줄번호][y].왼쪽연결길 == true: # 왼쪽으로 한칸 이동
				# 현재까지의 세로줄 그리기
				화살표추가_아래쪽(참가자번호,현재줄번호,oldy,y)
				#왼쪽 화살표
				현재줄번호 = (현재줄번호-1+세로줄수)%세로줄수
				화살표추가_왼쪽(참가자번호,현재줄번호+1, 현재줄번호,y)
				oldy = y
				continue
			if 사다리자료.자료[(현재줄번호+1)%세로줄수][y].왼쪽연결길 == true: # 오른쪽으로 한칸 이동
				# 현재까지의 세로줄 그리기
				화살표추가_아래쪽(참가자번호,현재줄번호,oldy,y)
				# 오른쪽 화살표
				현재줄번호 = (현재줄번호+1+세로줄수)%세로줄수
				화살표추가_오른쪽(참가자번호,현재줄번호-1, 현재줄번호,y)
				oldy = y
				continue
		# 나머지 끝까지 그린다.
		화살표추가_아래쪽(참가자번호,현재줄번호,oldy,가로줄수)

	#$"문제길".visible = false
	$"풀이길".visible = true
	#$"오른쪽패널/풀기".disabled = true
	#$"오른쪽패널/깜빡이기".disabled = false

# 중점을 돌려준다.
func 세로화살표위치(x :int, y :int) -> Vector3:
	var p = make_pos_by_rad_r_3d(
		기둥간각도*x,
		중심과의거리,
		기둥길이/2 - 가로줄간거리 * (y+0.5)  )
	return p

func 화살표추가_아래쪽(참가자번호 :int, x :int, y1 :int , y2 :int) -> Arrow3D:
	var p1 = 세로화살표위치(x,y1)
	var p2 = 세로화살표위치(x,y2)
	var a = preload("res://arrow_3d/arrow_3d.tscn").instantiate(
		).set_size( (p1-p2).length(),  화살표반지름, 화살표반지름*2 ).set_color(참가자정보[참가자번호][1])
	a.rotate_z(PI)
	a.position = (p1+p2)/2
	$"풀이길".add_child(a)
	a.add_to_group("%d" % 참가자번호)
	return a

func 화살표추가_왼쪽(참가자번호 :int, x1 :int, x2 :int , y :int) -> Arrow3D:
	var p1 = 세로화살표위치(x1,y)
	var p2 = 세로화살표위치(x2,y)
	var a = preload("res://arrow_3d/arrow_3d.tscn").instantiate(
		).set_size( (p1-p2).length(), 화살표반지름, 화살표반지름*2 ).set_color(참가자정보[참가자번호][1])
	a.rotate_z(PI/2)
	a.position = (p1+p2)/2 -가로화살표위치보정
	a.rotate_y(기둥간각도 * (x1+x2)/2)
	$"풀이길".add_child(a)
	a.add_to_group("%d" % 참가자번호)
	return a

func 화살표추가_오른쪽(참가자번호 :int, x1 :int, x2 :int , y :int) -> Arrow3D:
	var p1 = 세로화살표위치(x1,y)
	var p2 = 세로화살표위치(x2,y)
	var a = preload("res://arrow_3d/arrow_3d.tscn").instantiate(
		).set_size( (p1-p2).length(), 화살표반지름, 화살표반지름*2 ).set_color(참가자정보[참가자번호][1])
	a.rotate_z(-PI/2)
	a.position = (p1+p2)/2 +가로화살표위치보정
	a.rotate_y(기둥간각도 * (x1+x2)/2)
	$"풀이길".add_child(a)
	a.add_to_group("%d" % 참가자번호)
	return a

func 깜빡이기() -> void:
	for i in 세로줄수:
		var group_name = "%d" % i
		if i == 현재깜빡이는그룹번호:
			get_tree().call_group(group_name, "show")
		else:
			get_tree().call_group(group_name, "hide")
	현재깜빡이는그룹번호 = (현재깜빡이는그룹번호+1) % 세로줄수

func 깜빡이기_종료() -> void:
	for i in 세로줄수:
		var group_name = "%d" % i
		get_tree().call_group(group_name, "show")
	현재깜빡이는그룹번호 = 0

func make_pos_by_rad_r_3d(rad:float, r :float, y :float =0)->Vector3:
	return Vector3(sin(rad)*r, y, cos(rad)*r)

func Label3D만들기(t :String, co :Color) -> Label3D:
	var rtn = Label3D.new()
	rtn.text = t
	rtn.modulate = co
	rtn.pixel_size = 0.5
	#rtn.no_depth_test = true
	rtn.billboard = BaseMaterial3D.BILLBOARD_ENABLED
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

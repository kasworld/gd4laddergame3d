extends Node3D
class_name 사다리게임

@onready var 사다리문제 = $"문제길"
@onready var 사다리풀이 = $"풀이길"
var 화살표 = preload("res://arrow_3d/arrow_3d.tscn")

var 밝은색목록 :Array = NamedColors.filter_light_color_list()
var 참가자색 :Array[Color]
var 기본색 : Color = Color.DIM_GRAY
var 사다리자료 :사다리Lib
var 이름들백업 :Array = [] # Array[출발점, 도착점] 문자열 보관
var 깜빡이는중 :bool
var 현재깜빡이는그룹번호 :int # group_name =  "%d" % 참가자번호

func 참가자추가하기() -> void:
	var i = 사다리용숫자들().세로줄수
	if i >= Settings.최대칸수:
		return
	참가자색.append(밝은색목록.pick_random())

	var 참가자 = GlobalLib.LineEdit만들기("출발%d" % [i+1], 참가자색[i])
	참가자.text_changed.connect(
		func(t :String):
			$"출발목록".get_child(i).text = t
	)
	참가자.text_submitted.connect(
		func(_t :String):
			참가자.release_focus()
	)
	참가자들.add_child(참가자)
	var 도착점 = GlobalLib.LineEdit만들기("도착%d" % [i+1], 기본색)
	도착점.text_changed.connect(
		func(t :String):
			$"도착목록".get_child(i).text = t
	)
	도착점.text_submitted.connect(
		func(_t :String):
			도착점.release_focus()
	)
	도착지점들.add_child(도착점)
	$"세로기둥".add_child(GlobalLib.기둥만들기(30, 기둥반지름, 기본색))
	$"출발목록".add_child(GlobalLib.Label3D만들기("출발%d" % [i+1], 참가자색[i]))
	$"도착목록".add_child(GlobalLib.Label3D만들기("도착%d" % [i+1], 기본색))
	위치3D정리하기()

func 마지막참가자제거하기() -> void:
	var 현재참가자수 = 사다리용숫자들().세로줄수
	if 현재참가자수 <= Settings.최소칸수:
		return
	참가자색.pop_back()
	var 마지막수 = 현재참가자수-1
	참가자들.remove_child(참가자들.get_child(마지막수))
	도착지점들.remove_child(도착지점들.get_child(마지막수))
	$"세로기둥".remove_child($"세로기둥".get_child(마지막수))
	$"출발목록".remove_child($"출발목록".get_child(마지막수))
	$"도착목록".remove_child($"도착목록".get_child(마지막수))
	위치3D정리하기()

const 기둥반지름 = 1.0
const 화살표반지름 = 3
func 사다리용숫자들() -> Dictionary:
	var rtn := {}
	rtn.세로줄수 = 참가자들.get_child_count()
	rtn.가로줄수 = rtn.세로줄수 *Settings.가로길칸배수
	rtn.중심과의거리 = 50.0 * sqrt(rtn.세로줄수)
	rtn.기둥간각도 = 2.0*PI/rtn.세로줄수
	rtn.기둥길이 = rtn.세로줄수 * 50.0
	rtn.가로줄간거리 = rtn.기둥길이/rtn.가로줄수
	rtn.세로줄간거리 = rtn.중심과의거리 * sin(rtn.기둥간각도/2) *2
	rtn.가로화살표위치보정 = Vector3(0, 화살표반지름 *1.0, 0)
	rtn.세로화살표위치보정 = Vector3(0, 화살표반지름, 0)
	return rtn

func 위치3D정리하기() -> void:
	var 사다리수 = 사다리용숫자들()
	for i in min(이름들백업.size(),사다리수.세로줄수) :
		$"왼쪽패널/Scroll출발/출발목록".get_child(i).text = 이름들백업[i][0]
		$"오른쪽패널/Scroll도착/도착목록".get_child(i).text = 이름들백업[i][1]
	for i in 사다리수.세로줄수:
		var 각도 = 사다리수.기둥간각도*i
		var o = $"세로기둥".get_child(i)
		o.position = GlobalLib.make_pos_by_rad_r_3d(각도, 사다리수.중심과의거리,0)
		o.mesh.height = 사다리수.기둥길이
		$"출발목록".get_child(i).position = GlobalLib.make_pos_by_rad_r_3d(각도, 사다리수.중심과의거리, 사다리수.기둥길이/2 + 10)
		$"도착목록".get_child(i).position = GlobalLib.make_pos_by_rad_r_3d(각도, 사다리수.중심과의거리, -사다리수.기둥길이/2 - 10)
	$"문제길".visible = false
	$"풀이길".visible = false
	$"오른쪽패널/만들기".disabled = false
	$"오른쪽패널/풀기".disabled = true
	$"오른쪽패널/깜빡이기".disabled = true

# 중점을 돌려준다.
func 가로기둥위치(x :int, y :int) -> Vector3:
	var 사다리수 = 사다리용숫자들()
	var p = GlobalLib.make_pos_by_rad_r_3d(
		사다리수.기둥간각도 * (x-0.5),
		사다리수.중심과의거리 * cos(사다리수.기둥간각도/2),
		사다리수.기둥길이/2 - 사다리수.가로줄간거리 * (y +0.5)   )
	return p

func 사다리문제그리기() -> void:
	var 사다리수 = 사다리용숫자들()
	사다리자료 = 사다리Lib.new().만들기( Vector2i(사다리수.세로줄수, 사다리수.가로줄수 ) )
	for i in 참가자들.get_child_count():
		참가자들.get_child(i).add_theme_color_override("font_uneditable_color", 참가자색[i])
		참가자들.get_child(i).editable = false
		도착지점들.get_child(i).editable = false
	for n in 사다리문제.get_children():
		사다리문제.remove_child(n)

	for y in 사다리수.가로줄수:
		for x in 사다리수.세로줄수:
			if 사다리자료.자료[x%사다리수.세로줄수][y].왼쪽연결길:
				var 가로줄 = GlobalLib.기둥만들기(사다리수.세로줄간거리, 기둥반지름, Color.WHITE)
				가로줄.rotate_z(PI/2)
				가로줄.rotate_y(사다리수.기둥간각도 * (x-0.5))
				가로줄.position = 가로기둥위치(x,y)
				사다리문제.add_child(가로줄)
	$"문제길".visible = true
	$"풀이길".visible = false
	$"오른쪽패널/만들기".disabled = true
	$"오른쪽패널/풀기".disabled = false

func 사다리풀이그리기() -> void:
	var 사다리수 = 사다리용숫자들()
	이름들백업 = []
	for i in 사다리수.세로줄수:
		var s1 = 참가자들.get_child(i).text
		var s2 = 도착지점들.get_child(사다리자료.참가자위치[i]).text
		이름들백업.append([s1,s2])
		참가자들.get_child(i).text = "%s->%s" %[s1,s2]
		도착지점들.get_child(사다리자료.참가자위치[i]).text = "%s<-%s" %[s2,s1]
		도착지점들.get_child(사다리자료.참가자위치[i]).add_theme_color_override("font_uneditable_color",참가자색[i])
		$"도착목록".get_child(사다리자료.참가자위치[i]).modulate = 참가자색[i]
	for n in 사다리풀이.get_children():
		사다리풀이.remove_child(n)

	# 각 줄을 순서대로 타고
	for 참가자번호 in 사다리수.세로줄수:
		var 현재줄번호 = 참가자번호
		# 아래로 내려가면서 좌우로 이동
		var oldy = 0
		# 시작 세로줄 그리기
		화살표추가_아래쪽(참가자번호,현재줄번호,0, 1)
		for y in 사다리수.가로줄수:
			if 사다리자료.자료[현재줄번호][y].왼쪽연결길 == true: # 왼쪽으로 한칸 이동
				# 현재까지의 세로줄 그리기
				화살표추가_아래쪽(참가자번호,현재줄번호,oldy,y)
				#왼쪽 화살표
				현재줄번호 = (현재줄번호-1+사다리수.세로줄수)%사다리수.세로줄수
				화살표추가_왼쪽(참가자번호,현재줄번호+1, 현재줄번호,y)
				oldy = y
				continue
			if 사다리자료.자료[(현재줄번호+1)%사다리수.세로줄수][y].왼쪽연결길 == true: # 오른쪽으로 한칸 이동
				# 현재까지의 세로줄 그리기
				화살표추가_아래쪽(참가자번호,현재줄번호,oldy,y)
				# 오른쪽 화살표
				현재줄번호 = (현재줄번호+1+사다리수.세로줄수)%사다리수.세로줄수
				화살표추가_오른쪽(참가자번호,현재줄번호-1, 현재줄번호,y)
				oldy = y
				continue
		# 나머지 끝까지 그린다.
		화살표추가_아래쪽(참가자번호,현재줄번호,oldy,사다리수.가로줄수)

	#$"문제길".visible = false
	$"풀이길".visible = true
	$"오른쪽패널/풀기".disabled = true
	$"오른쪽패널/깜빡이기".disabled = false

# 중점을 돌려준다.
func 세로화살표위치(x :int, y :int) -> Vector3:
	var 사다리수 = 사다리용숫자들()
	var p = GlobalLib.make_pos_by_rad_r_3d(
		사다리수.기둥간각도*x,
		사다리수.중심과의거리,
		사다리수.기둥길이/2 - 사다리수.가로줄간거리 * (y+0.5)  )
	return p

func 화살표추가_아래쪽(참가자번호 :int, x :int, y1 :int , y2 :int) -> Arrow3D:
	var p1 = 세로화살표위치(x,y1)
	var p2 = 세로화살표위치(x,y2)
	var a = 화살표.instantiate().set_size( (p1-p2).length() ,  화살표반지름, 화살표반지름*2 ).set_color(참가자색[참가자번호])
	a.rotate_z(PI)
	a.position = (p1+p2)/2
	사다리풀이.add_child(a)
	a.add_to_group("%d" % 참가자번호)
	return a

func 화살표추가_왼쪽(참가자번호 :int, x1 :int, x2 :int , y :int) -> Arrow3D:
	var p1 = 세로화살표위치(x1,y)
	var p2 = 세로화살표위치(x2,y)
	var a = 화살표.instantiate().set_size( (p1-p2).length() , 화살표반지름, 화살표반지름*2 ).set_color(참가자색[참가자번호])
	a.rotate_z(PI/2)
	a.position = (p1+p2)/2 -사다리용숫자들().가로화살표위치보정
	a.rotate_y(사다리용숫자들().기둥간각도 * (x1+x2)/2)
	사다리풀이.add_child(a)
	a.add_to_group("%d" % 참가자번호)
	return a

func 화살표추가_오른쪽(참가자번호 :int, x1 :int, x2 :int , y :int) -> Arrow3D:
	var p1 = 세로화살표위치(x1,y)
	var p2 = 세로화살표위치(x2,y)
	var a = 화살표.instantiate().set_size( (p1-p2).length() , 화살표반지름, 화살표반지름*2 ).set_color(참가자색[참가자번호])
	a.rotate_z(-PI/2)
	a.position = (p1+p2)/2 +사다리용숫자들().가로화살표위치보정
	a.rotate_y(사다리용숫자들().기둥간각도 * (x1+x2)/2)
	사다리풀이.add_child(a)
	a.add_to_group("%d" % 참가자번호)
	return a

func 깜빡이기() -> void:
	for i in 사다리용숫자들().세로줄수:
		var group_name = "%d" % i
		if i == 현재깜빡이는그룹번호:
			get_tree().call_group(group_name, "show")
		else:
			get_tree().call_group(group_name, "hide")
	현재깜빡이는그룹번호 = (현재깜빡이는그룹번호+1) % 사다리용숫자들().세로줄수

func 깜빡이기_종료() -> void:
	for i in 사다리용숫자들().세로줄수:
		var group_name = "%d" % i
		get_tree().call_group(group_name, "show")
	현재깜빡이는그룹번호 = 0

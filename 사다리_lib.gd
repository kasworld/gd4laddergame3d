extends Node

class_name 사다리Lib

class 구성자료:
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
var 자료 :Array
var 참가자위치 :Array # [참가자] = 도착지
var 풀이이동좌표 :Array  # [참가자][ [vector3,vector3] ]
var 칸수 :Vector2i

func 보기():
	for y in 칸수.y:
		var ss :String = ""
		for x in 칸수.x:
			ss += str(자료[x][y]) + " "
		print(ss)
	for i in 칸수.x:
		print(i, "->", 참가자위치[i])

func 만들기(a칸수 :Vector2i) -> 사다리Lib:
	칸수 = a칸수
	# 초기화
	풀이이동좌표 = []
	참가자위치 = []
	자료 = []
	for i in 칸수.x:
		참가자위치.append(i)
		풀이이동좌표.append([])
		자료.append([])
		for j in 칸수.y:
			자료[i].append(구성자료.new())

	# 문제 만들기
	for y in 칸수.y:
		for x in 칸수.x:
			if randf() < 0.5:
				continue
			if 자료[(x-1+칸수.x)%칸수.x][y].왼쪽연결길 == true or 자료[(x+1)%칸수.x][y].왼쪽연결길 == true:
				continue
			if y > 0 and 자료[x][y-1].왼쪽연결길 == true:
				continue
			자료[x][y].왼쪽연결길 = true

	# 풀이 만들기
	# 각 줄을 순서대로 타고
	for 참가자번호 in 칸수.x:
		var 현재줄번호 = 참가자번호
		# 아래로 내려가면서 좌우로 이동
		for y in 칸수.y:
			if 자료[현재줄번호][y].왼쪽연결길 == true:
				# 왼쪽으로 한칸 이동
				자료[현재줄번호][y].왼쪽가는길 = 참가자번호
				현재줄번호 = (현재줄번호-1 + 칸수.x) %칸수.x
				참가자위치[참가자번호] = 현재줄번호
				continue
			if 자료[(현재줄번호+1)%칸수.x][y].왼쪽연결길 == true:
				# 오른쪽으로 한칸 이동
				자료[현재줄번호][y].오른쪽가는길 = 참가자번호
				현재줄번호 = (현재줄번호+1) % 칸수.x
				참가자위치[참가자번호] = 현재줄번호
				continue
	return self

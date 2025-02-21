extends Node3D

@onready var 참가자수 = $"왼쪽패널/참가자수"
@onready var 참가자들 = $"왼쪽패널/ScrollContainer/출발목록"
@onready var 도착지점들 = $"오른쪽패널/ScrollContainer/도착목록"

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
var 참가자색 :PackedColorArray
var 참가자위치 :Array # [참가자] = 도착지
var 풀이이동좌표 :Array  # [참가자][vector2]

func 사다리칸수() -> Vector2i:
	return Vector2i(참가자수.get_value(), 참가자수.get_value()*3 )

func _ready() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	RenderingServer.set_default_clear_color( Global3d.colors.default_clear)

	var r = min(vp_size.x,vp_size.y)/2
	$"왼쪽패널".size = Vector2(vp_size.x/2 -r, vp_size.y)
	$오른쪽패널.size = Vector2(vp_size.x/2 -r, vp_size.y)
	$오른쪽패널.position = Vector2(vp_size.x/2 + r, 0)

	var fsize = preload("res://사다리타기.tres").default_font_size
	참가자수.init(0,"참가자수 ",fsize)

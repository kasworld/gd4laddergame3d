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
	for i in 참가자수.get_value():
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


func _on_참가자수_value_changing(_idx: int) -> void:
	참가자수변경()

func _on_참가자_scroll_scroll_started() -> void:
	$"오른쪽패널/Scroll도착".scroll_vertical = $"왼쪽패널/Scroll출발".scroll_vertical

func _on_도착지점_scroll_scroll_started() -> void:
	$"왼쪽패널/Scroll출발".scroll_vertical = $"오른쪽패널/Scroll도착".scroll_vertical

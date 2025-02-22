extends Node

var colors = {
	default_clear = Color.BLACK,
}

func get_color_mat(co: Color)->Material:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = co
	#mat.metallic = 1
	#mat.clearcoat = true
	return mat

func new_box(hand_size :Vector3, mat :Material)->MeshInstance3D:
	var mesh = BoxMesh.new()
	mesh.size = hand_size
	mesh.material = mat
	var sp = MeshInstance3D.new()
	sp.mesh = mesh
	return sp

func new_sphere(r :float, mat :Material)->MeshInstance3D:
	var mesh = SphereMesh.new()
	mesh.radius = r
	#mesh.radial_segments = 100
	#mesh.rings = 100
	mesh.material = mat
	var sp = MeshInstance3D.new()
	sp.mesh = mesh
	return sp

func new_cylinder(h :float, r1 :float, r2 :float, mat :Material)->MeshInstance3D:
	var mesh = CylinderMesh.new()
	mesh.height = h
	mesh.bottom_radius = r1
	mesh.top_radius = r2
	mesh.radial_segments = clampi( int((r1+r2)*2) , 64, 360)
	mesh.material = mat
	var sp = MeshInstance3D.new()
	sp.mesh = mesh
	return sp

#var font = preload("res://HakgyoansimBareondotumR.ttf")
#func new_text(fsize :float, fdepth :float, mat :Material, text :String)->MeshInstance3D:
	#var mesh = TextMesh.new()
	#mesh.font = font
	#mesh.depth = fdepth
	#mesh.pixel_size = fsize / 100
	#mesh.font_size = fsize
	#mesh.text = text
	#mesh.material = mat
	#var sp = MeshInstance3D.new()
	#sp.mesh = mesh
	#return sp

func new_torus(r1 :float,r2 :float, mat :Material)->MeshInstance3D:
	var mesh = TorusMesh.new()
	mesh.outer_radius = r1
	mesh.inner_radius = r2
	mesh.material = mat
	var sp = MeshInstance3D.new()
	sp.mesh = mesh
	return sp

func new_plane(size :Vector2, mat :Material)->MeshInstance3D:
	var mesh = PlaneMesh.new()
	mesh.size = size
	mesh.material = mat
	var sp = MeshInstance3D.new()
	sp.mesh = mesh
	return sp


func make_pos_by_rad_r_3d(rad:float, r :float, y :float =0)->Vector3:
	return Vector3(sin(rad)*r, y, cos(rad)*r)

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

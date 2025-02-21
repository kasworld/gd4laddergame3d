extends Node3D
class_name Arrow3D

const bodyRate = 0.7
const headRate = 1.0 - bodyRate
const shiftRate = (headRate-bodyRate)/2

func init(l :float, co :Color, bodyw :float, headw :float) -> Arrow3D:
	var mat = Global3d.get_color_mat(co)
	# body
	var bodyMesh = CylinderMesh.new()
	bodyMesh.height = l *bodyRate
	bodyMesh.bottom_radius = bodyw
	bodyMesh.top_radius = bodyw
	bodyMesh.radial_segments = clampi( int(bodyw*2) , 64, 360)
	bodyMesh.material = mat
	$Body.mesh = bodyMesh
	$Body.position = Vector3(0,-l*bodyRate/2-shiftRate*l,0)

	# head
	var headMesh = CylinderMesh.new()
	headMesh.height = l *headRate
	headMesh.bottom_radius = headw
	headMesh.top_radius = 0
	headMesh.radial_segments = clampi( int(headw*2) , 64, 360)
	headMesh.material = mat
	$Head.mesh = headMesh
	$Head.position = Vector3(0,l*headRate/2-shiftRate*l,0)

	return self

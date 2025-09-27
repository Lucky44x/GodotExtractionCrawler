extends NodePoolInstance
class_name Hitzone

var hitzone_area: Area3D
var hitzone_shape: CollisionShape3D

func OnInstance():
	hitzone_area = $HitzoneArea
	hitzone_shape = $HitzoneArea/Shape

func SetupHitzone(root: Node3D, collider: HitscanCollider):
	hitzone_shape.shape = collider.Shape
	hitzone_area.reparent(root)
	hitzone_area.position = collider.Position
	hitzone_area.rotation = Vector3(deg_to_rad(collider.Rotation.x), deg_to_rad(collider.Rotation.y), deg_to_rad(collider.Rotation.z))

func OnPop():
	hitzone_area.process_mode = Node.PROCESS_MODE_INHERIT

func OnPush():
	hitzone_area.process_mode = Node.PROCESS_MODE_DISABLED
	hitzone_area.reparent(self)

func GetHitInstances() -> Array[Node3D]:
	return hitzone_area.get_overlapping_bodies()

extends MeshInstance3D

@onready var gunImpact = $HitImpact
var alpha = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var duplicate_material = material_override.duplicate() # HACK: what the hell?
	material_override = duplicate_material
	await get_tree().create_timer(0.15).timeout
	queue_free()

func _process(delta):
	self.material_override.albedo_color = lerp(self.material_override.albedo_color, Color("ffffff00"), delta * 30)

func init(posBarrel: Vector3, posTarget: Vector3, color_new: Color = Color("ffff00ff")):
	var draw_mesh = ImmediateMesh.new()
	mesh = draw_mesh
	draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	draw_mesh.surface_add_vertex(posBarrel)
	draw_mesh.surface_add_vertex(posTarget)
	draw_mesh.surface_end()
	material_override.albedo_color = color_new
	material_override.emission = color_new
	$HitImpact.material_override.albedo_color = color_new
	$HitImpact.material_override.emission = color_new


func trigger_particle(pos, barrelPosition): #reminder to check the enemy scan
	$HitImpact.set_position(pos)
	$HitImpact.look_at(barrelPosition)
	$HitImpact.emitting = true


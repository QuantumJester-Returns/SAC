"""Generate three connected SAC cloud meshes using Blender's metaball surface solver.

Run with:
  blender --background --python Tools/generate_cloud_meshes.py

Outputs OBJ source files under Content/SourceAssets/Clouds/Generated/.
Requires Blender 3.6+ with the built-in Wavefront OBJ exporter.
"""
import bpy
import os
from mathutils import Vector

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "Content", "SourceAssets", "Clouds", "Generated")
os.makedirs(OUT, exist_ok=True)

CLOUDS = {
    "SAC_CloudBank_02": [
        (-1.75, 0.00, -0.10, 1.05), (-0.90, 0.02, 0.08, 1.15),
        (0.00, 0.00, 0.12, 1.25), (0.95, 0.03, 0.00, 1.10),
        (1.80, 0.00, -0.12, 0.95), (-1.15, 0.00, 0.55, 0.72),
        (-0.25, 0.04, 0.72, 0.88), (0.72, 0.00, 0.55, 0.80),
        (1.50, 0.00, 0.28, 0.62), (-0.50, 0.00, -0.32, 1.30),
    ],
    "SAC_CloudTower_02": [
        (0.00, 0.00, -0.55, 1.25), (-0.25, 0.00, 0.00, 1.05),
        (0.25, 0.00, 0.58, 0.95), (-0.15, 0.04, 1.05, 0.72),
        (0.30, 0.00, 1.42, 0.48), (-0.95, 0.00, -0.25, 0.68),
        (0.90, 0.00, -0.15, 0.70), (-0.70, 0.00, 0.52, 0.55),
        (0.75, 0.00, 0.75, 0.55),
    ],
    "SAC_CloudShelf_02": [
        (-1.80, 0.00, 0.05, 0.95), (-0.95, 0.00, 0.00, 1.05),
        (0.00, 0.00, -0.05, 1.25), (1.00, 0.00, 0.00, 1.00),
        (1.90, 0.00, 0.08, 0.90), (-1.20, 0.00, 0.42, 0.70),
        (-0.15, 0.00, 0.48, 0.90), (0.95, 0.00, 0.38, 0.72),
        (-0.10, 0.00, -0.30, 1.70),
    ],
}

def clear_previous():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for datablocks in (bpy.data.meshes, bpy.data.metaballs, bpy.data.curves):
        for block in list(datablocks):
            if block.users == 0:
                datablocks.remove(block)

def build_cloud(name, lobes):
    meta = bpy.data.metaballs.new(name + "_Surface")
    meta.resolution = 0.075
    meta.render_resolution = 0.045
    meta.threshold = 0.62
    meta.materials.clear()
    obj = bpy.data.objects.new(name + "_Metaball", meta)
    bpy.context.collection.objects.link(obj)

    for x, y, z, radius in lobes:
        element = meta.elements.new()
        element.co = (x, y, z)
        element.radius = radius
        element.stiffness = 2.0
        element.type = "BALL"

    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    mesh_obj = bpy.context.object
    mesh_obj.name = name
    mesh_obj.data.name = name + "_Mesh"

    # Smooth normals and modest polygon reduction while retaining silhouette.
    for polygon in mesh_obj.data.polygons:
        polygon.use_smooth = True
    dec = mesh_obj.modifiers.new("SAC_CloudDecimate", "DECIMATE")
    dec.ratio = 0.72
    bpy.context.view_layer.objects.active = mesh_obj
    bpy.ops.object.modifier_apply(modifier=dec.name)

    # Scale to a broad, useful source size in centimetres and recalculate normals.
    mesh_obj.scale = (280.0, 180.0, 130.0)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    mesh_obj.location = (0.0, 0.0, 0.0)
    mesh_obj.data.update()

    bpy.ops.object.select_all(action="DESELECT")
    mesh_obj.select_set(True)
    bpy.context.view_layer.objects.active = mesh_obj
    filepath = os.path.join(OUT, name + ".obj")
    bpy.ops.wm.obj_export(
        filepath=filepath,
        export_selected_objects=True,
        export_materials=False,
        export_normals=True,
        export_uv=False,
        forward_axis="Y",
        up_axis="Z",
    )
    print("SAC cloud mesh exported:", filepath, "vertices:", len(mesh_obj.data.vertices),
          "polygons:", len(mesh_obj.data.polygons))
    bpy.data.objects.remove(mesh_obj, do_unlink=True)

clear_previous()
for cloud_name, cloud_lobes in CLOUDS.items():
    build_cloud(cloud_name, cloud_lobes)
print("SAC connected cloud mesh generation complete.")

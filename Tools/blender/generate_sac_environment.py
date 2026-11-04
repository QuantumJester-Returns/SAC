import bpy, math, os
from mathutils import Vector
from math import radians

# SAC visual study: sapphire ocean, high sun, horizon cloud banks.
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
scene=bpy.context.scene
scene.render.engine='CYCLES' if os.environ.get('SAC_RENDER_ENGINE')=='CYCLES' else 'BLENDER_EEVEE'
scene.render.resolution_x=1280
scene.render.resolution_y=720
scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG'
scene.render.film_transparent=False
scene.render.filepath=os.environ.get('SAC_OUTPUT','/tmp/sac_environment.png')
scene.view_settings.view_transform='AgX'
scene.render.image_settings.color_mode='RGBA'
scene.render.resolution_percentage=100
scene.world=bpy.data.worlds.new('SAC Azure Atmosphere')
scene.world.use_nodes=True
bg=scene.world.node_tree.nodes.get('Background')
sky=scene.world.node_tree.nodes.new('ShaderNodeTexSky')
sky.sky_type='NISHITA'
sky.sun_elevation=radians(28)
sky.sun_rotation=radians(205)
sky.air_density=1.15
sky.ozone_density=1.0
sky.sun_disc=True
sky.sun_disc_size=radians(0.545)
sky.sun_intensity=1.0
scene.world.node_tree.links.new(sky.outputs['Color'],bg.inputs['Color'])
bg.inputs['Strength'].default_value=0.7
scene.view_settings.look='AgX - Medium High Contrast'

# Ocean: broad, flat, subtly disturbed surface; reflection carries sky and clouds.
bpy.ops.mesh.primitive_plane_add(size=2000, location=(0,0,0))
ocean=bpy.context.object
ocean.name='SAC_Ocean_Reflective'
mat=bpy.data.materials.new('SAC Deep Sapphire Water')
mat.diffuse_color=(0.008,0.055,0.14,1)
mat.use_nodes=True
p=mat.node_tree.nodes.get('Principled BSDF')
p.inputs['Base Color'].default_value=(0.006,0.045,0.12,1)
p.inputs['Metallic'].default_value=0.18
p.inputs['Roughness'].default_value=0.14
p.inputs['IOR'].default_value=1.333
noise=mat.node_tree.nodes.new('ShaderNodeTexNoise')
noise.inputs['Scale'].default_value=3.0
noise.inputs['Detail'].default_value=2.0
bump=mat.node_tree.nodes.new('ShaderNodeBump')
bump.inputs['Strength'].default_value=0.025
bump.inputs['Distance'].default_value=0.012
mat.node_tree.links.new(noise.outputs['Fac'],bump.inputs['Height'])
mat.node_tree.links.new(bump.outputs['Normal'],p.inputs['Normal'])
ocean.data.materials.append(mat)

# Sun high and right of frame.
bpy.ops.object.light_add(type='SUN', location=(0,0,100))
sun=bpy.context.object
sun.name='SAC Sun'
sun.data.energy=2.0
sun.data.angle=radians(1.2)
sun.rotation_euler=(radians(18),radians(-12),radians(-20))

# Cloud forms: clustered smooth ellipsoids, layered at horizon and higher sky.
cloudmat=bpy.data.materials.new('SAC Sunlit Cloud White')
cloudmat.diffuse_color=(0.82,0.9,1,1)
cloudmat.use_nodes=True
cp=cloudmat.node_tree.nodes.get('Principled BSDF')
cp.inputs['Base Color'].default_value=(0.78,0.87,1.0,1)
cp.inputs['Roughness'].default_value=0.92
cp.inputs['Subsurface Weight'].default_value=0.035

import random
rng=random.Random(7319)

def puff(name, loc, scale):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, location=loc)
    o=bpy.context.object
    o.name=name
    o.scale=scale
    bpy.ops.object.shade_smooth()
    o.data.materials.append(cloudmat)
    return o

def cloud_bank(name, x, y, z, width, depth, height, count):
    # Broad connected bases plus overlapping rounded crowns create real cloud masses.
    puff(name+'_Base',(x,y,z),(width,depth,height*0.48))
    for j in range(count):
        angle=rng.uniform(0.0,math.tau)
        radius=rng.uniform(0.12,0.72)*width
        px=x+math.cos(angle)*radius
        py=y+math.sin(angle)*depth*0.55
        pz=z+rng.uniform(0.12,0.62)*height
        sx=rng.uniform(0.28,0.52)*width
        sy=rng.uniform(0.30,0.62)*depth
        sz=rng.uniform(0.42,0.82)*height
        puff(name+'_Crown',(px,py,pz),(sx,sy,sz))

# Large broken banks along the horizon: overlapping silhouettes, not isolated discs.
for bank in range(17):
    x=-620+bank*78+rng.uniform(-18,18)
    y=410+rng.uniform(-55,85)
    z=95+rng.uniform(-8,24)
    cloud_bank('SAC_Horizon_Cloud',x,y,z,rng.uniform(34,58),rng.uniform(28,46),
               rng.uniform(24,38),rng.randint(5,9))

# Mid-distance cloud towers and shelves, with substantial vertical volume.
for i in range(13):
    x=-560+(i*91)%1120+rng.uniform(-24,24)
    y=230+(i%5)*45+rng.uniform(-18,18)
    z=150+(i%4)*23
    cloud_bank('SAC_Mid_Cloud',x,y,z,rng.uniform(20,34),rng.uniform(18,28),
               rng.uniform(18,30),rng.randint(3,6))

# A few small, high-altitude cloud fragments preserve the open sky.
for i in range(16):
    x=-560+(i*137)%1120+rng.uniform(-20,20)
    y=100+(i%6)*34
    z=225+(i%4)*27
    cloud_bank('SAC_High_Cloud',x,y,z,rng.uniform(9,16),rng.uniform(8,13),
               rng.uniform(7,12),rng.randint(2,3))

# Camera: low viewpoint, horizon high enough to retain broad foreground reflections.
bpy.ops.object.camera_add(location=(0,-760,105))
cam=bpy.context.object
cam.name='SAC_Reference_Camera'
target=Vector((0,360,112))
direction=target-Vector(cam.location)
cam.rotation_euler=direction.to_track_quat('-Z','Y').to_euler()
cam.data.lens=38
scene.camera=cam

# Render quality and denoising.
if scene.render.engine=='CYCLES':
    scene.cycles.samples=64
    scene.cycles.use_denoising=False  # Ubuntu Blender build lacks OpenImageDenoiser
else:
    scene.eevee.taa_render_samples=32
scene.render.filepath=os.environ.get('SAC_OUTPUT','/tmp/sac_environment.png')
# Export reusable geometry for the UE5 import pipeline.
# Keep the Blender study editable, but also deliver compact, separated GLB assets.
out_dir=os.path.dirname(os.path.abspath(scene.render.filepath))
os.makedirs(out_dir, exist_ok=True)
cloud_objects=[o for o in scene.objects if o.type=='MESH' and o.name.startswith('SAC_Horizon_Cloud') or o.type=='MESH' and o.name.startswith('SAC_Mid_Cloud') or o.type=='MESH' and o.name.startswith('SAC_High_Cloud')]
if not cloud_objects:
    raise RuntimeError('No SAC cloud meshes were generated')
bpy.ops.object.select_all(action='DESELECT')
for obj in cloud_objects:
    obj.select_set(True)
bpy.context.view_layer.objects.active=cloud_objects[0]
bpy.ops.object.join()
clouds=bpy.context.object
clouds.name='SAC_Cloud_Field_Combined'
cloud_path=os.path.join(out_dir,'SAC_Cloud_Field.obj')
bpy.ops.object.select_all(action='DESELECT')
clouds.select_set(True)
bpy.context.view_layer.objects.active=clouds
bpy.ops.wm.obj_export(filepath=cloud_path, export_selected_objects=True, export_materials=True)

ocean_path=os.path.join(out_dir,'SAC_Ocean_Surface.obj')
bpy.ops.object.select_all(action='DESELECT')
ocean.select_set(True)
bpy.context.view_layer.objects.active=ocean
bpy.ops.wm.obj_export(filepath=ocean_path, export_selected_objects=True, export_materials=True)

# Save the editable source scene after the export objects have been consolidated.
bpy.ops.object.select_all(action='DESELECT')
bpy.ops.wm.save_as_mainfile(filepath=os.environ.get('SAC_BLEND','/tmp/SAC_Environment_Study.blend'))
bpy.ops.render.render(write_still=True)
for path in (cloud_path,ocean_path,scene.render.filepath):
    if not os.path.isfile(path) or os.path.getsize(path)==0:
        raise RuntimeError('Missing or empty SAC output: '+path)
    print('SAC_OUTPUT_READY',path,os.path.getsize(path))
print('SAC_RENDER_COMPLETE',scene.render.filepath)

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
sky.sky_type='SINGLE_SCATTERING'
sky.sun_elevation=radians(48)
sky.sun_rotation=radians(225)
sky.air_density=1.0
sky.dust_density=0.7
sky.ozone_density=1.0
scene.world.node_tree.links.new(sky.outputs['Color'],bg.inputs['Color'])
bg.inputs['Strength'].default_value=0.35

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
p.inputs['Roughness'].default_value=0.095
p.inputs['IOR'].default_value=1.333
noise=mat.node_tree.nodes.new('ShaderNodeTexNoise')
noise.inputs['Scale'].default_value=3.0
noise.inputs['Detail'].default_value=2.0
bump=mat.node_tree.nodes.new('ShaderNodeBump')
bump.inputs['Strength'].default_value=0.075
bump.inputs['Distance'].default_value=0.025
mat.node_tree.links.new(noise.outputs['Fac'],bump.inputs['Height'])
mat.node_tree.links.new(bump.outputs['Normal'],p.inputs['Normal'])
ocean.data.materials.append(mat)

# Sun high and right of frame.
bpy.ops.object.light_add(type='SUN', location=(0,0,100))
sun=bpy.context.object
sun.name='SAC Sun'
sun.data.energy=3.0
sun.data.angle=radians(0.7)
sun.rotation_euler=(radians(25),radians(-18),radians(-25))

# Cloud forms: clustered smooth ellipsoids, layered at horizon and higher sky.
cloudmat=bpy.data.materials.new('SAC Sunlit Cloud White')
cloudmat.diffuse_color=(0.82,0.9,1,1)
cloudmat.use_nodes=True
cp=cloudmat.node_tree.nodes.get('Principled BSDF')
cp.inputs['Base Color'].default_value=(0.78,0.87,1.0,1)
cp.inputs['Roughness'].default_value=0.92
cp.inputs['Subsurface Weight'].default_value=0.035

def puff(name, loc, scale):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, location=loc)
    o=bpy.context.object; o.name=name; o.scale=scale
    bpy.ops.object.shade_smooth()
    o.data.materials.append(cloudmat)
    return o

# Horizon banks: intentionally concentrated near horizon, leaving open blue sky.
for bank in range(18):
    x=-420+bank*49
    y=420+(bank%3)*55
    z=62+(bank%4)*13
    for j in range(4+(bank%3)):
        puff('SAC_Horizon_Cloud', (x+j*19-28,y+(j%2)*16,z+(j%3)*7),
             (22+(j%3)*7,15+(j%2)*5,10+(j%3)*4))
# Mid-distance broken cloud clusters, higher and smaller.
for i in range(48):
    x=-520+(i*83)%1040
    y=210+(i%6)*32
    z=125+(i%5)*27
    s=8+(i%4)*3
    puff('SAC_Mid_Cloud',(x,y,z),(s*1.5,s,s*0.55))
# Small high wisps.
for i in range(32):
    x=-560+(i*97)%1120
    y=90+(i%7)*22
    z=205+(i%4)*24
    s=4+(i%3)*2
    puff('SAC_High_Cloud',(x,y,z),(s*2.4,s*0.7,s*0.35))

# Camera: low viewpoint, horizon high enough to retain broad foreground reflections.
bpy.ops.object.camera_add(location=(0,-760,105))
cam=bpy.context.object
cam.name='SAC_Reference_Camera'
target=Vector((0,300,92))
direction=target-Vector(cam.location)
cam.rotation_euler=direction.to_track_quat('-Z','Y').to_euler()
cam.data.lens=38
scene.camera=cam

# Render quality and denoising.
scene.render.engine='CYCLES' if os.environ.get('SAC_RENDER_ENGINE')=='CYCLES' else 'BLENDER_EEVEE'
if scene.render.engine=='CYCLES':
    scene.cycles.samples=24
    scene.cycles.use_denoising=True
else:
    scene.eevee.taa_render_samples=32
scene.render.filepath=os.environ.get('SAC_OUTPUT','/tmp/sac_environment.png')
bpy.ops.wm.save_as_mainfile(filepath=os.environ.get('SAC_BLEND','/tmp/SAC_Environment_Study.blend'))
bpy.ops.render.render(write_still=True)
print('SAC_RENDER_COMPLETE',scene.render.filepath)

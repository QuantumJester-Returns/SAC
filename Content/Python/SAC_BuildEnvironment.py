"""Build the first SAC environment level from generated Blender OBJ assets.

Run inside Unreal Editor using Tools > Execute Python Script.
The source OBJ/MTL files are expected under Content/SourceAssets/Generated.
"""
import os
import unreal

PROJECT_DIR = unreal.Paths.project_dir()
SOURCE_DIR = os.path.join(PROJECT_DIR, "Content", "SourceAssets", "Generated")
DESTINATION = "/Game/SAC/Environment"
LEVEL_PATH = "/Game/Maps/SAC_Environment"


def import_obj(filename):
    source = os.path.join(SOURCE_DIR, filename)
    if not os.path.isfile(source):
        raise RuntimeError("Missing generated SAC source asset: " + source)

    task = unreal.AssetImportTask()
    task.filename = source
    task.destination_path = DESTINATION
    task.automated = True
    task.replace_existing = True
    task.save = True
    unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])
    if not task.imported_object_paths:
        raise RuntimeError("Unreal failed to import " + filename)
    asset = unreal.load_asset(task.imported_object_paths[0])
    if not asset:
        raise RuntimeError("Unreal could not load imported asset " + filename)
    return asset


def spawn_mesh(mesh, label, location, scale):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_object(
        mesh, unreal.Vector(*location), unreal.Rotator(0.0, 0.0, 0.0)
    )
    if not actor:
        raise RuntimeError("Could not spawn " + label)
    actor.set_actor_label(label)
    actor.set_actor_scale3d(unreal.Vector(*scale))
    return actor


def add_directional_light():
    light = unreal.EditorLevelLibrary.spawn_actor_from_class(
        unreal.DirectionalLight, unreal.Vector(0.0, 0.0, 50000.0),
        unreal.Rotator(-35.0, -25.0, 0.0)
    )
    light.set_actor_label("SAC Sun")
    component = light.get_component_by_class(unreal.DirectionalLightComponent)
    if component:
        component.set_editor_property("intensity", 10.0)
        component.set_editor_property("light_color", unreal.LinearColor(0.78, 0.88, 1.0, 1.0))
    return light


def build():
    if not unreal.EditorLevelLibrary.new_level(LEVEL_PATH):
        raise RuntimeError("Could not create SAC environment level")

    cloud_mesh = import_obj("SAC_Cloud_Field.obj")
    ocean_mesh = import_obj("SAC_Ocean_Surface.obj")

    # Blender units are mapped to centimeters at this stage: 100x keeps
    # the 2 km study ocean and cloud field at the intended world scale.
    spawn_mesh(ocean_mesh, "SAC Ocean Surface", (0.0, 0.0, 0.0), (100.0, 100.0, 100.0))
    spawn_mesh(cloud_mesh, "SAC Cloud Field", (0.0, 0.0, 0.0), (100.0, 100.0, 100.0))
    add_directional_light()

    unreal.EditorLevelLibrary.save_current_level()
    unreal.log("SAC environment level assembled. Verify imported materials and scale in-editor.")


build()

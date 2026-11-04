# SAC Cloud Mesh Source Assets

Original, editable 3D source assets created specifically for Sea Among The Clouds.

## Mesh generations

- `SAC_CloudBank_01.obj`, `SAC_CloudTower_01.obj`, `SAC_CloudShelf_01.obj`: first-pass intersecting ellipsoid blockouts.
- `Tools/generate_cloud_meshes.py`: Blender-based generator for connected 02-generation cloud meshes.
- Generated outputs: `Generated/SAC_CloudBank_02.obj`, `Generated/SAC_CloudTower_02.obj`, and `Generated/SAC_CloudShelf_02.obj`.

The 02 meshes are generated from Blender metaball surfaces, converted to smooth polygon meshes and lightly decimated. Each output is a single connected mesh object rather than separate intersecting puff shells. They are mesh clouds, not physically simulated volumetric clouds.

## Generate and import

1. On a PC with Blender 3.6+, run `blender --background --python Tools/generate_cloud_meshes.py` from the repository root.
2. Import the three OBJ files from `Content/SourceAssets/Clouds/Generated/` into Unreal under `Content/Environment/Clouds/Source/`.
3. Inspect normals and silhouette; create a soft, high-roughness, non-metallic cloud material.
4. Assign bank/shelf/tower meshes to the corresponding mesh properties on `ASACCloudField`.
5. Profile density, material cost and LODs on the target PC and Android test device.

The 01 blockouts remain available as fallback meshes. Generated OBJ source files must be imported and saved as Unreal `.uasset` assets before packaging.

## Rights and provenance

All cloud forms are generated specifically for this project and have no third-party asset dependency. They may be modified and used in SAC. Retain this provenance note if redistributed.

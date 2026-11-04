# Cloud Mesh Upgrade — Milestone 02

## Goal
Upgrade the simple intersecting-puff blockout into connected, organic cloud silhouettes while retaining the deterministic three-layer `ASACCloudField` placement actor.

## Generator added
`Tools/generate_cloud_meshes.py` uses Blender's metaball surface solver to create three continuous mesh clouds:
- `SAC_CloudBank_02.obj` — broad rolling cloud bank.
- `SAC_CloudTower_02.obj` — tall vertical formation.
- `SAC_CloudShelf_02.obj` — elongated low shelf for horizon layers.

The generated forms are converted to smooth polygon meshes, lightly decimated, scaled to useful source dimensions, and exported as OBJ with normals. This avoids leaving the final model as separate intersecting ellipsoid shells.

## Generate the assets
Run on a PC with Blender 3.6 or newer:

```bash
blender --background --python Tools/generate_cloud_meshes.py
```

Output files are written to `Content/SourceAssets/Clouds/Generated/`. Import those OBJ files into Unreal Engine under `Content/Environment/Clouds/Source/`.

## UE5 integration
1. Inspect each imported mesh for a continuous silhouette and smooth shading.
2. Create a non-metallic cloud material with soft highlights, subtle colour variation and atmospheric depth.
3. Assign bank/shelf/tower meshes to the appropriate Near/Mid/Far mesh properties of `ASACCloudField`.
4. Tune scale and density from the player camera; use sparse towers as distant focal silhouettes.
5. Profile Android separately and keep a reduced instance-count/material path available.

## Acceptance checks
- The generator completes in Blender without errors.
- Each output is a single connected mesh object with smooth shading and exported normals.
- Visual silhouette and material quality are approved in Unreal, not inferred from source validation.

GitHub checks validate source files only. They do not run Blender, compile Unreal, or package an APK.

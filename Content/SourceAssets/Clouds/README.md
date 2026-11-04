# SAC Cloud Mesh Source Assets

These are original, editable 3D mesh source files created specifically for Sea Among The Clouds. They are not screenshots, billboards, or downloaded marketplace assets.

## Included meshes

- `SAC_CloudBank_01.obj` — broad horizontal bank for low and middle-distance cloud fields.
- `SAC_CloudTower_01.obj` — vertically rising formation for dramatic scale and silhouettes.
- `SAC_CloudShelf_01.obj` — long, low shelf formation for cloud layers near the horizon.
- `SAC_Clouds.mtl` — simple neutral material reference for OBJ import.

Each OBJ contains multiple intersecting ellipsoid puff meshes. The geometry is intentionally simple at this stage so it can be reshaped, subdivided, remeshed, or replaced with a higher-detail sculpt in Blender.

## Import into Unreal Engine

1. Copy the OBJ and MTL files into a working asset folder.
2. In Unreal Editor, use **Import** in the Content Browser and select the OBJ.
3. Enable normal/tangent generation as appropriate; inspect the result for shading seams.
4. Apply a new Unreal material rather than relying on the simple MTL placeholder.
5. Test at several scales and distances. Use Nanite only where supported and justified by the target platform.
6. Save the imported asset as a project `.uasset` inside `Content/Environment/Clouds/`.

## Important visual note

These are first-pass 3D blockout meshes, not final volumetric clouds. The final look should come from carefully authored geometry plus a high-quality cloud material, soft lighting, atmospheric depth, and layered composition. Do not mistake the blockout geometry for the finished visual target.

## Rights and provenance

The mesh geometry in this folder is generated specifically for this project and has no third-party asset dependency. It may be modified and used in SAC. The project should retain this provenance note if the files are redistributed.

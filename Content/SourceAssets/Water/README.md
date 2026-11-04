# SAC Ocean Surface Source Mesh

`SAC_OceanSurface_Base.obj` is an original project-generated 3D ocean surface grid.

- 6,561 vertices and 12,800 triangles.
- Approximately 6 km square in source-space units (to be checked against Unreal's centimetre scale on import).
- Very subtle base undulation; intended to be paired with a dedicated Unreal water material.
- No external textures, downloaded geometry, or third-party dependencies.

## Unreal import

Import the OBJ as a static mesh and inspect its scale, normals, bounds, and shading. Unreal uses centimetres by default, so confirm the import scale before placing it in the arena. This is a base surface mesh, not a finished water system.

## Important

The final ocean must be driven by an Unreal material and appropriate reflection/rendering features. The source mesh alone does not provide animated waves, realistic reflections, foam, or interaction. Those are separate material and gameplay tasks.

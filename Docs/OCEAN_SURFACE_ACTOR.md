# SAC Ocean Surface Actor

## Purpose

`ASACOceanSurface` is the reusable Unreal actor that joins the imported ocean mesh, its water material, and the impact-ripple driver. It keeps gameplay calls independent from the eventual material graph.

## Editor setup

1. Import `Content/SourceAssets/Water/SAC_OceanSurface_Base.obj` into Unreal as a Static Mesh.
2. Create the water master material separately. It must implement the four ripple parameter groups listed in `WATER_INTERACTION.md`.
3. Place an `SACOceanSurface` actor in the arena level.
4. Assign the imported mesh to `Surface Mesh Asset`.
5. Assign the water master material to `Water Material`.
6. Leave collision disabled until the character/water interaction design requires a collision surface. If collision is enabled, select an appropriate project collision profile.
7. Test the surface at its intended world scale and inspect mesh bounds, normals, UVs, and collision before tuning the material.

## Gameplay interface

Call `ApplyWaterImpact(WorldLocation, ImpulseMagnitude)` on the actor. Impulse is measured in N*s and is forwarded to `USACWaterRippleComponent`.

The actor does not create the water material, mesh asset, reflections, waves, or ripple material graph. Those remain separate editor-side assets and validation tasks.

## Current status

This is Unreal C++ source, not a compiled or editor-validated asset. The OBJ is still source geometry until imported and saved as a `.uasset` in Unreal Editor.

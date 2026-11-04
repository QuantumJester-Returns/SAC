# SAC Asset Strategy — Free-First, Quality-First

## Guiding rule

Use the best assets we can legally use for free. Free does not mean accepting low quality, and quality does not mean downloading assets without checking their rights.

The long-term PC version is the visual target. Android is a later constrained build target and should receive deliberate optimization rather than dictating the artistic ceiling of the PC world.

## Asset pipeline

1. Prefer original project-made assets when they are practical and distinctive.
2. For third-party assets, verify the exact licence and redistribution terms before adding them.
3. Prefer source formats that can be edited in Blender or Unreal.
4. Keep source assets separate from Unreal-imported `.uasset` files.
5. Record creator, source URL, licence, attribution, and any modifications.
6. Use Git LFS for large binary files where needed; do not commit generated engine cache or packaged builds.

## 3D formats

- **OBJ:** useful interchange format for static meshes and early geometry.
- **FBX:** useful for meshes, rigs, and animation when needed.
- **BLEND:** editable Blender source; use when Blender project files are part of the asset handoff.
- **EXR/HDR:** environment and lighting sources; verify provenance and licence before use.
- **UASSET/UMAP:** Unreal-native imported assets and level content, generated and saved by Unreal Editor.

## First environment asset priorities

1. Cloud formations with real 3D volume and varied silhouettes.
2. Large-scale ocean surface geometry and a dedicated water material.
3. Sky and atmospheric lighting setup.
4. Distant cloud layers and scale landmarks.
5. Small environmental details only after the main composition works.

## Current original cloud source meshes

See `Content/SourceAssets/Clouds/`. These first-pass models are editable OBJ geometry created for SAC. They are blockout forms, not final volumetric cloud rendering.

## Free asset sourcing

Potential sources to evaluate include:
- Unreal Engine's free learning samples and free content offers, subject to the licence shown for each asset.
- Fab free assets, checking the specific listing licence and redistribution limits.
- Poly Haven assets, checking the asset's stated CC0 status and any source-specific notes.
- Blender's built-in modelling tools and project-authored geometry.

Never assume that an asset being downloadable for free means it can be repackaged or redistributed inside the game. Record the exact licence for each chosen asset.

## Visual quality bar

The environment should feel expansive, atmospheric, and coherent. Prioritise silhouette, scale, lighting, material response, and depth over sheer polygon count. Use high detail where it contributes visibly, and use efficient level-of-detail strategies for distant scenery.

# Sea Among The Clouds: clean Godot recovery

A new, isolated Godot 4.7.2 project using the GL Compatibility renderer.

## Separation rules
- All new project work lives in `SAC-Godot/`.
- The legacy `Godot/` directory is not used, copied from, or modified.
- The discarded Unreal project is not used.
- The old APK workflow is not used.

## Current prototype
The entry scene now creates a bright open-sky arena, a high directional sun, a broad reflective sea surface using the recovered still-sea shader, a 6.2-foot (1.88976 m) temporary player capsule, a distant opponent marker, a third-person camera, and basic on-screen directional controls.

The Android export preset and a separate clean-build workflow target landscape orientation and arm64.

## Important status
This is an initial playable-scene prototype, **not yet a verified APK**. The source has been committed, but Godot 4.7.2 is not installed in the current working container, and the GitHub Actions workflow has not yet produced a run. The scene therefore still needs engine import, parser/runtime validation, and an Android export test.

The uploaded original character GLB and 4K sky EXR are available in this conversation, but their binary contents have not yet been transferred into the Git branch. The current player is deliberately a plain capsule placeholder, not a claim that the original model is integrated.

## Next integration targets
- Import the original character GLB and confirm its real-world height is 1.88976 m.
- Bring in the uploaded 4K sky EXR and tune the sky/sun to the supplied reference.
- Refine water reflections and the shoreline-free horizon after a device render test.
- Replace the temporary capsule with the original un-clothed base mesh.

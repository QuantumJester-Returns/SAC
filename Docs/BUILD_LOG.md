# SAC Development Build Log

## 2026-11-04 — Repository foundation

- Confirmed GitHub write access and verified the repository's default branch.
- Added the project vision and Milestone 1 arena specification.
- Added the initial technical plan and Git ignore/LFS guidance.

## 2026-11-04 — World Study 01

- Added a browser-based environment prototype in `Prototype/index.html`.
- Implemented a procedural atmospheric sky, sun focal point, animated stylized water, and layered procedural cloud clusters.
- Added prototype run instructions and known limitations.

### Next development tasks

1. Review the prototype's visual direction and refine sea/sky/cloud composition.
2. Confirm the Unreal Engine version to target.
3. Create the native Unreal project and a minimal playable arena.
4. Replace prototype approximations with engine-native environment systems.

## 2026-11-04 — First original 3D environment source assets

- Added three editable OBJ cloud formations: a broad bank, a vertical tower, and a low shelf.
- Corrected cloud mesh face winding so surfaces are outward-facing.
- Added a generated ocean base mesh with 6,561 vertices and 12,800 triangles.
- Added import notes and asset provenance documentation.
- Added a free-first asset strategy and a phone-only development workflow.
- These are genuine 3D source meshes, not final Unreal-imported assets or finished volumetric rendering.

### Next environment tasks

1. Import and inspect the source meshes in Unreal Editor when a build environment is available.
2. Create the high-quality ocean material and reflection setup.
3. Develop the cloud material and layered atmospheric composition.
4. Establish the arena map, sun, and sky system.


## 2026-11-04 — Unreal Engine 5 environment foundation

- Confirmed Unreal Engine 5 as the final engine; the prior Godot APK is reference material only.
- Added an Unreal C++ environment controller for Sky Atmosphere, sun lighting, skylight, and exponential height fog.
- Added the Environment Milestone 01 setup and acceptance checklist.
- Added the animation recovery plan: the old 42-clip report is useful evidence, but the editable retargeted GLB is not present as a source file in the APK.
- Confirmed the previous Godot sea shader's core behaviour: calm baseline, event-triggered expanding ripple, force-scaled amplitude. Its material implementation will be recreated in Unreal.
- Animation replacement will be sourced from free libraries only after checking exact licences; animation work does not block the environment milestone.

### Current validation status

- GitHub source commits: verified by fetching the newly committed files.
- Unreal C++ compile: not yet run; no Unreal Editor/build environment is available in the phone-only workflow.
- Unreal asset import and level assembly: pending editor access.
- Android APK: no new Unreal package has been built.

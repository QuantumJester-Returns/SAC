# Sea Among The Clouds: clean Godot recovery

This project is a new, isolated Godot project targeting **Godot 4.7.2** with the **GL Compatibility** renderer.

## Separation rule

- This project lives in `SAC-Godot/`.
- The legacy `Godot/` directory is not used as a source, dependency, build input, or destination.
- The Unreal project is not used.
- No legacy project files are copied into this project.

## Recovery priorities

1. Preserve the recovered character model.
2. Reconstruct the arena and its visual environment from the recovered APK references.
3. Restore the original interactive still-sea water behavior.
4. Integrate and verify the 42-clip retargeted animation library.
5. Establish a reproducible Android export only after the clean project is validated.

## Current state

This commit establishes the isolated project boundary and a minimal entry scene. It is **not yet the recovered playable game**. The original APK contains compiled scripts and packed scene data rather than a complete editable project. Recovered source assets must be added and validated before gameplay reconstruction.

## Expected layout

- `assets/characters/`: original character source assets
- `assets/animations/`: retargeted animation library
- `assets/environment/`: recovered sky and arena source assets
- `shaders/`: recovered water shader source
- `scenes/`: clean editable Godot scenes
- `scripts/`: clean editable Godot scripts
- `recovery_reference/`: read-only reference material; never used as project source code

## Build policy

No Android workflow is attached to this project yet. In particular, changes here must not trigger the legacy APK workflow, which targets `Godot/` and Godot 4.4.1.

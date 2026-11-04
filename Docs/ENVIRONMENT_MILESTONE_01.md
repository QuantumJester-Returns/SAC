# SAC — Environment Milestone 01

## Goal

Create the first native Unreal Engine 5 arena foundation. This milestone is about the world itself: an immense sky, a readable sun, atmospheric depth, the deep-blue sea, and layered 3D clouds.

The PC visual target remains the quality ceiling. Android testing will be profiled and optimized after the visual baseline exists.

## Included source foundation

- ASACEnvironmentController: C++ actor that creates and configures a Sky Atmosphere, directional sun, movable Sky Light, and Exponential Height Fog.
- USACWaterRippleComponent: gameplay-to-material bridge for force-driven ripple events.
- Original cloud and ocean OBJ source meshes in Content/SourceAssets/.

These source classes and OBJ files are not Unreal-imported assets. They require an Unreal Editor project generation/import/compile pass before they can be considered working in-engine.

## Level setup once Unreal Editor is available

1. Generate project files with the selected Unreal Engine 5 installation.
2. Compile the SAC C++ project.
3. Create a level named L_SAC_Arena.
4. Add one SACEnvironmentController actor.
5. Add the ocean base mesh and assign a dedicated water master material.
6. Import the cloud OBJ source meshes and place near, middle, and far cloud formations.
7. Add a Player Start and verify the existing SAC player pawn and camera.
8. Set the level as the editor startup map and package a development build only after a successful compile.

## Sky and EXR direction

Use Unreal Sky Atmosphere as the primary sky and atmospheric scattering system. The supplied rustig_koppie_puresky_4k.exr is a visual reference and a possible HDR lighting/reflection source, not automatically the final visible sky dome.

Import the EXR in Unreal and inspect its colour space, exposure, orientation, and dynamic range. Verify its source licence before redistributing it. Do not combine a bright HDRI sky dome with a competing physical sky until the lighting result has been checked.

## Sea direction

The baseline sea must read as deep blue, expansive, and reflective. At rest, it should remain still. The water material must not contain permanently scrolling normal textures or ambient wave animation in this milestone.

The ripple component exposes four event slots. The master material must implement the matching parameter names documented in WATER_INTERACTION.md. The material graph is a separate required task; the C++ component alone does not render ripples.

## Cloud direction

Use the original cloud meshes as layout and scale prototypes. Improve silhouettes before final materials:
- Near clouds: large, detailed, soft forms that establish scale.
- Mid-distance: connected banks and shelves that frame the horizon.
- Far distance: low-contrast atmospheric masses that support depth.

Do not use a single repeated cloud mesh at identical scale and orientation. Vary scale, rotation, silhouette, and spacing. Final volumetric rendering is a later quality pass; first validate the world composition.

## Definition of done

- The project opens and compiles in the selected UE5 version.
- The level starts with the correct player pawn and camera.
- The sky and sun establish a coherent lighting direction.
- Atmospheric depth makes the horizon feel distant.
- The sea has a convincing deep-blue baseline and remains still at rest.
- Cloud formations establish vertical and horizontal scale.
- No Godot runtime or shader dependency remains in the shipping project.
- A real development build has been installed and tested before calling the milestone complete.

## Not included yet

- Finished character animation state machine.
- Combat, multiplayer, inventory, progression, crafting, or lobby systems.
- Final volumetric cloud rendering.
- Final animated wave simulation.
- Signed release APK.

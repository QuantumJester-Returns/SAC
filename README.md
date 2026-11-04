# Sea Among The Clouds (SAC)

**Build the world first, then build the game that belongs in it.**

Sea Among The Clouds is a native 3D game project. The primary engine is Unreal Engine 5, and Android is the first hands-on test platform. Development focuses on a real-time playable world, not a browser game.

## First milestone — The arena

Create a convincing, explorable environment built around:
- A vast, deep-blue reflective sea with restrained surface motion.
- An enormous sky with atmospheric depth and natural sunlight.
- Clouds floating beneath and around sea altitude.
- Coherent lighting and reflections across the environment.
- A playable space for later movement and combat tests.

## Development order

1. Establish the native Unreal project and a minimal playable character.
2. Build the sea, sky, clouds, and lighting.
3. Refine scale, atmosphere, and performance.
4. Add mobile touch controls and device-specific optimization.
5. Package a signed Android APK at major milestones for real-device testing.

## Android update continuity

The Android application ID is initially com.quantumjester.sac. A persistent private signing keystore will be created and securely backed up before the first distributed APK. The keystore and passwords must never be committed to this repository. Future APKs must retain the same application ID and signing identity, and their version codes must increase.

See Docs/ANDROID_RELEASE_PLAN.md for the signing and packaging policy.

## Repository structure

- Config/ — Unreal project and input configuration.
- Content/ — maps, materials, meshes, blueprints, and other game assets.
- Docs/ — milestone specifications, technical decisions, and build records.
- Source/ — C++ game code.
- SAC.uproject — Unreal project descriptor.

## Scope discipline

The first milestone is the world foundation. Do not divert effort into lobbies, dungeons, multiplayer, progression, crafting, inventory, rankings, or finished combat before the arena is stable and explorable.

## Status

In progress: native Unreal project foundation and first arena implementation.

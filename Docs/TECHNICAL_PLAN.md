# SAC — Technical Plan

## Platform and project

- Engine: Unreal Engine 5.
- First hands-on target: native Android (ARM64).
- Main implementation: C++ gameplay foundation plus Unreal-native maps, materials, and assets.
- Repository: GitHub, with large binary assets tracked using Git LFS where appropriate.

The exact Unreal Engine release must be selected before the first local compile and Android package. The Android SDK, NDK, and Java toolchain must match that engine release.

## First milestone: the arena

Build the environment before adding unrelated game systems:
1. Establish a minimal playable character and camera.
2. Create a large-scale arena map.
3. Establish the sky, atmospheric lighting, and sun direction.
4. Build the sea surface, restrained waves, and convincing reflections.
5. Add cloud layers at and below sea altitude.
6. Tune horizon, scale, colour, and visual depth.
7. Profile performance on the target Android device.

## Rendering approach

### Water
Develop an Unreal material and geometry approach that supports:
- Deep-blue appearance with natural lighting variation.
- Restrained, low-amplitude surface movement.
- Stable reflections of sky and clouds.
- Mobile-appropriate shader complexity.

An earlier roughness value around 0.025 was only a visual reference, not a locked physical parameter. Validate the final response under the selected rendering pipeline and lighting.

### Sky and atmosphere
Evaluate Unreal Sky Atmosphere and supported sky/lighting components as the primary system. Avoid adding a separate HDR sky that conflicts with the engine atmosphere.

A previously considered HDR file was named rustig_koppie_puresky_4k.exr. Verify its provenance, licence, and suitability before including it.

### Clouds
Use layered cloud forms with clear near, middle, and far depth. Choose a rendering approach that meets the visual target while remaining viable on Android hardware.

## Android build and update strategy

- Keep application ID com.quantumjester.sac unchanged after first release.
- Package ARM64 APKs for milestone testing.
- Increase Android version code for every distributed update.
- Sign every update with the same protected release keystore.
- Never commit keystore files or passwords.
- Back up the keystore securely before distributing the first signed APK.

See ANDROID_RELEASE_PLAN.md for the release workflow and security rules.

## Asset and licence policy

For every external asset, record its source, creator, licence, attribution requirements, local path, and modifications. Do not commit assets with unclear redistribution rights.

## Source control

- Keep source, configuration, and documentation in Git.
- Use Git LFS for large binary assets when appropriate.
- Exclude generated build products and local signing material.
- Make focused commits with descriptive messages.

## Validation

For each major environment change, compare repeatable views:
- Wide horizon.
- Low camera angle near the water.
- View toward the sun.
- View away from the sun.
- View showing cloud depth and vertical placement.

A milestone APK is only considered ready after a real package build and installation test on the phone.

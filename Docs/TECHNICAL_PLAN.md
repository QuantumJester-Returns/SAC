# SAC — Initial Technical Plan

## 1. Engine and project structure

Unreal Engine 5 is the intended primary engine. Confirm and record the exact engine release before generating engine-version-specific project files or plugins.

Use a clear separation between:
- **Environment:** water, sky, clouds, atmosphere, lighting.
- **Arena:** map composition, scale references, traversal space.
- **Player test layer:** a minimal pawn and camera for exploration.
- **Validation:** repeatable screenshots, performance observations, and setup documentation.

## 2. Rendering approach

### Water
Start with an Unreal material and a deliberately restrained surface response. Evaluate:
- Reflection quality and stability.
- Roughness and specular response under the chosen lighting.
- Large-scale colour variation and subtle normal movement.
- Cost of reflection features at the intended camera distances.

Do not lock a roughness value from an early visual reference without checking it under the actual lighting and rendering configuration.

### Sky and atmosphere
Evaluate Unreal Sky Atmosphere and the engine's supported sky/lighting components first. A separately sourced HDR environment may be useful for reference or a controlled lighting experiment, but it should not be added blindly as a competing sky system.

A previously considered source file was named `rustig_koppie_puresky_4k.exr`. Its availability, provenance, licence, and compatibility must be verified before use.

### Clouds
Prototype cloud placement and depth independently from the water. Choose the least complex approach that meets the visual target, then test how it behaves with the selected lighting and camera distances.

## 3. Asset and licence policy

For every external asset, record:
- Asset name and source URL.
- Creator or publisher.
- Licence and attribution requirements.
- Local project path.
- Any modifications made.

Do not commit assets whose licence or redistribution terms are unclear. Large binary assets should use Git LFS when appropriate.

## 4. Source control

- Keep the Unreal project and documentation in Git.
- Use Git LFS for large binary formats when needed.
- Keep generated build products and local editor state out of version control.
- Make focused commits with descriptive messages.
- Keep the default branch buildable and documented.

## 5. Development sequence

1. Confirm the Unreal Engine version and create/open the project.
2. Establish a minimal arena map and player test pawn.
3. Build the sky and atmospheric lighting baseline.
4. Add the sea material and validate reflections.
5. Add cloud layers and tune their relationship to the horizon and sea.
6. Establish scale references and a repeatable camera test route.
7. Profile the scene and document known limitations.
8. Review the acceptance criteria in the Milestone 1 specification.

## 6. Validation

For each major visual change, capture the same set of views:
- Wide horizon view.
- Low camera angle near the water.
- View toward the sun.
- View away from the sun.
- View showing cloud depth and vertical placement.

Record engine version, rendering settings, hardware, and any known limitations alongside performance measurements.

## 7. Decision log

Record confirmed decisions here as the project develops. Keep proposed approaches clearly distinguished from implemented and tested ones.

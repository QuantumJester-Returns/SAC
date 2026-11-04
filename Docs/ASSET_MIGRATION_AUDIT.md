# SAC Asset Migration Audit — Godot Prototype to Unreal Engine 5

## Decision

Unreal Engine 5 is the project's final engine. The previous Godot APK is a reference build only. Do not continue gameplay development in Godot or treat Godot's imported scene cache as source assets.

## Supplied files inspected

### Sky environment

- File: `rustig_koppie_puresky_4k.exr`
- Size: approximately 71 MB.
- Format: OpenEXR, 4K panoramic image.
- The file is retained as a visual reference pending licence/provenance confirmation and an Unreal import test.
- Unreal Sky Atmosphere should be evaluated as the primary atmospheric system. The EXR may be used as a lighting/reflection reference or a controlled sky backdrop if that produces the intended look without fighting the physical atmosphere.

### Character base mesh

- File: `Male Base Mesh (T-Pose).glb`
- Size: approximately 1.1 MB.
- glTF 2.0 binary.
- One skinned mesh, one skin, 65 joints, and one embedded animation named `Armature|mixamo.com|Layer0`.
- The model is therefore rigged and animated; it is not merely a static T-pose mesh.
- Import into Unreal as a Skeletal Mesh and inspect the skeleton, bind pose, scale, material slots, and embedded animation before assigning it as the production character.

### Previous Android build

- File: `SAC-v1.6.0 (1).zip`, containing `SAC-v1.6.0.apk`.
- This is a compiled Godot Android APK, not the editable Godot project and not an Unreal project.
- The APK includes a Godot shader named `interactive_still_sea.gdshader`, import metadata, compiled scene/script resources, and character validation reports.
- The Godot shader is a behaviour reference only; it must be recreated as an Unreal material.

## Animation investigation

The APK's reports document a successful earlier retarget preparation:
- Target armature: `Armature`, 65 bones.
- Source armature: `Rig`, 53 bones.
- 52 source bones mapped to target bones.
- One source-only root bone was intentionally ignored.
- No unmapped source bones or mapping collisions were reported.
- The re-import validation report lists 42 animation actions with curves, including idle, walk, jog, sprint, jump, swim, crouch, sword, punch, and interaction clips.
- The validation report describes a 65-bone armature and one skinned mesh in the retargeted animation GLB.

Important distinction: these reports prove that the previous pipeline had a validated 42-clip retarget result. The APK does not contain the original editable project or the raw `retargeted-character-animations.glb` file; it contains Godot's imported compiled scene cache. The 42 clips cannot be assumed to be directly importable into Unreal from this APK alone.

## Unreal migration path

1. Import the supplied base GLB into Unreal as a Skeletal Mesh. Confirm skeleton orientation, scale, root/hips behaviour, and the embedded clip.
2. Recover the original 42-clip source GLB from the previous authoring workspace if it still exists. Prefer that source over extracting from a compiled APK.
3. If the original retargeted GLB is unavailable, reacquire the animation source files and retarget them in Unreal using IK Rig and IK Retargeter. Build and validate a retarget pose before batch import.
4. Create a minimal Animation Blueprint with idle and locomotion blending only after the skeleton is verified.
5. Add swim and combat states later; they are not required for the first arena milestone.

## What is not yet verified

- The exact Unreal Engine minor version.
- Successful Unreal import of the GLB or EXR.
- The EXR licence and redistribution terms.
- Availability of the original 42-clip animation source.
- Whether the old Gobot shading setup has any transferable material textures or source files.
- A compiled Unreal build or installable APK.

## Binary asset handling

The supplied EXR and GLB are currently available as conversation uploads, but the text-only GitHub file operation used for source files cannot safely commit these binary assets. They should be added to the repository through a binary-capable Git/LFS workflow once the project workspace is available. Do not convert them to text or place large binary blobs into ordinary source files.

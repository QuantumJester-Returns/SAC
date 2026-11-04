# SAC Character Animation Plan — Unreal Engine 5

## Decision

The animation set in the previous Godot prototype was selected and prepared by an AI workflow, not supplied or chosen by the user. Do not ask the user to locate files they never downloaded.

The previous APK contains validation reports describing a 42-clip retargeted GLB, but the editable source GLB is not included as a normal source asset. Godot's imported .scn cache is not a reliable Unreal interchange format. Treat the old reports as evidence of the intended animation coverage, not as a recoverable production animation library.

## Character source

Use the supplied Male Base Mesh (T-Pose).glb as the starting character. It contains one skinned mesh, a 65-joint skeleton, and an embedded animation track. Import and inspect it in Unreal before making assumptions about bone orientation, root, scale, material slots, or retarget compatibility.

## Free-first animation acquisition

Find replacement animation clips from sources that explicitly permit the intended use. Verify the exact licence for each download before adding it to the project. Candidate sources may include:
- Mixamo animations, subject to Adobe's current terms and the exact intended use.
- Unreal Engine sample content and learning projects, subject to their applicable licence.
- Other free animation libraries only after checking redistribution and commercial-use rights.

Do not bulk-download an animation pack before verifying that its skeleton and licence suit SAC.

## First animation set

Prioritize:
1. Idle loop.
2. Walk loop.
3. Run/jog loop.
4. Jump start, loop, and landing.
5. Swim idle and swim forward.

Combat and interaction clips come later.

## Unreal retarget pipeline

1. Import the base character as a Skeletal Mesh.
2. Inspect the reference pose and hierarchy.
3. Create an IK Rig for the source skeleton and one for the SAC character.
4. Configure chains for spine, head, arms, and legs.
5. Create an IK Retargeter and align the retarget pose.
6. Test one idle and one locomotion clip before batch processing.
7. Check foot contact, root motion, shoulder deformation, wrists, hands, and scale.
8. Create an Animation Blueprint with idle/move blending.
9. Add jump and swim states after locomotion is stable.

## Acceptance criteria

- Feet do not slide excessively during planted phases.
- Hands and shoulders deform naturally.
- The pelvis and root do not drift unexpectedly.
- Loop boundaries are clean.
- Swimming clips have a suitable body orientation for the water gameplay.
- The same animation source can be reimported and retargeted reproducibly.

## Scope

Animation is not a blocker for Environment Milestone 01. Use the existing player capsule and camera to validate the arena while the character pipeline is prepared separately.

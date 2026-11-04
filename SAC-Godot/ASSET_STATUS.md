# Recovered asset and prototype status

| Asset / feature | Status |
|---|---|
| Original male base mesh GLB | Uploaded in this conversation and readable; binary not yet committed to Git |
| 4K sky EXR | Uploaded in this conversation and readable; binary not yet committed to Git |
| Original 42-clip retargeted animation library | Not required for the first prototype; intentionally deferred |
| Original interactive still-sea shader | Recovered from the v1.6.0 APK and committed |
| Still-sea ripple controller | Committed; not yet runtime-tested |
| New open-sky arena prototype | Committed in `scripts/arena_bootstrap.gd` |
| Landscape Android export preset | Committed |
| Clean Android build workflow | Committed; no successful workflow run or APK yet |

## Reference target
The supplied image is the visual target: vivid blue sky, high bright sun, distant clean horizon, deep blue reflective water, and two widely spaced fighters. The initial prototype approximates the environment with a procedural sky and directional light while the original EXR is waiting for binary integration.

## Player scale
Target height: 6.2 ft = 1.88976 m. The current plain capsule is a temporary scale and movement proxy.

## Deferred
The previous 42-animation library is deliberately not blocking the initial scene. It can be integrated later if the source becomes available and the character rig passes validation.

## Validation
No Godot executable is installed in the current container. Source commits are verified on the clean branch, but scene import, shader compilation, runtime behavior, and APK installation have not yet been verified. Never treat a workflow definition or source commit as a successful build.

# SAC Environment Preview Pipeline

This workflow uses Blender in background mode on a GitHub-hosted Ubuntu runner. No local PC or Blender installation is required from the project owner.

## Output
- `SAC_Environment_Preview.png`: rendered environment study.
- `SAC_Environment_Study.blend`: editable Blender scene.
- `SAC_Cloud_Field.obj`: consolidated cloud-field mesh for UE5 import.
- `SAC_Ocean_Surface.obj`: ocean surface geometry for UE5 import.

The workflow checks that both OBJ exports and the rendered PNG exist and are non-empty before uploading the artifact. The exports are geometry handoff assets; Unreal materials, collision, water interaction, and final scene assembly still need to be implemented in UE5.

## Visual target
The study follows the supplied reference: deep sapphire reflective ocean, bright high sun offset to the right, broad cloud banks near the horizon, smaller higher cloud clusters, and a low camera with a large foreground reflection area.

## Run
GitHub → Actions → **SAC Environment Preview** → Run workflow. Download the `SAC-Environment-Preview` artifact.

## Engine boundary
This workflow genuinely runs Blender and renders the scene. It does not compile Unreal Engine. UE5 is not preinstalled on standard GitHub-hosted runners; a licensed, provisioned UE5 runner is required for UE editor builds, level cooking, and packaged APKs. The project remains UE5-first while that runner requirement is investigated.

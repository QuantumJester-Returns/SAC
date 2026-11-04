# Recovered asset status

| Asset | Intended location | Status |
|---|---|---|
| Original male base mesh GLB | `assets/characters/` | Available in the ChatGPT Library; binary transfer into this Git branch is still pending |
| 42-clip retargeted animation GLB | `assets/animations/` | The original animation-library ZIP is not present in the accessible Library listing; the APK contains an imported Godot cache scene and QA reports |
| Interactive still-sea shader | `shaders/interactive_still_sea.gdshader` | **Recovered and committed** from the v1.6.0 APK |
| Still-sea ripple controller | `scripts/still_sea_controller.gd` | **Added**; awaits Godot 4.7.2 runtime validation and hookup to a water mesh |
| 4K sky source texture | `assets/environment/` | APK contains an imported texture cache; original editable source is not confirmed |
| Original arena scene | `scenes/` | APK contains packed scene data; clean editable reconstruction is required |

## Water behavior recovered

The original shader creates a radial travelling ripple from a world-space impact point. Its exported parameters control ripple origin, age, strength, speed, frequency, and width. The controller added in this branch exposes `trigger_water_reaction(world_position, strength)` and advances the ripple age.

## Binary asset transfer limitation

The original character GLB and v1.6.0 APK are available in the user's Library and were inspected. The GitHub write connection available for this task supports UTF-8 text files and Git blobs, but does not provide a binary upload or Git LFS upload action. The shader is text and has therefore been committed directly. The GLB and animation binary files have **not** been falsely marked as committed.

The project must not be described as playable until the model and animation assets are present and a Godot 4.7.2 import and runtime test succeeds.

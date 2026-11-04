# SAC — Layered Cloud Field Actor

## Purpose

`ASACCloudField` creates a repeatable, editable arrangement of cloud mesh instances around the arena. It is a layout and composition tool, not a volumetric cloud renderer.

The actor has three independent instance layers:

- **Near:** fewer, larger cloud forms that establish scale around the player.
- **Mid:** connected banks and shelves that shape the horizon.
- **Far:** a wider, denser, lower-contrast silhouette layer.

Each layer has its own mesh, count, horizontal extent, and base height. A fixed random seed makes the layout reproducible. Changing the seed produces a new arrangement.

## Source files

- `Source/SAC/SACCloudField.h`
- `Source/SAC/SACCloudField.cpp`

The actor uses Unreal `UInstancedStaticMeshComponent` components. Cloud instances have collision and navigation influence disabled.

## Editor setup

1. Compile the SAC C++ project in Unreal Editor.
2. Import the source OBJ meshes from `Content/SourceAssets/Clouds/` as Static Mesh assets.
3. Place one `ASACCloudField` actor in the arena level, with its origin at the intended sea-level composition centre.
4. Assign an imported cloud mesh to each of the Near, Mid, and Far mesh properties. Reusing a mesh is acceptable for the first layout pass, but use different silhouettes when available.
5. Adjust the three counts, extents, and heights while viewing the arena from the player camera.
6. Change Random Seed only when a different deterministic arrangement is wanted.

## Important scale note

Unreal uses centimetres by default. The initial extents are broad composition defaults, not measured final-world dimensions. Check the imported OBJ scale and cloud mesh pivots in Unreal before judging placement. If a mesh imports at an unexpected size, correct its import scale or source asset rather than compensating with extreme per-instance scales.

## Performance and visual limits

- Instancing reduces actor/component overhead; it does not make complex meshes free.
- Start with the default counts, then profile GPU cost, overdraw, shadow cost, and draw calls on the target Android device.
- The first pass uses static mesh clouds. It does not provide soft volumetric lighting, internal self-shadowing, or animated cloud motion.
- Avoid expensive cloud shadows on mobile until the base scene has been profiled.
- The actor does not create a waterline or guarantee that cloud meshes intersect the sea attractively. That is a level-composition task.

## Validation status

This is Unreal C++ source only. It has not been compiled in Unreal Editor or tested on Android. The GitHub source-validation workflow can check file presence and basic source contracts, but cannot replace an Unreal build.

# SAC Water Interaction — Unreal Engine 5

## Intended behaviour

The arena sea is calm and visually still when there is no interaction. It must not have permanently scrolling normal maps or ambient wave animation in the first milestone. A gameplay event creates a ripple at the impact location. The impulse controls the ripple's strength, width, and propagation speed.

The uploaded Godot prototype established the visual rule and used a single expanding ring. Its shader was useful as a behaviour reference, but it is not portable Unreal material code.

## C++ driver

`USACWaterRippleComponent` is the first Unreal-side implementation. Attach it to the water actor and assign the water mesh/material slot. Gameplay calls:

```cpp
WaterRippleComponent->ApplyImpact(ImpactWorldLocation, ImpactImpulse);
```

Impulse is expressed in newton-seconds (N*s). The component:
- Ignores impacts below the configured minimum.
- Normalizes impulse against `ImpulseForMaximumRipple`.
- Assigns up to four simultaneous ripple events.
- Reuses the oldest slot if all four are occupied.
- Updates material parameters only while at least one ripple is alive.
- Stops ticking when every ripple has expired.

The component does not generate a water material or a finished ocean surface by itself. It is the gameplay-to-material bridge.

## Required material parameters

Create a master water material and expose these parameters for each slot 0–3:

| Parameter | Type | Meaning |
|---|---|---|
| `SAC_RippleN_Origin` | Vector | World-space impact position (XYZ) |
| `SAC_RippleN_Age` | Scalar | Seconds since impact |
| `SAC_RippleN_Strength` | Scalar | Normalized impulse strength |
| `SAC_RippleN_Speed` | Scalar | Ring propagation speed, cm/s |
| `SAC_RippleN_Width` | Scalar | Ring envelope width, cm |

Use world position in centimetres. Compute radial distance on the water plane (world XY for a horizontal Unreal surface). For each active event, derive:

- Ring radius = age × speed.
- Ring distance = radial distance − ring radius.
- A narrow Gaussian envelope around the ring distance.
- A decaying amplitude multiplied by event strength.
- A radial normal perturbation or subtle vertex displacement.

Combine the four events additively but clamp the final perturbation to avoid unstable normals. The material should return to its unperturbed state when all strengths are zero.

## Visual and physical constraints

- No ripple or surface motion before an event.
- A light footstep should create a small, subtle ring.
- A heavy landing or large impact should create a broader, faster, more visible ring.
- Avoid a permanently repeating concentric texture; it reads as decoration rather than a physical response.
- Do not use metallic = 1 as a shortcut for reflections. Use the selected Unreal reflection method and tune dielectric water response.
- Test the surface from grazing and low camera angles, and inspect reflection stability near the horizon.

## Planned validation

1. No interaction: sea appears still.
2. Single light impact: small ripple, quick fade.
3. Single heavy impact: stronger, wider, faster ripple.
4. Two impacts close together: both rings remain visible.
5. Four or more impacts: event slots recycle without stale ripples.
6. Ripple expiry: material returns exactly to the calm baseline.

## Current limitation

The C++ component has not yet been compiled in Unreal Editor. The master material and its parameter graph still need to be created and validated in the selected Unreal Engine version. This source is a project foundation, not a verified packaged feature.

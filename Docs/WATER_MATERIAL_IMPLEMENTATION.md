# SAC Water Material — Implementation Specification 01

## Goal

Create a calm, reflective, deep-blue ocean surface. The undisturbed surface has no animated waves, scrolling normal maps, or procedural noise. A gameplay impact creates an expanding ring whose width, speed, and strength depend on the impulse.

This is a material implementation specification and source snippet. It is not a compiled Unreal `.uasset`.

## Create the material

Create a Material named `M_SAC_Water_Master` with these settings:

- Material Domain: Surface
- Blend Mode: Opaque
- Shading Model: Default Lit
- Two Sided: Off
- Tangent Space Normal: Off (the custom node returns a world-space normal)
- Use a dielectric water response; Metallic = 0

Suggested starting values, to be tuned in-engine rather than treated as final art direction:

| Input | Starting value |
|---|---:|
| Base Color | (0.018, 0.105, 0.19) |
| Metallic | 0 |
| Specular | 0.5 |
| Roughness | 0.04 |
| Calm Normal | (0, 0, 1) |

Do not set Metallic to 1 to imitate a mirror. Let the engine's supported reflection path provide the sky and environment reflection.

## Ripple normal custom node

Add a Custom material node named `SAC_RippleNormal`:

- Output Type: Float3
- Code: use the contents of `SAC_WaterRippleNormal.hlsl`.
- Connect Absolute World Position (excluding material offsets) to `WorldPosition`.
- Create Vector Parameter inputs `Origin0` through `Origin3`; connect the corresponding `SAC_RippleN_Origin` vector parameters.
- Create Scalar Parameter inputs `Age0` through `Age3`; connect `SAC_RippleN_Age`.
- Create Scalar Parameter inputs `Strength0` through `Strength3`; connect `SAC_RippleN_Strength`.
- Create Scalar Parameter inputs `Speed0` through `Speed3`; connect `SAC_RippleN_Speed`.
- Create Scalar Parameter inputs `Width0` through `Width3`; connect `SAC_RippleN_Width`.
- Connect the custom node output directly to the material Normal input.

All parameter names must match the C++ ripple component exactly. Keep all four slots connected, even if their strength is zero.

The source assumes a flat ocean surface in world XY with Z up. If the mesh is rotated, transform positions and normals into the water's local plane before using this calculation.

## Reflection and rendering

The material's smooth dielectric surface must reflect the sky and surrounding clouds through the reflection features supported by the active Unreal renderer. Validate the result in the target UE5 version and rendering configuration.

- PC visual baseline: test the renderer's supported high-quality reflection path and compare against a planar reflection only if the camera/scene needs it.
- Android: do not assume desktop Lumen or planar reflections are available or affordable. Establish a mobile-compatible fallback using supported reflection captures / skylight contribution and profile it on the actual device.
- Avoid adding a second bright HDR sky dome that competes with Sky Atmosphere.
- Test at grazing camera angles; the horizon is a key part of the visual target.

## Validation sequence

1. Set all ripple strengths to zero. The normal must remain exactly flat and the surface must not animate.
2. Trigger one small impulse. A subtle ring should expand and fade.
3. Trigger a large impulse. It should produce a wider, stronger, faster ring.
4. Trigger two impacts at different locations. Both should remain visible at once.
5. Trigger more than four impacts. The oldest active event should be recycled cleanly.
6. Wait for all events to expire. The surface must return to the exact calm baseline.
7. Inspect reflection stability at the horizon and from low angles.
8. Profile shader cost and reflection cost separately on PC and Android.

## Important limitations

- This implementation only perturbs the surface normal; it does not displace vertices or simulate fluid motion.
- It assumes a horizontal XY water plane.
- The material graph must be assembled and compiled in Unreal Editor.
- Reflection quality depends on the renderer, platform, and project settings.
- The HLSL snippet has not yet been compiled in a UE material graph. Validate Custom node syntax in the selected engine version before treating it as production-ready.

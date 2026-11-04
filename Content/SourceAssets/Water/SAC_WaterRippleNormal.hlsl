// SAC water ripple normal — Custom Material node body (Unreal Engine 5).
// Output type: Float3. Set the material's "Tangent Space Normal" option OFF.
// Inputs:
//   WorldPosition (Float3)
//   Origin0..Origin3 (Float4), Age0..Age3, Strength0..Strength3,
//   Speed0..Speed3, Width0..Width3 (all scalar except Origin).
//
// The water plane is horizontal in world XY with Z up.
// The component supplies world-space origins in centimetres.
// A zero Strength means the event contributes exactly zero slope.

float2 RippleSlope = float2(0.0, 0.0);
const float Frequency = 0.055;       // radians per centimetre
const float AmplitudeCm = 3.0;       // calm baseline remains perfectly flat

#define SAC_ACCUMULATE_RIPPLE(O, A, S, V, W)                         \
{                                                                    \
    const float SafeWidth = max((W), 1.0);                            \
    const float2 ToPoint = WorldPosition.xy - (O).xy;                \
    const float DistanceFromOrigin = length(ToPoint);                \
    const float RingRadius = (A) * (V);                               \
    const float RingOffset = DistanceFromOrigin - RingRadius;        \
    const float NormalizedOffset = RingOffset / SafeWidth;            \
    const float Envelope = exp(-NormalizedOffset * NormalizedOffset);\
    const float Phase = RingOffset * Frequency;                       \
    const float TimeFade = exp(-max((A), 0.0) * 0.85);                 \
    const float Derivative = (S) * AmplitudeCm * TimeFade * Envelope  \
        * (Frequency * cos(Phase)                                  \
        - (2.0 * RingOffset / (SafeWidth * SafeWidth)) * sin(Phase)); \
    const float2 Direction = ToPoint / max(DistanceFromOrigin, 1.0);   \
    RippleSlope += Direction * Derivative;                            \
}

SAC_ACCUMULATE_RIPPLE(Origin0, Age0, Strength0, Speed0, Width0)
SAC_ACCUMULATE_RIPPLE(Origin1, Age1, Strength1, Speed1, Width1)
SAC_ACCUMULATE_RIPPLE(Origin2, Age2, Strength2, Speed2, Width2)
SAC_ACCUMULATE_RIPPLE(Origin3, Age3, Strength3, Speed3, Width3)

#undef SAC_ACCUMULATE_RIPPLE

return normalize(float3(-RippleSlope.x, -RippleSlope.y, 1.0));

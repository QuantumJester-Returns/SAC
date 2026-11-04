#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "SACWaterRippleComponent.generated.h"

class UMeshComponent;
class UMaterialInstanceDynamic;

/**
 * Drives impact-triggered ripples on an Unreal water material.
 *
 * The material must expose the parameter names documented in
 * Docs/WATER_INTERACTION.md. No ripple is active until ApplyImpact is called.
 */
UCLASS(ClassGroup=(SAC), meta=(BlueprintSpawnableComponent))
class SAC_API USACWaterRippleComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    USACWaterRippleComponent();

    /** Mesh whose material slot receives the ripple parameters. */
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Water")
    TObjectPtr<UMeshComponent> WaterMesh = nullptr;

    /** Material slot used for the water surface. */
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Water", meta=(ClampMin="0"))
    int32 MaterialSlot = 0;

    /** Impact impulse, in N*s, that produces the maximum ripple strength. */
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Water", meta=(ClampMin="1.0"))
    float ImpulseForMaximumRipple = 1200.0f;

    /** Impacts below this impulse are ignored. */
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Water", meta=(ClampMin="0.0"))
    float MinimumImpulse = 8.0f;

    /** How long a ripple remains visible, in seconds. */
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Water", meta=(ClampMin="0.1"))
    float RippleLifetime = 3.5f;

    /** Add an impact at a world-space location. ImpulseMagnitude is measured in N*s. */
    UFUNCTION(BlueprintCallable, Category="SAC|Water")
    void ApplyImpact(FVector WorldLocation, float ImpulseMagnitude);

protected:
    virtual void OnRegister() override;
    virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

private:
    static constexpr int32 RippleSlotCount = 4;

    struct FRippleEvent
    {
        FVector Origin = FVector::ZeroVector;
        float Age = 0.0f;
        float Strength = 0.0f;
        float Speed = 0.0f;
        float Width = 0.0f;
        bool bActive = false;
    };

    UPROPERTY(Transient)
    TObjectPtr<UMaterialInstanceDynamic> DynamicWaterMaterial = nullptr;

    FRippleEvent RippleEvents[RippleSlotCount];

    void CreateDynamicMaterial();
    void PushRippleParameters();
};

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "SACEnvironmentController.generated.h"

class USceneComponent;
class USkyAtmosphereComponent;
class UDirectionalLightComponent;
class USkyLightComponent;
class UExponentialHeightFogComponent;

UCLASS()
class SAC_API ASACEnvironmentController : public AActor
{
    GENERATED_BODY()

public:
    ASACEnvironmentController();

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="SAC|Environment")
    TObjectPtr<USceneComponent> SceneRoot;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="SAC|Environment")
    TObjectPtr<USkyAtmosphereComponent> SkyAtmosphere;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="SAC|Environment")
    TObjectPtr<UDirectionalLightComponent> SunLight;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="SAC|Environment")
    TObjectPtr<USkyLightComponent> SkyLight;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="SAC|Environment")
    TObjectPtr<UExponentialHeightFogComponent> AtmosphericFog;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Environment|Sun")
    FRotator SunRotation = FRotator(-28.0f, -35.0f, 0.0f);

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Environment|Sun", meta=(ClampMin="0.0"))
    float SunIntensityLux = 100000.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Environment|Sky", meta=(ClampMin="0.0"))
    float SkyLightIntensity = 1.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Environment|Fog", meta=(ClampMin="0.0", ClampMax="0.1"))
    float FogDensity = 0.003f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Environment|Fog", meta=(ClampMin="0.0"))
    float FogHeightFalloff = 0.18f;

#if WITH_EDITOR
    virtual void OnConstruction(const FTransform& Transform) override;
#endif

private:
    void ApplyEnvironmentSettings();
};

#include "SACEnvironmentController.h"

#include "Components/SceneComponent.h"
#include "Components/SkyAtmosphereComponent.h"
#include "Components/DirectionalLightComponent.h"
#include "Components/SkyLightComponent.h"
#include "Components/ExponentialHeightFogComponent.h"

ASACEnvironmentController::ASACEnvironmentController()
{
    PrimaryActorTick.bCanEverTick = false;

    SceneRoot = CreateDefaultSubobject<USceneComponent>(TEXT("SceneRoot"));
    SetRootComponent(SceneRoot);

    SkyAtmosphere = CreateDefaultSubobject<USkyAtmosphereComponent>(TEXT("SkyAtmosphere"));
    SkyAtmosphere->SetupAttachment(SceneRoot);

    SunLight = CreateDefaultSubobject<UDirectionalLightComponent>(TEXT("SunLight"));
    SunLight->SetupAttachment(SceneRoot);
    SunLight->SetMobility(EComponentMobility::Movable);
    SunLight->bAtmosphereSunLight = true;
    SunLight->AtmosphereSunLightIndex = 0;

    SkyLight = CreateDefaultSubobject<USkyLightComponent>(TEXT("SkyLight"));
    SkyLight->SetupAttachment(SceneRoot);
    SkyLight->SetMobility(EComponentMobility::Movable);

    AtmosphericFog = CreateDefaultSubobject<UExponentialHeightFogComponent>(TEXT("AtmosphericFog"));
    AtmosphericFog->SetupAttachment(SceneRoot);

    ApplyEnvironmentSettings();
}

void ASACEnvironmentController::ApplyEnvironmentSettings()
{
    if (SunLight)
    {
        SunLight->SetRelativeRotation(SunRotation);
        SunLight->SetIntensity(SunIntensityLux);
        SunLight->SetLightColor(FLinearColor(1.0f, 0.91f, 0.78f));
    }

    if (SkyLight)
    {
        SkyLight->SetIntensity(SkyLightIntensity);
    }

    if (AtmosphericFog)
    {
        AtmosphericFog->SetFogDensity(FogDensity);
        AtmosphericFog->SetFogHeightFalloff(FogHeightFalloff);
    }
}

#if WITH_EDITOR
void ASACEnvironmentController::OnConstruction(const FTransform& Transform)
{
    Super::OnConstruction(Transform);
    ApplyEnvironmentSettings();
}
#endif

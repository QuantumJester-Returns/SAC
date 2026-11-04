#include "SACOceanSurface.h"

#include "Components/StaticMeshComponent.h"
#include "Materials/MaterialInterface.h"
#include "SACWaterRippleComponent.h"

ASACOceanSurface::ASACOceanSurface()
{
    PrimaryActorTick.bCanEverTick = false;

    SurfaceMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("OceanSurfaceMesh"));
    SetRootComponent(SurfaceMesh);

    SurfaceMesh->SetMobility(EComponentMobility::Static);
    SurfaceMesh->SetCollisionEnabled(ECollisionEnabled::NoCollision);

    RippleDriver = CreateDefaultSubobject<USACWaterRippleComponent>(TEXT("WaterRippleDriver"));
    RippleDriver->WaterMesh = SurfaceMesh;
}

void ASACOceanSurface::ConfigureSurface()
{
    if (!SurfaceMesh)
    {
        return;
    }

    if (SurfaceMeshAsset)
    {
        SurfaceMesh->SetStaticMesh(SurfaceMeshAsset);
    }

    if (WaterMaterial)
    {
        SurfaceMesh->SetMaterial(0, WaterMaterial);
    }

    if (bEnableCollision)
    {
        SurfaceMesh->SetCollisionProfileName(CollisionProfile);
        SurfaceMesh->SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
    }
    else
    {
        SurfaceMesh->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    }

    if (RippleDriver)
    {
        RippleDriver->WaterMesh = SurfaceMesh;
    }
}

void ASACOceanSurface::ApplyWaterImpact(FVector WorldLocation, float ImpulseMagnitude)
{
    if (RippleDriver)
    {
        RippleDriver->ApplyImpact(WorldLocation, ImpulseMagnitude);
    }
}

#if WITH_EDITOR
void ASACOceanSurface::OnConstruction(const FTransform& Transform)
{
    Super::OnConstruction(Transform);
    ConfigureSurface();
}
#endif

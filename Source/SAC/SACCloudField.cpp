#include "SACCloudField.h"

#include "Components/InstancedStaticMeshComponent.h"
#include "Components/SceneComponent.h"
#include "Engine/StaticMesh.h"

ASACCloudField::ASACCloudField()
{
    PrimaryActorTick.bCanEverTick = false;

    SceneRoot = CreateDefaultSubobject<USceneComponent>(TEXT("SceneRoot"));
    SetRootComponent(SceneRoot);

    NearCloudInstances = CreateDefaultSubobject<UInstancedStaticMeshComponent>(TEXT("NearCloudInstances"));
    NearCloudInstances->SetupAttachment(SceneRoot);
    NearCloudInstances->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    NearCloudInstances->SetCanEverAffectNavigation(false);

    MidCloudInstances = CreateDefaultSubobject<UInstancedStaticMeshComponent>(TEXT("MidCloudInstances"));
    MidCloudInstances->SetupAttachment(SceneRoot);
    MidCloudInstances->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    MidCloudInstances->SetCanEverAffectNavigation(false);

    FarCloudInstances = CreateDefaultSubobject<UInstancedStaticMeshComponent>(TEXT("FarCloudInstances"));
    FarCloudInstances->SetupAttachment(SceneRoot);
    FarCloudInstances->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    FarCloudInstances->SetCanEverAffectNavigation(false);
}

void ASACCloudField::RebuildCloudLayer(
    UInstancedStaticMeshComponent* InstanceComponent,
    UStaticMesh* Mesh,
    int32 InstanceCount,
    const FVector2D& FieldExtent,
    float BaseHeight,
    int32 LayerSeed)
{
    if (!InstanceComponent)
    {
        return;
    }

    InstanceComponent->ClearInstances();
    InstanceComponent->SetStaticMesh(Mesh);

    if (!Mesh || InstanceCount <= 0)
    {
        return;
    }

    FRandomStream Random(LayerSeed);
    const float SafeExtentX = FMath::Max(100.0f, FieldExtent.X);
    const float SafeExtentY = FMath::Max(100.0f, FieldExtent.Y);
    const float MinScale = FMath::Max(0.1f, 1.0f - ScaleVariation);
    const float MaxScale = FMath::Max(MinScale, 1.0f + ScaleVariation);

    for (int32 Index = 0; Index < InstanceCount; ++Index)
    {
        const FVector Location(
            Random.FRandRange(-SafeExtentX, SafeExtentX),
            Random.FRandRange(-SafeExtentY, SafeExtentY),
            BaseHeight + Random.FRandRange(-HeightJitter, HeightJitter));

        const FRotator Rotation(
            Random.FRandRange(-TiltVariationDegrees, TiltVariationDegrees),
            Random.FRandRange(0.0f, 360.0f),
            Random.FRandRange(-TiltVariationDegrees, TiltVariationDegrees));

        const float UniformScale = Random.FRandRange(MinScale, MaxScale);
        const FVector Scale(
            UniformScale * Random.FRandRange(0.88f, 1.12f),
            UniformScale * Random.FRandRange(0.88f, 1.12f),
            UniformScale * Random.FRandRange(0.88f, 1.12f));

        InstanceComponent->AddInstance(FTransform(Rotation, Location, Scale), false);
    }
}

void ASACCloudField::OnConstruction(const FTransform& Transform)
{
    Super::OnConstruction(Transform);

    RebuildCloudLayer(
        NearCloudInstances, NearCloudMesh, NearCloudCount,
        NearFieldExtent, NearBaseHeight, RandomSeed);

    RebuildCloudLayer(
        MidCloudInstances, MidCloudMesh, MidCloudCount,
        MidFieldExtent, MidBaseHeight, RandomSeed + 101);

    RebuildCloudLayer(
        FarCloudInstances, FarCloudMesh, FarCloudCount,
        FarFieldExtent, FarBaseHeight, RandomSeed + 211);
}

#include "SACWaterRippleComponent.h"

#include "Components/MeshComponent.h"
#include "Materials/MaterialInstanceDynamic.h"

USACWaterRippleComponent::USACWaterRippleComponent()
{
    PrimaryComponentTick.bCanEverTick = true;
    PrimaryComponentTick.bStartWithTickEnabled = false;
}

void USACWaterRippleComponent::OnRegister()
{
    Super::OnRegister();
    CreateDynamicMaterial();
}

void USACWaterRippleComponent::CreateDynamicMaterial()
{
    if (!WaterMesh && GetOwner())
    {
        TArray<UMeshComponent*> MeshComponents;
        GetOwner()->GetComponents<UMeshComponent>(MeshComponents);
        if (MeshComponents.Num() > 0)
        {
            WaterMesh = MeshComponents[0];
        }
    }

    if (!WaterMesh || MaterialSlot < 0 || MaterialSlot >= WaterMesh->GetNumMaterials())
    {
        DynamicWaterMaterial = nullptr;
        return;
    }

    DynamicWaterMaterial = Cast<UMaterialInstanceDynamic>(WaterMesh->GetMaterial(MaterialSlot));
    if (!DynamicWaterMaterial)
    {
        DynamicWaterMaterial = UMaterialInstanceDynamic::Create(WaterMesh->GetMaterial(MaterialSlot), this);
        if (DynamicWaterMaterial)
        {
            WaterMesh->SetMaterial(MaterialSlot, DynamicWaterMaterial);
        }
    }
}

void USACWaterRippleComponent::ApplyImpact(FVector WorldLocation, float ImpulseMagnitude)
{
    if (ImpulseMagnitude < MinimumImpulse || !FMath::IsFinite(ImpulseMagnitude))
    {
        return;
    }

    if (!DynamicWaterMaterial)
    {
        CreateDynamicMaterial();
    }
    if (!DynamicWaterMaterial)
    {
        return;
    }

    int32 TargetSlot = INDEX_NONE;
    float GreatestAge = -1.0f;

    for (int32 Index = 0; Index < RippleSlotCount; ++Index)
    {
        if (!RippleEvents[Index].bActive)
        {
            TargetSlot = Index;
            break;
        }
        if (RippleEvents[Index].Age > GreatestAge)
        {
            GreatestAge = RippleEvents[Index].Age;
            TargetSlot = Index;
        }
    }

    const float NormalizedStrength = FMath::Clamp(ImpulseMagnitude / FMath::Max(ImpulseForMaximumRipple, 1.0f), 0.05f, 1.0f);
    FRippleEvent& Event = RippleEvents[TargetSlot];
    Event.Origin = WorldLocation;
    Event.Age = 0.0f;
    Event.Strength = NormalizedStrength;
    Event.Speed = FMath::Lerp(180.0f, 650.0f, NormalizedStrength);
    Event.Width = FMath::Lerp(35.0f, 180.0f, NormalizedStrength);
    Event.bActive = true;

    PushRippleParameters();
    SetComponentTickEnabled(true);
}

void USACWaterRippleComponent::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction)
{
    Super::TickComponent(DeltaTime, TickType, ThisTickFunction);

    bool bAnyActive = false;
    for (FRippleEvent& Event : RippleEvents)
    {
        if (!Event.bActive)
        {
            continue;
        }

        Event.Age += DeltaTime;
        if (Event.Age >= RippleLifetime)
        {
            Event.bActive = false;
            Event.Strength = 0.0f;
        }
        else
        {
            bAnyActive = true;
        }
    }

    PushRippleParameters();
    if (!bAnyActive)
    {
        SetComponentTickEnabled(false);
    }
}

void USACWaterRippleComponent::PushRippleParameters()
{
    if (!DynamicWaterMaterial)
    {
        return;
    }

    for (int32 Index = 0; Index < RippleSlotCount; ++Index)
    {
        const FRippleEvent& Event = RippleEvents[Index];
        const FString Prefix = FString::Printf(TEXT("SAC_Ripple%d_"), Index);
        DynamicWaterMaterial->SetVectorParameterValue(
            FName(*(Prefix + TEXT("Origin"))),
            FLinearColor(Event.Origin.X, Event.Origin.Y, Event.Origin.Z, 1.0f));
        DynamicWaterMaterial->SetScalarParameterValue(FName(*(Prefix + TEXT("Age"))), Event.bActive ? Event.Age : RippleLifetime);
        DynamicWaterMaterial->SetScalarParameterValue(FName(*(Prefix + TEXT("Strength"))), Event.bActive ? Event.Strength : 0.0f);
        DynamicWaterMaterial->SetScalarParameterValue(FName(*(Prefix + TEXT("Speed"))), Event.Speed);
        DynamicWaterMaterial->SetScalarParameterValue(FName(*(Prefix + TEXT("Width"))), Event.Width);
    }
}

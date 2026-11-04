#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "SACOceanSurface.generated.h"

class UStaticMesh;
class UStaticMeshComponent;
class UMaterialInterface;
class USACWaterRippleComponent;

/**
 * Reusable ocean surface actor. Assign an imported ocean mesh and water
 * material in the editor; gameplay can forward impact impulses to its
 * ripple driver without depending on the material implementation.
 */
UCLASS()
class SAC_API ASACOceanSurface : public AActor
{
    GENERATED_BODY()

public:
    ASACOceanSurface();

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="SAC|Water")
    TObjectPtr<UStaticMeshComponent> SurfaceMesh;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="SAC|Water")
    TObjectPtr<USACWaterRippleComponent> RippleDriver;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Water|Setup")
    TObjectPtr<UStaticMesh> SurfaceMeshAsset = nullptr;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Water|Setup")
    TObjectPtr<UMaterialInterface> WaterMaterial = nullptr;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Water|Setup")
    bool bEnableCollision = false;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Water|Setup", meta=(EditCondition="bEnableCollision"))
    FName CollisionProfile = TEXT("BlockAll");

    /** Send an impact event to the water's ripple system. Impulse is N*s. */
    UFUNCTION(BlueprintCallable, Category="SAC|Water")
    void ApplyWaterImpact(FVector WorldLocation, float ImpulseMagnitude);

#if WITH_EDITOR
    virtual void OnConstruction(const FTransform& Transform) override;
#endif

private:
    void ConfigureSurface();
};

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "SACCloudField.generated.h"

class UInstancedStaticMeshComponent;
class UStaticMesh;

UCLASS()
class SAC_API ASACCloudField : public AActor
{
    GENERATED_BODY()

public:
    ASACCloudField();

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="SAC|Clouds")
    TObjectPtr<USceneComponent> SceneRoot;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="SAC|Clouds")
    TObjectPtr<UInstancedStaticMeshComponent> NearCloudInstances;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="SAC|Clouds")
    TObjectPtr<UInstancedStaticMeshComponent> MidCloudInstances;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="SAC|Clouds")
    TObjectPtr<UInstancedStaticMeshComponent> FarCloudInstances;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Meshes")
    TObjectPtr<UStaticMesh> NearCloudMesh;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Meshes")
    TObjectPtr<UStaticMesh> MidCloudMesh;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Meshes")
    TObjectPtr<UStaticMesh> FarCloudMesh;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Layout", meta=(ClampMin="1", ClampMax="256"))
    int32 NearCloudCount = 12;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Layout", meta=(ClampMin="1", ClampMax="256"))
    int32 MidCloudCount = 18;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Layout", meta=(ClampMin="1", ClampMax="256"))
    int32 FarCloudCount = 24;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Layout", meta=(ClampMin="100.0"))
    FVector2D NearFieldExtent = FVector2D(9000.0f, 9000.0f);

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Layout", meta=(ClampMin="100.0"))
    FVector2D MidFieldExtent = FVector2D(24000.0f, 24000.0f);

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Layout", meta=(ClampMin="100.0"))
    FVector2D FarFieldExtent = FVector2D(50000.0f, 50000.0f);

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Height")
    float NearBaseHeight = 250.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Height")
    float MidBaseHeight = 650.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Height")
    float FarBaseHeight = 1100.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Variation", meta=(ClampMin="0"))
    int32 RandomSeed = 1701;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Variation", meta=(ClampMin="0.0", ClampMax="1.0"))
    float ScaleVariation = 0.35f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Variation", meta=(ClampMin="0.0"))
    float HeightJitter = 180.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="SAC|Clouds|Variation", meta=(ClampMin="0.0", ClampMax="45.0"))
    float TiltVariationDegrees = 8.0f;

    virtual void OnConstruction(const FTransform& Transform) override;

private:
    void RebuildCloudLayer(
        UInstancedStaticMeshComponent* InstanceComponent,
        UStaticMesh* Mesh,
        int32 InstanceCount,
        const FVector2D& FieldExtent,
        float BaseHeight,
        int32 LayerSeed);
};

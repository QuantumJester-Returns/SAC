#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "SACPlayerCharacter.generated.h"

UCLASS()
class SAC_API ASACPlayerCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    ASACPlayerCharacter();

protected:
    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

private:
    void MoveForward(float Value);
    void MoveRight(float Value);
};

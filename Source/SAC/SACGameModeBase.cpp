#include "SACGameModeBase.h"
#include "SACPlayerCharacter.h"

ASACGameModeBase::ASACGameModeBase()
{
    DefaultPawnClass = ASACPlayerCharacter::StaticClass();
}

using UnrealBuildTool;
using System.Collections.Generic;

public class SACEditorTarget : TargetRules
{
    public SACEditorTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Editor;
        DefaultBuildSettings = BuildSettingsVersion.V5;
        IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
        ExtraModuleNames.Add("SAC");
    }
}

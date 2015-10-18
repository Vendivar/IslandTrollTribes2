------------------------------------------------
--               Global item applier          --
------------------------------------------------
function ApplyModifier( unit, modifier_name )
    GameRules.APPLIER:ApplyDataDrivenModifier(unit, unit, modifier_name, {})
end

------------------------------------------------

-- Unit Label for now
function GetHeroClass( hero )
    return hero:GetUnitLabel()
end

------------------------------------------------
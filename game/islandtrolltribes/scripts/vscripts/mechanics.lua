------------------------------------------------
--            Global item applier             --
------------------------------------------------
function ApplyModifier( unit, modifier_name )
    GameRules.APPLIER:ApplyDataDrivenModifier(unit, unit, modifier_name, {})
end

------------------------------------------------
--               Class functions              --
------------------------------------------------

-- Unit Label for now
function GetHeroClass( hero )
    return hero:GetUnitLabel()
end

------------------------------------------------
--              Ability functions             --
------------------------------------------------

function SetAbilityVisibility(unit, abilityName, visibility)
    local ability = unit:FindAbilityByName(abilityName)
    local hidden = (visibility == false)
    if ability ~= nil and unit ~= nil then
        ability:SetHidden(hidden)
    end
end

------------------------------------------------

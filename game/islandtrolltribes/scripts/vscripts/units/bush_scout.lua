function CheckReveal( event )
    local caster = event.caster
    local target = event.target

    if GetHeroClass(target) == "scout" then
        caster:RemoveModifierByName("modifier_bush_scout")
    end
end

function StopReveal( event )
    local caster = event.caster
    local ability = event.ability
    
    if not caster:HasModifier("modifier_bush_scout") then
        local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), il, 350, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, 0, 0, false)

        for k,v in pairs(units) do
            if GetHeroClass(v) == "scout" then
                return
            end
        end

        ability:ApplyDataDrivenModifier(caster, caster, "modifier_bush_scout", {})
    end    
end
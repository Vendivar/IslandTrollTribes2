function StormEarthFire(event)
    local caster    = event.caster
    local target    = event.target
    local dur       = event.duration
    local entangle  = CreateItem( "item_scroll_entangling", caster, caster)
    entangle:ApplyDataDrivenModifier( caster, target, "modifier_scroll_entanglingroots", {duration=dur})
    StoneThrow(event)
end

function StoneThrow(event)
    local caster = event.caster
    local target = event.target
    local abilityName = event.stone_throw
    local dummy = CreateUnitByName("dummy_caster_stormearthfire", caster:GetAbsOrigin() , false, caster, caster, caster:GetTeam())
    dummy:AddAbility(abilityName)
    local abilityStoneThrow = dummy:FindAbilityByName(abilityName)
    abilityStoneThrow:SetLevel(1)
    if abilityStoneThrow:IsFullyCastable() then
        Timers:CreateTimer(0.1, function()
            dummy:CastAbilityOnTarget(target,abilityStoneThrow, caster:GetPlayerID())
            return
        end)
        Timers:CreateTimer(1.0, function()
            dummy:ForceKill(true)
            return
        end)
    end
end

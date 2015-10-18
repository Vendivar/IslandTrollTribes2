function StormEarthFire(event)
    local caster    = event.caster
    local target    = event.target
    local dur       = event.duration

    local entangle  = CreateItem( "item_scroll_entangling", caster, caster)
    entangle:ApplyDataDrivenModifier( caster, target, "modifier_scroll_entanglingroots", {duration=dur})
    local ability = event.stone_throw
    local dummy = CreateUnitByName("dummy_caster_stormearthfire", caster:GetAbsOrigin() , false, caster, caster, caster:GetTeam())
    dummy:CastAbilityOnTarget(target, ability, caster:GetPlayerID())
    dummy:Kill()
end

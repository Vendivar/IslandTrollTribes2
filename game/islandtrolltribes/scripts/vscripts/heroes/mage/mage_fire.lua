-- Note: This isn't using the building system, should it?
function SpawnMageFire(keys)
    local caster = keys.caster
    local spawnPosition = caster:GetAbsOrigin() + (caster:GetForwardVector() * 150)

    local unit = CreateUnitByName("npc_building_fire_mage", spawnPosition, false, caster, caster, caster:GetTeam())

    unit:AddNewModifier(caster, nil, "modifier_kill", {duration = 30})
end
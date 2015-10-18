function SpawnMageFire(keys)
    local caster = keys.caster
    local spawnPosition = caster:GetAbsOrigin() + (caster:GetForwardVector() * 150)

    CreateUnitByName("npc_building_fire_mage",
                        spawnPosition,
                        false,
                        caster,
                        caster,
                        caster:GetTeam())
end
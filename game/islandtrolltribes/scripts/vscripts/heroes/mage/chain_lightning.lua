function ChainLightning(keys)
    local caster = keys.caster
    local target = keys.target
    local teamnumber = caster:GetTeamNumber()
    local bounces = keys.Bounces
    local radius = keys.BounceRadius
    local dmg = keys.Damage
    local dmgFactor = keys.BounceDamageFactor
    local hitUnits = {}

    -- hit initial target
    local damageTable = {victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL}
    ApplyDamage(damageTable)
    table.insert(hitUnits, target)
    local lightningBolt = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))

    for i=0,bounces do
        targetPosition = target:GetAbsOrigin()
        local units = FindUnitsInRadius(teamnumber,
                                    targetPosition,
                                    nil,
                                    radius,
                                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                                    DOTA_UNIT_TARGET_ALL,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)

        for _,unit in pairs(units) do
            if unit:IsAlive() then
                print("unit found")
                local alreadyHit = 0

                for j = 0, #hitUnits do
                    if hitUnits[j] == unit then
                        alreadyHit = 1
                    end
                end

                if alreadyHit == 0 then
                    local origin = target
                    target = unit
                    dmg = dmg*dmgFactor

                    local damageTable = {victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL}
                    ApplyDamage(damageTable)
                    table.insert(hitUnits, target)
                    lightningBolt = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, origin)
                    ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))
                    break
                end
            end
        end
    end
end


function HealingWave(keys)
    local caster = keys.caster
    local target = keys.target
    local teamnumber = caster:GetTeamNumber()
    local bounces = keys.Bounces
    local radius = keys.BounceRadius
    local healing = keys.Healing
    local healFactor = keys.BounceHealingFactor
    local healedUnits = {}

    -- heal initial target
    target:Heal(healing,caster)
    table.insert(healedUnits, target)
    local healingWave = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(healingWave,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))

    for i=0,bounces do
        targetPosition = target:GetAbsOrigin()
        local units = FindUnitsInRadius(teamnumber,
                                    targetPosition,
                                    nil,
                                    radius,
                                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                    DOTA_UNIT_TARGET_ALL,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)

        for _,unit in pairs(units) do
            if unit:IsAlive() then
                print("unit found")
                local alreadyHealed = 0

                for j = 0, #healedUnits do
                    if healedUnits[j] == unit then
                        alreadyHealed = 1
                    end
                end

                if alreadyHealed == 0 then
                    local origin = target
                    target = unit
                    healing = healing*healFactor
                    target:Heal(healing,caster)
                    table.insert(healedUnits, target)
                    lightningBolt = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, origin)
                    ParticleManager:SetParticleControl(healingWave,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))
                    break
                end
            end
        end
    end
end

function HealingWave(keys)
    local caster = keys.caster
    local targetPosition = keys.target_points[1]
    local teamnumber = caster:GetTeamNumber()
    local bounces = keys.Bounces
    local radius = keys.BounceRadius
    local healing = keys.Healing
    local healFactor = keys.BounceHealingFactor
    local healedUnits = {}
    -- heal initial target
    local healingWave = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(healingWave,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z+((caster:GetBoundingMaxs().z - caster:GetBoundingMins().z)/2)))
    ParticleManager:SetParticleControl(healingWave,1,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z+((caster:GetBoundingMaxs().z - caster:GetBoundingMins().z)/2)))
    local previousTarget = caster
    local numBounces = 0
    Timers:CreateTimer(function()
        print ("Hello. I'm running immediately and then every second thereafter.")

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
            if unit:IsAlive() and not caster then
                --print("unit found")
                local alreadyHealed = 0

                for j = 0, #healedUnits do
                    if healedUnits[j] == unit then
                        alreadyHealed = 1
                    end
                end

                if alreadyHealed == 0 then
                    local origin = targetPosition
                    local target = unit
                    healing = healing*healFactor
                    target:Heal(healing,caster)
                    table.insert(healedUnits, target)
                    healingWave = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
                    ParticleManager:SetParticleControl(healingWave,1,Vector(previousTarget:GetAbsOrigin().x,previousTarget:GetAbsOrigin().y,previousTarget:GetAbsOrigin().z+((previousTarget:GetBoundingMaxs().z - previousTarget:GetBoundingMins().z)/2)))
                    ParticleManager:SetParticleControl(healingWave,0,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))
                    --print("heal bounce")
                    previousTarget = target
                    if #healedUnits == #units then
                        healedUnits = {}
                    end
                    break
                end
            end
        end
        numBounces = numBounces + 1
        print("numBounces " .. numBounces)
        if numBounces >= bounces then
            return nil
        else
            return 0.2
        end
    end
    )
end
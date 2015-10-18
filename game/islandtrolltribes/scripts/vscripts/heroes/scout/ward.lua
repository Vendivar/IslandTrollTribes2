function EnemyRadar(keys)
    local caster = keys.caster
    local range = keys.Range
    local casterPosition = caster:GetAbsOrigin()
    local teamnumber = caster:GetTeamNumber()

    local units = FindUnitsInRadius(teamnumber,
                                casterPosition,
                                nil,
                                range,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_ALL,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_ANY_ORDER,
                                false)

    local redVal = 0
    local greenVal = 0
    local blueVal = 0

    for _, unit in pairs(units) do
        if unit:IsHero() then
            redVal = 255
        elseif unit:IsCreature() then
            blueVal = 255
        end

        local thisParticle = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, caster:GetOwner())
        ParticleManager:SetParticleControl(thisParticle, 0, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(thisParticle, 1, Vector(redVal, greenVal, blueVal))
        PingMap(caster:GetPlayerID(),unit:GetAbsOrigin(),redVal,greenVal,blueVal)
        ParticleManager:ReleaseParticleIndex(thisParticle)
        unit:EmitSound("General.Ping")   --may be deafening
    end
end
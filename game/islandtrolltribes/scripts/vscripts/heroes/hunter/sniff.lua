function SniffInit(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    if string.find(target:GetUnitName(), "corpse") then
    else
        SendErrorMessage(caster:GetPlayerOwnerID(),"#invalid_sniff_target")
        caster:Interrupt()
        ability:StartCooldown(1.0)
    end
end

function Sniff( event )
    local ability = event.ability

    local caster = event.caster
    local target = event.target
    local killer = target.killer

    if string.find(target:GetUnitName(), "corpse") then
        ability.elapsed = 0
        ability.tracker = CreateUnitByName("dummy_hunter_sniff", target:GetAbsOrigin(), true, caster, caster, 0)
        ability.sniffParticleTable = {}

        Timers:CreateTimer(0.1, function()
            ability.tracker:MoveToNPC(killer)
            SniffThink( event )
            return
        end)
    end
end

function SniffThink( event )
    local ability = event.ability
    local caster = event.caster

    local sniffDuration = event.SniffDuration
    local trailInterval = event.TrailInterval
    local footprintDuration = event.FootprintDuration

    Timers:CreateTimer(trailInterval, function()
        local tracker = ability.tracker
        local thisParticle = ParticleManager:CreateParticle(event.FootprintPfx, PATTACH_ABSORIGIN, tracker)
        ParticleManager:SetParticleControl(thisParticle, 0, tracker:GetAbsOrigin())
        ParticleManager:SetParticleControl(thisParticle, 15, Vector(139,69,19))
        table.insert(ability.sniffParticleTable, thisParticle)

        ability.elapsed = ability.elapsed + trailInterval
        if ability.elapsed >= footprintDuration then
            local particle = ability.sniffParticleTable[1]
            if particle ~= nil then
                ParticleManager:DestroyParticle( particle, false )
                ParticleManager:ReleaseParticleIndex( particle )
                table.remove( ability.sniffParticleTable, 1 )
            end
        end
        if ability.elapsed <= sniffDuration then
            SniffThink( event )
        else
            tracker:ForceKill(true)
        end
        return
    end)
end

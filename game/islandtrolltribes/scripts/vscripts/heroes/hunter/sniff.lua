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
    else
        caster:GiveMana(event.mana_cost)
        ability:EndCooldown()
    end
end

function SniffThink( event )
    local ability = event.ability
    local caster = event.caster

    local sniffDuration = event.sniff_duration
    local trailInterval = event.trail_interval
    local footprintDuration = event.footprint_duration

    Timers:CreateTimer(trailInterval, function()
        tracker = ability.tracker
        
        thisParticle = ParticleManager:CreateParticle(event.footprint_pfx, PATTACH_ABSORIGIN, tracker)
        ParticleManager:SetParticleControl(thisParticle, 0, tracker:GetAbsOrigin())
        ParticleManager:SetParticleControl(thisParticle, 15, Vector(139,69,19))
        table.insert(ability.sniffParticleTable, thisParticle)

        ability.elapsed = ability.elapsed + trailInterval
        if ability.elapsed >= footprintDuration then
            particle = ability.sniffParticleTable[1]
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

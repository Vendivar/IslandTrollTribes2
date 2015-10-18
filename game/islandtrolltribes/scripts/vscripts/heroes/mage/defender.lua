function DefenderEnergyOnSpellStart(event)
    local ability   =   event.ability
    ability.cast_origin = event.target_points[1]
end

function DefenderEnergyCast(event)
    local caster    =   event.caster
    local ability   =   event.ability

    ability.defender_startTime          =   GameRules:GetGameTime()
    ability.defender_count              =   0
    ability.defender_defendersSpawned   =   {}
    caster.defender_radius              =   event.radius
end

function DefenderEnergyThink(event)
    local caster    =   event.caster
    local ability   =   event.ability

    local numDefendersMax   =   event.num_defenders
    local castOrigin        =   ability.cast_origin
    
    local elapsedTime       =   GameRules:GetGameTime() - ability.defender_startTime

    local idealNumDefendersSpawned = elapsedTime / event.summon_interval
    idealNumDefendersSpawned = math.min( idealNumDefendersSpawned, numDefendersMax)

    if ability.defender_count < idealNumDefendersSpawned then
        local newDefender = CreateUnitByName( "npc_mage_defender", castOrigin, false, caster, caster, caster:GetTeam())

        local pfx = ParticleManager:CreateParticle( event.defender_particle, PATTACH_ABSORIGIN_FOLLOW, newDefender )
        newDefender.defender_pfx = pfx

        local defenderIndex = ability.defender_count + 1
        newDefender.defender_index = defenderIndex
        ability.defender_count = defenderIndex
        ability.defender_defendersSpawned[defenderIndex] = newDefender

        ability:ApplyDataDrivenModifier( caster, newDefender, event.defender_modifier, {duration = -1} )
    end

    local currentRadius = caster.defender_radius

    local currentRotationAngle  =   elapsedTime * event.turn_rate
    local rotationAngleOffset   =   360 / event.num_defenders

    local numDefendersAlive     =   0
    
    for k, v in pairs( ability.defender_defendersSpawned ) do

        numDefendersAlive = numDefendersAlive + 1

        local rotationAngle = currentRotationAngle - rotationAngleOffset * (k - 1)
        local relPos = Vector( 0, currentRadius, 0 )
        relPos = RotatePosition( Vector( 0, 0, 0 ), QAngle( 0, -rotationAngle, 0 ), relPos )
        local absPos = GetGroundPosition( relPos + castOrigin, v )

        v:SetAbsOrigin( absPos )

        ParticleManager:SetParticleControl( v.defender_pfx, 1, Vector( currentRadius, 0, 0 ) )

    end

    if ability.defender_count == numDefendersMax and numDefendersAlive == 0 then
        caster:RemoveModifierByName( event.caster_modifier )
    end

end

function DefenderEnergyEnd(event)

    local caster    = event.caster
    local ability   = event.ability

    local defenderModifier    = event.defender_modifier

    for k,v in pairs( ability.defender_defendersSpawned ) do
        v:RemoveModifierByName( defenderModifier )
        v:Destroy()
    end
end
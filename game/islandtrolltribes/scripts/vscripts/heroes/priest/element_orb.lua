--Based on pucks orb. 
function CastAngelicElementalOrb( keys )
    
    local caster    = keys.caster
    local ability   = keys.ability
    local point     = keys.target_points[1]

    local radius            = keys.radius
    local maxDist           = keys.max_distance
    local orbSpeed          = keys.orb_speed
    local visionRadius      = keys.orb_vision
    local visionDuration    = keys.vision_duration
    local numExtraVisions   = keys.num_extra_visions

    local travelDuration    = maxDist / orbSpeed
    local extraVisionInterval = travelDuration / numExtraVisions

    local casterOrigin      = caster:GetAbsOrigin()
    local targetDirection   = ( ( point - casterOrigin ) * Vector(1,1,0) ):Normalized()
    local projVelocity      = targetDirection * orbSpeed

    local startTime     = GameRules:GetGameTime()
    local endTime       = startTime + travelDuration

    local numExtraVisionsCreated = 0
    local isKilled      = false

    -- Create linear projectile
    local projID = ProjectileManager:CreateLinearProjectile( {
        Ability             = ability,
        EffectName          = keys.proj_particle,
        vSpawnOrigin        = casterOrigin,
        fDistance           = maxDist,
        fStartRadius        = radius,
        fEndRadius          = radius,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = endTime,
        bDeleteOnHit        = false,
        vVelocity           = projVelocity,
        bProvidesVision     = true,
        iVisionRadius       = visionRadius,
        iVisionTeamNumber   = caster:GetTeamNumber(),
    } )

    --print("projID = " .. projID)

    -- Create sound source
    local thinker = CreateUnitByName( "npc_dota_thinker", casterOrigin, false, caster, caster, caster:GetTeamNumber() )
    ability:ApplyDataDrivenModifier( caster, thinker, keys.proj_modifier, { duration = -1 } )

    --
    -- Track the projectile
    --
    Timers:CreateTimer( function ( )
        
        local elapsedTime   = GameRules:GetGameTime() - startTime
        local currentOrbPosition = casterOrigin + projVelocity * elapsedTime
        currentOrbPosition = GetGroundPosition( currentOrbPosition, thinker )

        -- Update position of the sound source
        thinker:SetAbsOrigin( currentOrbPosition )

        -- Try to create new extra vision
        if elapsedTime > extraVisionInterval * (numExtraVisionsCreated + 1) then
            ability:CreateVisibilityNode( currentOrbPosition, visionRadius, visionDuration )
            numExtraVisionsCreated = numExtraVisionsCreated + 1
        end

        -- Remove if the projectile has expired
        if elapsedTime >= travelDuration or isKilled then
            thinker:RemoveModifierByName( keys.proj_modifier )

            return nil
        end

        return 0.03

    end )

end

function StopSound( keys )
    StopSoundEvent( keys.sound_name, keys.target ) 
end
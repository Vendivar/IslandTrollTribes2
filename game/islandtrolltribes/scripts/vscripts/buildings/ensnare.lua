function CastTrap( event )
    local ability = event.ability
    local caster = event.caster
    local target = event.target_entities and event.target_entities[1]

    if target and ability:GetAutoCastState() and ability:IsFullyCastable() then
        -- Cast ability on target
        caster:CastAbilityOnTarget(target, ability, -1)
    end
end

function CreateTrollDummy(event)
    local caster = event.caster
    Timers:CreateTimer(0.1, function()
        local pos = caster:GetAbsOrigin()
        caster.troll_dummy = CreateUnitByName("tower_ensnare_dummy", pos, false, caster, caster, caster:GetTeamNumber())
        caster.troll_dummy:SetNeverMoveToClearSpace(true)
        caster.troll_dummy:StartGesture(ACT_DOTA_IDLE)
    end)
end

function TrollDummyAttack(event)
    local caster = event.caster
    if IsValidEntity(caster.troll_dummy) then
        caster.troll_dummy:StartGesture(ACT_DOTA_ATTACK)
    end
end

function AnimateTrollDummy(event)
    local caster = event.caster
    local target = event.target
    if IsValidEntity(caster.troll_dummy) then

        local towardsTarget = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
        caster.troll_dummy:SetForwardVector(towardsTarget)

        caster.troll_dummy:StartGesture(ACT_DOTA_CAST_ABILITY_1)
    end
end

function RemoveTrollDummy(event)
    local caster = event.caster
    if IsValidEntity(caster.troll_dummy) then
        UTIL_Remove(caster.troll_dummy)
    end
end
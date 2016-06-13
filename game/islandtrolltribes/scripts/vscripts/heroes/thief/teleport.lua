function Teleport(event)
    local caster = event.caster
    local ability = event.ability
    local point = event.target_points[1]

    FindClearSpaceForUnit(caster, point, false)
end

function CheckTeleport( event )
    local caster = event.caster
    local ability = event.ability
    local point = event.target_points[1]

    --[[local dummyTarget = CreateUnitByName("dummy_caster", point, false, nil, nil, DOTA_TEAM_NEUTRALS)
    local visible = caster:CanEntityBeSeenByMyTeam(dummyTarget)

    if visible then
        dummyTarget:RemoveSelf()
    else
        caster:Interrupt()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#error_cant_teleport_without_vision")
    end]]
end
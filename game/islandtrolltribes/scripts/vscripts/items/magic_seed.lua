function CheckPosition( event )
    local caster = event.caster
    local point = event.target_points[1]

    if not BuildingHelper:ValidPosition(2, point, event) then
        caster:Interrupt()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#error_invalid_build_position")
    end
end

function MakeTree( event )
    local caster = event.caster
    local point = event.target_points[1]

    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_furion/furion_sprout.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl( particle, 0, point )
    ParticleManager:SetParticleControl( particle, 1, Vector( 0.0, 64, 0.0 ) )

    CreateTempTree( point, 9999 )
    ResolveNPCPositions( point, 64.0 )

    -- Need to spawn PSO because temp trees dont block the gridnav for BH
    local ent = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = point})
    local trees = GridNav:GetAllTreesAroundPoint(point, 0, false)
    local tree = trees[1]
    tree.blocker = ent

    -- Temp trees also don't trigger a tree_cut event so we have to listen in place
    Timers:CreateTimer(1,function()
        if #GridNav:GetAllTreesAroundPoint(point, 0, false) == 0 then
            DoEntFireByInstanceHandle(tree.blocker, "Disable", "1", 0, nil, nil)
            DoEntFireByInstanceHandle(tree.blocker, "Kill", "1", 1, nil, nil)
            return
        else
            return 1
        end
    end)
end
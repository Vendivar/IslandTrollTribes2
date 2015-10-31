--[[Pings the items in parameter ItemTable with their corresponding color]]
function PingItemInRange(keys)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local team = caster:GetTeamNumber()
    local range = ability:GetCastRange()
    local itemColorTable = GameRules.ItemInfo["PingColors"]

    local itemDrops = Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetAbsOrigin(), range)
    print(#itemDrops,"in",range)
    for k,drop in pairs(itemDrops) do
        local item = drop:GetContainedItem()
        if not item then print("ERROR: Drop doesnt contain an item") return end

        local itemName = item:GetAbilityName()
        if itemname ~= "item_meat_raw" then

            -- Get item color from table, else default white
            local itemColor = itemColorTable[itemName]
            if not itemColor then
                itemColor = "255 255 255"
            end
            
            -- Iterate over item color string and parse into specific values
            local color = split(itemColor)
            local r = tonumber(color[1])
            local g = tonumber(color[2])
            local b = tonumber(color[3])
                 
            -- Ping World Particle, 3 second duration
            local position = drop:GetAbsOrigin()
            local pingParticle = ParticleManager:CreateParticleForTeam("particles/custom/ping_world.vpcf", PATTACH_ABSORIGIN, caster, team)
            ParticleManager:SetParticleControl(pingParticle, 0, position)
            ParticleManager:SetParticleControl(pingParticle, 1, Vector(r, g, b))

            -- Static particle on the world, 5 second duration through fog
            local pingStaticParticle1 = ParticleManager:CreateParticleForTeam("particles/custom/ping_static.vpcf", PATTACH_ABSORIGIN, caster, team)
            ParticleManager:SetParticleControl(pingStaticParticle1, 0, position)
            ParticleManager:SetParticleControl(pingStaticParticle1, 1, Vector(r, g, b))
            Timers:CreateTimer(5, function() ParticleManager:DestroyParticle(pingStaticParticle1, true) end)

            -- Static particle attached to the item drop, removed after the item is picked up
            local pingStaticParticle2 = ParticleManager:CreateParticleForTeam("particles/custom/ping_static.vpcf", PATTACH_ABSORIGIN_FOLLOW, drop, team)
            ParticleManager:SetParticleControl(pingStaticParticle2, 0, position)
            ParticleManager:SetParticleControl(pingStaticParticle2, 1, Vector(r, g, b))

            item:EmitSound("General.Ping")  --may be deafening

            --Ping Minimap
            GameRules:AddMinimapDebugPointForTeam( -drop:entindex(), drop:GetAbsOrigin(), r, g, b, 400, 100, team )
        end
    end
end
--[[Pings the items in parameter ItemTable with their corresponding color]]
function PingItemInRange(event)
    local caster = event.caster
    local ability = event.ability
    local playerID = caster:GetPlayerID()
    local team = caster:GetTeamNumber()
    local range = ability:GetCastRange()
    local itemColorTable = GameRules.ItemInfo["PingColors"]
    
    -- Handle specific item pings
    local items = event.Items
    local itemList
    if items then
        itemList = {}
        items = split(items, ",")
        for k,itemName in pairs(items) do
            itemList[itemName] = ""
        end
    end


    local itemDrops = Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetAbsOrigin(), range)
    for k,drop in pairs(itemDrops) do
        local item = drop:GetContainedItem()
        if not item then print("ERROR: Drop doesnt contain an item") return end

        local itemName = item:GetAbilityName()
        if itemname ~= "item_meat_raw" and (not itemList or itemList[itemName]) then

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

            -- Static particle on the drop, 25 second duration through fog or when the item gets picked up
            if drop.pingStaticParticle then ParticleManager:DestroyParticle(drop.pingStaticParticle, true) end --Remove the old particle instance

            drop.pingStaticParticle = ParticleManager:CreateParticleForTeam("particles/custom/ping_static.vpcf", PATTACH_ABSORIGIN, caster, team)
            ParticleManager:SetParticleControl(drop.pingStaticParticle, 0, position)
            ParticleManager:SetParticleControl(drop.pingStaticParticle, 1, Vector(r, g, b))
            Timers:CreateTimer(25, function()
                if IsValidEntity(drop) then
                    ParticleManager:DestroyParticle(drop.pingStaticParticle, true)
                    drop.pingStaticParticle = nil
                end
            end)

            item:EmitSound("General.Ping")  --may be deafening

            --Ping Minimap
            local radius = 400
            GameRules:AddMinimapDebugPointForTeam( -drop:entindex(), drop:GetAbsOrigin(), r, g, b, radius, 100, team )
        end
    end
end
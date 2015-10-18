--[[Pings the items in parameter ItemTable with their corresponding color]]
function PingItemInRange(keys)
    --PrintTable(keys)
    local caster = keys.caster
    local id = caster:GetPlayerID()
    local team = caster:GetTeamNumber()
    local range = keys.Range
    local itemTable = keys.ItemTable

    --PingMap(caster:GetPlayerID(),caster:GetOrigin(),1,1,1)
    --code above for checking your position.
    print("caster info", caster:GetTeam(), caster:GetOrigin(),range)
    for _,item in pairs( Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetOrigin(), range)) do
        local containedItem = item:GetContainedItem()

        -- Get item color from table, else default white
        local itemColor = itemTable[containedItem:GetAbilityName()]
        if (itemColor == nil) then
            itemColor = "255 255 255"
        end
        -- TODO: ignore raw meat since it is now an item.
        
        -- Iterate over item color string and parse into specific values
        local stringParse = string.gmatch(itemColor, "%d+")
        --need to divide by 255 to convert to 0-1 scale
        local redVal = tonumber(stringParse())/255
        local greenVal = tonumber(stringParse())/255
        local blueVal = tonumber(stringParse())/255
 
        print("pinging", containedItem:GetAbilityName(), "at", item:GetAbsOrigin().x, item:GetAbsOrigin().y, item:GetAbsOrigin().z)
        --maybe use CreateParticleForPlayer(string particleName, int particleAttach, handle owningEntity, handle owningPlayer)
        local thisParticle = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, item)
        ParticleManager:SetParticleControl(thisParticle, 0, item:GetAbsOrigin())
        ParticleManager:SetParticleControl(thisParticle, 1, Vector(redVal, greenVal, blueVal))
        print(containedItem:GetAbilityName(), redVal, greenVal, blueVal)
        ParticleManager:ReleaseParticleIndex(thisParticle)
        item:EmitSound("General.Ping")   --may be deafening
        print("ping color: ", itemColor)
        --Ping Minimap
        --MinimapEvent( team, caster, item:GetAbsOrigin().x, item:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 3 )
        GameRules:AddMinimapDebugPointForTeam(id,item:GetAbsOrigin(), redVal*255, greenVal*255, blueVal*255, 500, 3, team)
    end
end
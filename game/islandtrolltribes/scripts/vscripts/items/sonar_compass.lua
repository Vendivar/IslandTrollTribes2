function SonarCompassUse(keys)
	local caster = keys.caster
    local unitTable = keys.UnitTable
    print("SonarCompassUse")
    PrintTable(unitTable)
    local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                      Vector(0, 0, 0),
                      nil,
                      FIND_UNITS_EVERYWHERE,
                      DOTA_UNIT_TARGET_TEAM_BOTH,
                      DOTA_UNIT_TARGET_ALL,
                      DOTA_UNIT_TARGET_FLAG_NONE,
                      FIND_ANY_ORDER,
                      false)
    for _,unit in pairs(units) do
    	for unitName,unitColor in pairs(unitTable) do
    		if unitName == unit:GetUnitName() then
	    		if unitColor == nil then
		            unitColor = "255 255 255"
		        end
		        local stringParse = string.gmatch(unitColor, "%d+")
		    
		        --need to divide by 255 to convert to 0-1 scale
		        local redVal = tonumber(stringParse())/255
		        local greenVal = tonumber(stringParse())/255
		        local blueVal = tonumber(stringParse())/255

		        print("pinging", unit:GetUnitName(), "at", unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, unit:GetAbsOrigin().z)
                --maybe use CreateParticleForPlayer(string particleName, int particleAttach, handle owningEntity, handle owningPlayer)
                local thisParticle = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, unit)
                ParticleManager:SetParticleControl(thisParticle, 0, unit:GetAbsOrigin())
                ParticleManager:SetParticleControl(thisParticle, 1, Vector(redVal, greenVal, blueVal))
                print(itemName, redVal, greenVal, blueVal)
                ParticleManager:ReleaseParticleIndex(thisParticle)
                unit:EmitSound("General.Ping")   --may be deafening
    		end
    	end
	end
end
--Omnicure purges all units in a radius around the caster. 
--NOTE: will appear not to function due to debuffs acting strangely
function Omnicure(keys)
    local caster = keys.caster
    local radius = keys.Radius
    local teamnumber = caster:GetTeamNumber()

    targetPosition = caster:GetAbsOrigin()
    local units = FindUnitsInRadius(teamnumber, targetPosition, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,unit in pairs(units) do

            print("unit found")
            unit:RemoveModifierByName("modifier_lizard_slow")
            unit:RemoveModifierByName("modifier_disease1")
            unit:RemoveModifierByName("modifier_disease2")
            unit:RemoveModifierByName("modifier_disease3")
    end
    
end
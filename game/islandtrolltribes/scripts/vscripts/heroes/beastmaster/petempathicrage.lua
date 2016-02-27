function StartEmpathicRage(keys)
    local empathicRageInfo = {}
    empathicRageInfo.pet = keys.caster
    empathicRageInfo.range = keys.Range
    empathicRageInfo.ability = keys.ability
    empathicRageInfo.duration = keys.Duration
    Timers:CreateTimer(DoUniqueString("pet_empathic_rage"),{callback=DeathCheck},empathicRageInfo)
end

function DeathCheck(empathicRageInfo)
    local pet = empathicRageInfo.pet
    local range = empathicRageInfo.range
    local ability = empathicRageInfo.ability
    local duration = empathicRageInfo.duration
    if not pet:IsAlive() then
        local targetPosition = pet:GetAbsOrigin()
        local heroes = FindUnitsInRadius (pet:GetTeamNumber(),
            targetPosition,
            nil,
            range,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )
        for _,hero in pairs(heroes) do
            if hero:GetEntityIndex() == pet:GetOwner():GetEntityIndex() and hero:HasModifier("modifier_empathicrage") then
--                print("Owner ID :"..hero:GetEntityIndex())
                ability:ApplyDataDrivenModifier(pet,hero,"modifer_empathicrage_buff",{duration = duration})
            end
        end
        return nil
    end
    return 1.0
end
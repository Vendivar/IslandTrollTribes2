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
                -- print("pet death check Owner ID :"..hero:GetEntityIndex())
                -- ability:ApplyDataDrivenModifier(pet,hero,"modifier_empathicrage_buff",{duration = duration})
                --check number of stacks
                local curStacks = hero:GetModifierStackCount("modifier_empathicrage_buff", nil)
                if hero:HasModifier("modifier_empathicrage_buff") then
                    print("adding stack")
                    hero:SetModifierStackCount("modifier_empathicrage_buff", nil, curStacks + 1)
                else
                    print("applying empathic rage")
                    ability:ApplyDataDrivenModifier(pet, hero, "modifier_empathicrage_buff", {duration = duration})
                    hero:SetModifierStackCount("modifier_empathicrage_buff", nil, curStacks + 1)
                end
            end
        end
        return nil
    end
    return 1.0
end

function TargetEnemies(keys)
    local caster = keys.caster
    local ability = keys.ability
    local casterPosition = caster:GetAbsOrigin()
    local teamnumber = caster:GetTeamNumber()
    local item
    for i=0,5 do
        item = caster:GetItemInSlot(i)
        if item and item:GetAbilityName() ~= "item_slot_locked" and ability:IsCooldownReady() then
    
        item:SetCurrentCharges(item:GetCurrentCharges() - 1)
            local units = FindUnitsInRadius(teamnumber, casterPosition, nil, item:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
            if #units > 0 then
                local target = units[RandomInt(1,#units)]
                Timers:CreateTimer(0.1, function()
                    caster:CastAbilityOnTarget(target, caster:GetItemInSlot(0), -1)
                    ability:StartCooldown(2.0)
                    end)
                    return
                --caster:CastAbilityOnTarget(target, item, -1)
            end
        end
    end
end


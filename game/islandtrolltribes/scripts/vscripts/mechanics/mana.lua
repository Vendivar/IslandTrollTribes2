function RestoreMana(keys)
    local target = keys.target
    local manaGain = keys.ManaRestored
    if not target then
        target = keys.caster
    end

    target:GiveMana(manaGain)
    PopupMana(target, manaGain)
end

function RemoveMana(keys)
    local target = keys.target
    local ability = keys.ability
    local manaloss = keys.ManaRemoved
    if not target then
        target = keys.caster
    end

    local mana = target:GetMana()
    target:SpendMana(manaloss, ability)
    PopupMana(target, -manaloss)
end

function RestAndRestoreMana(keys)
    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability
    local rest_duration = ability:GetSpecialValueFor("rest_duration")
    local rested_duration = ability:GetSpecialValueFor("rested_duration")
    local invulnerable_duration = ability:GetSpecialValueFor("invuln_duration")
    if not target:HasModifier("modifier_rested") then
        ability:ApplyDataDrivenModifier(caster,target,"modifier_sleep",{duration = rest_duration})
        ability:ApplyDataDrivenModifier(caster,target,"modifier_rested",{duration = rested_duration})
        RestoreMana(keys)
    else
        local playerID = target:GetPlayerID()
        if playerID then
            SendErrorMessage(playerID, "#error_already_rested")
        end
    end
end
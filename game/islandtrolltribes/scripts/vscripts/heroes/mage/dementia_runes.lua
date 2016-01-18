function RunesTelegatherInit(keys)
    local caster = keys.caster
    local target = keys.target

    keys.caster.targetFire = target

end

-- ItemRunes, RunesManip
-- ToggleOn RunesManip:         ItemRunes, RunesManip, Ability1, 2, 3, 4.
function ToggleOnRunes( event )
    local caster = event.caster
    local ability = event.ability
    local level = ability:GetLevel()

    -- Toggle off the secondary subclass ability

    local RunesSkillTable = {
        [1] = {"ability_mage_karune", "ability_mage_lezrune", "ability_mage_nelrune"},
    }

    local abilityTable = RunesSkillTable[level]
    local currentSlot = 3

    for k,abilityName in pairs(abilityTable) do
        local swapAbility = GetAbilityOnVisibleSlot(caster, currentSlot)

        -- If there is already an ability on slot 4~6, swap it
        if swapAbility then
            caster:SwapAbilities(swapAbility:GetAbilityName(), abilityName, false, true)
        end

        -- All the _find abilities should already be added as hidden on the gatherer skill list
        local ability = caster:FindAbilityByName(abilityName)
        if ability then
            ability:SetHidden(false)
            ability:SetLevel(1)
            currentSlot = currentSlot+1
        end
    end

    AdjustAbilityLayout(caster)
end

-- Turns the layout back to normal
function ToggleOffRunes( event )
    local caster = event.caster
    
    local abilityTable = {
        ["ability_mage_karune"]="",
        ["ability_mage_lezrune"]="",
        ["ability_mage_nelrune"]="",
    }

    for i=0,15 do
        local ability = caster:GetAbilityByIndex(i)
        if ability then
            local abilityName = ability:GetAbilityName()
            if abilityTable[abilityName] then
                ability:SetHidden(true)
                ability:SetLevel(0)
            elseif ability:GetLevel() > 0 and not IsCastableWhileHidden(abilityName) then
                ability:SetHidden(false)
            end
        end        
    end
end

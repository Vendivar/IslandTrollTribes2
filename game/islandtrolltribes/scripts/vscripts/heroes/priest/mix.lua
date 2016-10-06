
function MixInit(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    if string.find(target:GetUnitName(), "npc_dota_hero_dazzle") then
        SendErrorMessage(caster:GetPlayerOwnerID(),"#invalid_priest_target")
        caster:Interrupt()
        ability:StartCooldown(1.0)
    else
    print("else")
    end
end


function MixHeat(keys)
    local caster = keys.caster
    local target = keys.target

    local heat1 = caster:GetModifierStackCount("modifier_heat_passive", nil)
    local heat2 = target:GetModifierStackCount("modifier_heat_passive", nil)
--    print("Old heat caster: "..heat1)
--    print("Old heat target: "..heat2)
    local newHeat = (heat1+heat2)/2
--    print("New heat: "..newHeat)
    caster.currentHeat = newHeat
    target.currentHeat = newHeat
    caster:SetModifierStackCount("modifier_heat_passive", nil, newHeat)
    target:SetModifierStackCount("modifier_heat_passive", nil, newHeat)
end

function MixEnergy(keys)
    local caster = keys.caster
    local target = keys.target

--    print("Old mana caster :"..caster:GetMana())
--    print("Old mana target :"..target:GetMana())
    local manaPercentageCaster = (caster:GetMana()/caster:GetMaxMana()) * 100
    local manaPercentageTarget = (target:GetMana()/target:GetMaxMana()) * 100
--    print("Mana percentaget caster "..caster:GetMana().."/"..caster:GetMaxMana().." = "..manaPercentageCaster.."%")
--    print("Mana percentaget target "..target:GetMana().."/"..target:GetMaxMana().." = "..manaPercentageTarget.."%")

    local averageManaPercentage = (manaPercentageCaster + manaPercentageTarget)/2
--    print("Average percentage: "..averageManaPercentage)
    local newManaCaster = (caster:GetMaxMana()/100) * averageManaPercentage
    local newManaTarget = (target:GetMaxMana()/100) * averageManaPercentage

    caster:SetMana(newManaCaster)
    target:SetMana(newManaTarget)
--    print("Mana percentaget caster "..caster:GetMana().."/"..caster:GetMaxMana().." = "..averageManaPercentage.."%")
--    print("Mana percentaget target "..target:GetMana().."/"..target:GetMaxMana().." = "..averageManaPercentage.."%")
end

function MixHealth(keys)
    local caster = keys.caster
    local target = keys.target
--    print("Old health caster :"..caster:GetHealth())
--    print("Old health target :"..target:GetHealth())
    local healthPercentageCaster = (caster:GetHealth()/caster:GetMaxHealth()) * 100
    local healthPercentageTarget = (target:GetHealth()/target:GetMaxHealth()) * 100
--    print("Health percentaget caster "..caster:GetHealth().."/"..caster:GetMaxHealth().." = "..healthPercentageCaster.."%")
--    print("Health percentaget target "..target:GetHealth().."/"..target:GetMaxHealth().." = "..healthPercentageTarget.."%")

    local averageHealthPercentage = (healthPercentageCaster + healthPercentageTarget)/2
--    print("Average percentage: "..averageHealthPercentage)
    local newHealthCaster = (caster:GetMaxHealth()/100) * averageHealthPercentage
    local newHealthTarget = (target:GetMaxHealth()/100) * averageHealthPercentage

    caster:SetHealth(newHealthCaster)
    target:SetHealth(newHealthTarget)
--    print("Health percentaget caster "..caster:GetHealth().."/"..caster:GetMaxHealth().." = "..averageHealthPercentage.."%")
--    print("Health percentaget target "..target:GetHealth().."/"..target:GetMaxHealth().." = "..averageHealthPercentage.."%")
end
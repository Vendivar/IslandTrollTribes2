function GetCorpses( event )
    local ability = event.ability
    local caster = event.caster
    local range = ability:GetCastRange()
    if not caster:HasModifier("modifier_meat_passive") then
        ApplyModifier(caster, "modifier_meat_passive")
    end
    local meatStacks = GetMeatRawStackCount(caster)
    if (meatStacks < 10) then
        local drops = Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetAbsOrigin(), range)
        for k,drop in pairs(drops) do
            if (meatStacks < 10) then
                local item = drop:GetContainedItem()
                local itemName = item:GetAbilityName()
                if itemName == "item_meat_raw" then
                 local position = drop:GetAbsOrigin()
            local meatParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_cast.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl( meatParticle, 0, drop:GetAbsOrigin() )
        ParticleManager:SetParticleControl( meatParticle, 1, caster:GetAbsOrigin() )
        ParticleManager:SetParticleControl( meatParticle, 2, drop:GetAbsOrigin() )
        ParticleManager:SetParticleControl( meatParticle, 3, drop:GetAbsOrigin() )
                    meatStacks = meatStacks + 1
                    caster:SetModifierStackCount("modifier_meat_passive", nil, meatStacks)
                    drop:RemoveSelf()
                end
            end
        end
    end
end

function GetCorpseAutocast( event )
    local ability = event.ability
    local caster = event.caster

    if ability:GetAutoCastState() and ability:IsFullyCastable() then
        caster:CastAbilityNoTarget(ability, -1)
    end
end

function FillSlots( event )
    local unit = event.caster

    local lockN = GameRules.UnitKV[unit:GetUnitName()]["FillSlots"] or 5
    ITT:CreateLockedSlotsForUnits(unit, lockN)
end

function GetMeatRawStackCount( unit )
    return unit:GetModifierStackCount("modifier_meat_passive", nil)
end

--[[
function GetMeatRawStack( unit )
    for i=0,5 do
        local item = unit:GetItemInSlot(i)
        if item and item:GetAbilityName() == "item_meat_raw" then
            return item
        end
    end
    return nil
end

function GetCurrentMeatRawStacks( unit )
    local meat = GetMeatRawStack(unit)
    if not meat then
        return 0
    else
        return meat:GetCurrentCharges()
    end
end]]

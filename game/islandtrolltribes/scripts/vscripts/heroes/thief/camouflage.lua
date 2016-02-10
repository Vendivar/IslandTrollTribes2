function CloakCamouflageInvis(keys)
    local caster = keys.caster
    ParticleManager:CreateParticle("particles/status_fx/status_effect_medusa_stone_gaze.vpcf", PATTACH_ROOTBONE_FOLLOW, caster)

    --print("attempt cloak")

    if GridNav:IsNearbyTree(caster:GetOrigin(), 150, true) then
        caster.invisLocation = caster:GetOrigin()
        caster.startTime = GameRules:GetGameTime()
        -- caster:SetContextThink("CloakCamouflageInvis", CamouflageInvisCheck, 1.0)
        Timers:CreateTimer(CamouflageInvisCheck, caster)
    end
end

function CamouflageInvisCheck(caster)
    local originalPos = caster.invisLocation
    if math.ceil(GameRules:GetGameTime() - caster.startTime) == 3 then
        --print("invis fade time over")
        local modApplier = CreateItem("item_coat_camouflage", caster, caster)
        modApplier:ApplyDataDrivenModifier(caster, caster, "modifier_coat_camouflage_invis", {duration = -1})
        caster:AddNewModifier(caster, nil, "modifier_persistent_invisibility", {duration = -1, hidden = true})
    end

    if math.ceil(GameRules:GetGameTime() - caster.startTime) % 3 == 0 then
        --print("losing more stats!")
        local heat = caster:GetModifierStackCount("modifier_heat_passive", nil)
        caster:SetModifierStackCount("modifier_heat_passive", nil, heat - 2)
        caster:ReduceMana(2)
        caster:ModifyHealth(caster:GetHealth()-2, caster,true,-2)
    end

    if caster:GetOrigin() ~= originalPos then
        --print("invis broken")
        caster:RemoveModifierByName("modifier_coat_camouflage_invis")
        caster:RemoveModifierByName("modifier_persistent_invisibility")
        return nil
    end

    return 1.0
end
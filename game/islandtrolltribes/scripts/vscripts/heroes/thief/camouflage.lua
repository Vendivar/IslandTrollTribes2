function CloakCamouflageInvis(keys)
    local caster = keys.caster
    ParticleManager:CreateParticle("particles/status_fx/status_effect_medusa_stone_gaze.vpcf", PATTACH_ROOTBONE_FOLLOW, caster)

    print("attempt cloak")

    if GridNav:IsNearbyTree(caster:GetOrigin(), 150, true) then
        caster.invisLocation = caster:GetOrigin()
        caster.startTime = GameRules:GetGameTime()
        Timers:CreateTimer(CamouflageInvisCheck, caster)
    end
end

function CamouflageInvisCheck(caster)
    local originalPos = caster.invisLocation
    print("tree nearby cloaking")
    if math.ceil(GameRules:GetGameTime() - caster.startTime) == 3 then
        --print("invis fade time over")
        caster:AddNewModifier(caster, nil, "modifier_persistent_invisibility", {duration = -1, hidden = true})
    end

    if caster:GetOrigin() ~= originalPos then
        --print("invis broken")
        caster:RemoveModifierByName("modifier_persistent_invisibility")
        caster:RemoveModifierByName("modifier_thief_camouflage")
        return nil
    end

    return 1.0
end
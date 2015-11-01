function MageMasherManaBurn(keys)
    local caster = keys.caster
    local target = keys.target
    local damage = tonumber(keys.Damage)
    local attackedClass = GetHeroClass(target)

    --look for mage and priests only
    if (attackedClass == "priest") or (attackedClass == "mage") then
        target:SpendMana(damage, nil)
        
        local damageTable = {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL}                      

        ApplyDamage(damageTable)
        
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN, target)
        target:EmitSound("Hero_NyxAssassin.ManaBurn.Target")

        local particlePopup = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(particlePopup, 1, Vector(1, damage, 0))
        ParticleManager:SetParticleControl(particlePopup, 2, Vector(1, #tostring(damage), 0))
    end 
end

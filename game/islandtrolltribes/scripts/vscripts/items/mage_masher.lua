function MageMasherManaBurn(keys)
    local caster = keys.caster
    local target = keys.target
    local damage = keys.Damage
    local targetName = target:GetUnitName()
    --look for mage and priests only
    if ((string.find(targetName,"mage") ~= nil) or (string.find(targetName,"priest")~= nil) or (string.find(targetName,"dazzle")~= nil) or (string.find(targetName,"witch")~= nil)) then
        --print("Burning " .. damage .. " mana")
        local startingMana = target:GetMana()
        target:SetMana(startingMana - damage)
        --print("Old mana " .. startingMana .. ". New Mana " .. target:GetMana())
        
        local damageTable = {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL}                      

        ApplyDamage(damageTable)
        
        local thisParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN, target)
        ParticleManager:ReleaseParticleIndex(thisParticle)
        target:EmitSound("Hero_NyxAssassin.ManaBurn.Target")
    else
        print(targetName .. " is not Mage or Priest")
    end 
end

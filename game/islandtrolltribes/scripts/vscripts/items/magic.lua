function RawMagicUse(keys)
    local caster = keys.caster
    local dieRoll = RandomInt(0, 100)

    print("Test your luck! " .. dieRoll)
    if dieRoll <= 30 then -- 30% lose % hp
        local percentHealth = RandomFloat(0.10, 0.99)
        local damageTable = {
        victim = caster,
        attacker = caster,
        damage = caster:GetHealth()*percentHealth,
        damage_type = DAMAGE_TYPE_PURE}

        ApplyDamage(damageTable)
        print("Unlucky! " .. percentHealth .. " health damage") 
    elseif dieRoll <= 40 then -- 10% full heal
        caster:Heal(caster:GetMaxHealth(), nil)
        print("Lucky! Full heal!")
    elseif dieRoll <= 50 then -- 10% death
        caster:Kill(nil, caster)
        print("Unlucky! Death!")
    elseif dieRoll <= 60 then -- 10% time = midnight
        GameRules:SetTimeOfDay(0.00)
        print("Lucky? Midnight")
    elseif dieRoll <= 70 then -- 10% meteor
        local abilityName = "ability_magic_raw_meteor"
        local ability_magic_raw_meteor = caster:FindAbilityByName(abilityName)
        if ability_magic_raw_meteor == nil then
            caster:AddAbility(abilityName)
            ability_magic_raw_meteor = caster:FindAbilityByName(abilityName)
        end
        print("trying to cast ability_magic_raw_meteor")
        caster:CastAbilityOnPosition(caster:GetOrigin(), ability_magic_raw_meteor, -1)
        caster:RemoveAbility(abilityName)
        print("BOOM")
    elseif dieRoll <= 80 then -- 10% mana crystals
        local item1 = CreateItem("item_crystal_mana", nil, nil)
        local item2 = CreateItem("item_crystal_mana", nil, nil)
        CreateItemOnPositionSync(caster:GetOrigin() + RandomVector(RandomInt(20,100)), item1)
        CreateItemOnPositionSync(caster:GetOrigin() + RandomVector(RandomInt(20,100)), item2)
        print("Lucky! Crystals!")
    else -- 20% disco duck
        if (duckBoss == nil) then
            duckBoss = CreateUnitByName("npc_boss_disco_duck", Vector(0,0,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
            EmitGlobalSound("ancient.evil")
            print(duckBoss:GetClassname())
            print(duckBoss:GetUnitName())
            print("AN ANCIENT EVIL HAS AWOKEN")
            ShowCustomHeaderMessage("#DiscoDuckSpawnMessage", -1, -1, 5)
        end
    end
end

function RawMagicMeteor(keys)
    local caster = keys.caster
    local startPoint = caster:GetAbsOrigin()
    startPoint.z = 3000
    startPoint = startPoint + RandomVector(RandomInt(-150,150))
    local endPoint = caster:GetAbsOrigin()
    endPoint.z = -3000
    local duration = Vector(0.75,0,0)

    print(startPoint, endPoint)

    local particle = ParticleManager:CreateParticle('particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf', PATTACH_CUSTOMORIGIN, dummy_unit)
    ParticleManager:SetParticleControl(particle, 0, startPoint)
    ParticleManager:SetParticleControl(particle, 1, endPoint)
    ParticleManager:SetParticleControl(particle, 2, duration)

    local context = {particle =  particle, startPoint= startPoint, endPoint = endPoint,}
    Timers:CreateTimer(DoUniqueString("meteor_timer"), {callback=RemoveParticles, endTime = 1}, context)
end

function RemoveParticles(context)
    local endMeteor = ParticleManager:CreateParticle('particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf', PATTACH_CUSTOMORIGIN, dummy_unit)
    ParticleManager:SetParticleControl(endMeteor, 0, context.endPoint)
    ParticleManager:DestroyParticle(endMeteor, false)
    ParticleManager:ReleaseParticleIndex(endMeteor)
    ParticleManager:DestroyParticle(context.particle, true)
    ParticleManager:ReleaseParticleIndex(context.particle)
    return
end
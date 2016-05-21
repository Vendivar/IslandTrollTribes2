function Metronome(keys)
    local caster = keys.caster
    local target = keys.target
    local targetPosition = target:GetAbsOrigin()
    local dieroll = RandomInt(0, 99)
    --start tick noise
    target:EmitSound("Tick")
    target.metronomeParticle = ParticleManager:CreateParticle("particles/metronome.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)

    local dummy = CreateUnitByName("dummy_caster_metronome", targetPosition, false, caster, caster, caster:GetTeam())
    local abilityList = {
        {name = "ability_metronome_frostnova",possibilityFactor = 9}, -- {name="ability name", possibilityFactor = 9,  abilityObj = ability_object}
        {name = "ability_metronome_cyclone",  possibilityFactor = 29},
        {name = "ability_metronome_tsunami",  possibilityFactor = 39},
        {name = "ability_metronome_manaburn", possibilityFactor = 59},
        {name = "ability_metronome_impale" ,  possibilityFactor = 69},
        {name = "ability_metronome_poisonthistle", possibilityFactor = 89 }
    }
    for i,ability in pairs(abilityList) do
         dummy:AddAbility(ability.name)
         ability.abilityObj = dummy:FindAbilityByName(ability.name)
         ability.abilityObj:SetLevel(1)
    end
    dummy.abilityList = abilityList
    local frostnova = dummy:FindAbilityByName("ability_metronome_frostnova")
    local spellFrostnova = function()
        dummy:CastAbilityOnTarget(target, frostnova, caster:GetPlayerID())
        return
    end

    if dieroll <=49 then
        Timers:CreateTimer(0.1, spellFrostnova)
    else
        print("full metro cast")
        dummy.duration = 10
        dummy.target = target
        dummy.caster = caster
        dummy.startTime = GameRules:GetGameTime()
        Timers:CreateTimer(MetronomeSpell, dummy)
    end
end

function MetronomeSpell(dummy)
    local firstTarget = dummy.target
    local duration = dummy.duration
    local caster = dummy.caster
    local selectedSpell  = SelectSpell(dummy.abilityList)

    -- pick a random target
    local secondaryTarget = FindRandomTarget(firstTarget)
    if secondaryTarget ~= nil and selectedSpell ~= nil then
        print("casting spell, "..selectedSpell:GetName()..", on "..secondaryTarget:GetName())
        Timers:CreateTimer(0.3, function()
            dummy:MoveToNPC(secondaryTarget)
            dummy:CastAbilityOnTarget(secondaryTarget, selectedSpell, caster:GetPlayerID())
            return
            end)
    end

    if (GameRules:GetGameTime() - dummy.startTime) >= duration then
        --should stop playing when metronome script finishes
        --firstTarget:StopSound("tick")
        ParticleManager:DestroyParticle(target.metronomeParticle,false)
        return nil
    end
    return 0.7
end


function SelectSpell(abilityList)
    local dieroll = RandomInt(0, 89)
    for i,ability in pairs(abilityList) do  -- {name="ability name", possibilityFactor = 9,  abilityObj = ability_object}
        if dieroll <= ability.possibilityFactor then
            return  ability.abilityObj
        end
    end
end


function FindRandomTarget(firstTarget)
    local units = FindUnitsInRadius(firstTarget:GetTeamNumber(),
        firstTarget:GetAbsOrigin(),
        nil,
        500,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)
    local count = 1
    for _ in pairs(units) do
        count = count + 1
    end
    local randomTarget = RandomInt(0,count)
--    print("Random target: "..randomTarget..", count:"..count)
    return units[randomTarget]
end

function MetronomeManaBurn(keys)
    local caster = keys.caster
    local target = keys.target
    local damage = keys.Damage
    local targetName = target:GetUnitName()

    --print("Burning " .. damage .. " mana")
    local startingMana = target:GetMana()
    target:SetMana(startingMana - damage)
    --print("Old mana " .. startingMana .. ". New Mana " .. target:GetMana())

    local damageTable = {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL
    }

    ApplyDamage(damageTable)

    local thisParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN, target)
    ParticleManager:ReleaseParticleIndex(thisParticle)
    target:EmitSound("Hero_NyxAssassin.ManaBurn.Target")
end
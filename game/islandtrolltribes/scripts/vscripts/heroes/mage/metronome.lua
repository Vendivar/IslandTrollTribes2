--ISNT WORKING, CANT GETPLAYERID
function Metronome(keys)
    local caster = keys.caster
    local target = keys.target
    local targetPosition = target:GetAbsOrigin()
    local dieroll = RandomInt(0, 99)
    local metronomeParticle = "particles/metronome.vpcf"

    local dummy = CreateUnitByName("dummy_caster_metronome",
                                targetPosition,
                                false,
                                caster,
                                caster,
                                caster:GetTeam())

    dummy:AddAbility("ability_metronome_frostnova")
    dummy:AddAbility("ability_metronome_cyclone")
    dummy:AddAbility("ability_metronome_tsunami")
    dummy:AddAbility("ability_metronome_manaburn")
    dummy:AddAbility("ability_metronome_impale")
    dummy:AddAbility("ability_metronome_poisonthistle")

    local frostnova = dummy:FindAbilityByName("ability_metronome_frostnova")
    local cyclone = dummy:FindAbilityByName("ability_metronome_cyclone")
    local tsunami = dummy:FindAbilityByName("ability_metronome_tsunami")
    local manaburn = dummy:FindAbilityByName("ability_metronome_manaburn")
    local impale = dummy:FindAbilityByName("ability_metronome_impale")
    local poisonthistle = dummy:FindAbilityByName("ability_metronome_poisonthistle")

    frostnova:SetLevel(1)
    cyclone:SetLevel(1)
    tsunami:SetLevel(1)
    manaburn:SetLevel(1)
    impale:SetLevel(1)
    poisonthistle:SetLevel(1)
    --start tick noise
    target:EmitSound("Tick")
    ParticleManager:CreateParticle(metronomeParticle, PATTACH_ABSORIGIN_FOLLOW, target)
    if dieroll <=49 then
        Timers:CreateTimer(0.1, function()
                dummy:CastAbilityOnTarget(target, frostnova, caster:GetPlayerID())
                return
                end
                )
    else
        print("full metro cast")
        dummy.dur = 10
        dummy.tar = target
        dummy.cas = caster
        dummy.startTime = GameRules:GetGameTime()
        dummy:SetContextThink("dummy_thinker"..dummy:GetEntityIndex(), MetronomeSpell, 0.7)
    end
    target:StopSound("tick")
  ParticleManager:DestroyParticle(target.metronomeParticle,false)
    --should stop playing when metronome script finishes
end

function MetronomeSpell(dummy)
    local target = dummy.target
    local duration = dummy.duration
    local caster = dummy.caster

    local frostnova = dummy:FindAbilityByName("ability_metronome_frostnova")
    local cyclone = dummy:FindAbilityByName("ability_metronome_cyclone")
    local tsunami = dummy:FindAbilityByName("ability_metronome_tsunami")
    local manaburn = dummy:FindAbilityByName("ability_metronome_manaburn")
    local impale = dummy:FindAbilityByName("ability_metronome_impale")
    local poisonthistle = dummy:FindAbilityByName("ability_metronome_poisonthistle")

    local ability = nil
    dieroll = RandomInt(0, 99)

    if dieroll <= 9 then
        ability = cyclone
    elseif dieroll <= 29 then
        ability = tsunami
    elseif dieroll <= 39 then
        ability = manaburn
    elseif dieroll <= 59 then
        ability = impale
    elseif dieroll <= 69 then
        ability = poisonthistle
    elseif dieroll <= 89 then
        ability = frostnova
    end 
    target:StopSound("tick")
    -- pick a random target
    local units = FindUnitsInRadius(target:GetTeamNumber(),
                                    target:GetAbsOrigin(),
                                    nil,
                                    500,
                                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                    DOTA_UNIT_TARGET_HERO,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)
    local count = 0
    for _ in pairs(units) do
        count = count + 1
    end

    local randomTarget = RandomInt(0,count)
    target = units[randomTarget]
    dummy:MoveToNPC(target)

    if ability ~= nil then
        print("casting spell!")
        Timers:CreateTimer(0.3, function()
                dummy:CastAbilityOnTarget(target, ability, caster:GetPlayerID())
                return
                end
                )
    end

    if (GameRules:GetGameTime() - dummy.startTime) >= duration then
        return nil
    end

    return 0.7
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
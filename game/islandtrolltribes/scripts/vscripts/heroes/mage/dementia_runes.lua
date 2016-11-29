DEMENTIA_RUNES = {"ka_rune","lez_rune","nel_rune"}
LEVEL_TO_STACKS = {1,3,6}

-- Shows the new abilities
function ToggleOnRunes( event )
    local caster = event.caster
    local ability = event.ability
    HideAllAbilities(caster)
    
    ability:SetHidden(false)
    PrintAbilities(caster)

    if not caster:HasAbility("ability_mage_dementia_runes_start") then
        local start = caster:AddAbility("ability_mage_dementia_runes_start")
        local stop = caster:AddAbility("ability_mage_dementia_runes_stop")
        local invoked = caster:AddAbility("ability_mage_dementia_runes_invoked")

        start:SetLevel(1)
        stop:SetLevel(1)
        invoked:SetLevel(1)

        stop:SetActivated(false)
        invoked:SetActivated(false)
    else
        local start = caster:FindAbilityByName("ability_mage_dementia_runes_start")
        local stop = caster:FindAbilityByName("ability_mage_dementia_runes_stop")
        local invoked = caster:FindAbilityByName("ability_mage_dementia_runes_invoked")

        start:SetHidden(false)
        stop:SetHidden(false)
        invoked:SetHidden(false)

        if not ability.runes or #ability.runes == 0 then
            stop:SetActivated(false)
        end
    end
end

-- Turns the layout back to normal
function ToggleOffRunes( event )
    local caster = event.caster
    local spellBook = GameRules.SpellBookInfo[MAGE]["dementia_master"]["book2"]
    HideAllAbilities(caster)
    ShowTheSpellBook(caster, spellBook)
end

function Start(event)
    local ability = event.ability
    local caster = event.caster
    ResetRunes(caster)

    ability.particle = ParticleManager:CreateParticle("particles/custom/rune_base.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

    caster:FindAbilityByName("ability_mage_dementia_runes_stop"):SetActivated(true)
    caster:FindAbilityByName("ability_mage_dementia_runes_invoked"):SetActivated(false)
    StartRotatingRunes(caster, 1)
end

function Stop(event)
    local ability = event.ability
    local caster = event.caster
    local acquired = DEMENTIA_RUNES[RandomInt(1,3)]
    
    local dementia_runes = caster:FindAbilityByName("ability_mage_dementia_runes")
    table.insert(dementia_runes.runes, acquired)
    dementia_runes[acquired] = dementia_runes[acquired] and dementia_runes[acquired] + 1 --1/2/3

    ability:ApplyDataDrivenModifier(caster,caster,"modifier_"..acquired,{})
    caster:SetModifierStackCount("modifier_"..acquired,caster,LEVEL_TO_STACKS[dementia_runes[acquired]]) --1/3/6

    StopRunes(caster)

    if #dementia_runes.runes == 3 then
        ability:SetActivated(false)
        local start_ability = caster:FindAbilityByName("ability_mage_dementia_runes_start")
        start_ability:SetActivated(true)
        ParticleManager:DestroyParticle(start_ability.particle,false)
        caster:FindAbilityByName("ability_mage_dementia_runes_invoked"):SetActivated(true)
        dementia_runes.resetTimer = Timers:CreateTimer(45, function() -- The runes last 45 seconds
            ResetRunes(caster)
        end)
    else
        StartRotatingRunes(caster, #dementia_runes.runes+1)
    end
end

function Cast(event)
    local caster = event.caster
    local target = event.target
    local ability = event.ability

    local info =
    {
        Ability = ability,
        Target = target,
        Source = caster,
        EffectName = "particles/units/heroes/hero_visage/visage_soul_assumption_bolt6.vpcf", -- This should be different combinations
        vSpawnOrigin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
        bProvidesVision = false,
        bDeleteOnHit = true,
        bDodgeable = false,
        iMoveSpeed = 1000
    }
    projectile = ProjectileManager:CreateTrackingProjectile(info)

    caster:FindAbilityByName("ability_mage_dementia_runes_invoked"):SetActivated(false)
    caster:FindAbilityByName("ability_mage_dementia_runes"):ToggleAbility()
end

function Hit(event)
    local caster = event.caster
    local target = event.target
    local ability = event.ability

    local ka_level = caster:GetModifierStackCount("modifier_ka_rune",caster)
    local lez_level = caster:GetModifierStackCount("modifier_lez_rune",caster)
    local nel_level = caster:GetModifierStackCount("modifier_nel_rune",caster)

    if ka_level > 0 then -- Damage
        ApplyDamage({victim = target, attacker = caster, damage = ability:GetSpecialValueFor("damage_per_ka_lvl") * ka_level, damage_type = DAMAGE_TYPE_PURE})
    end

    if lez_level > 0 then
        ability:ApplyDataDrivenModifier(caster,target,"modifier_lez_slow",{duration=5})
       -- caster:SetModifierStackCount("modifier_lez_slow",caster,lez_level)
        for i=1,lez_level do
            ability:ApplyDataDrivenModifier(caster,target,"modifier_lez_dot",{duration=5})
        end
    end

    if nel_level > 0 then -- Stun
        ability:ApplyDataDrivenModifier(caster,target,"modifier_nel_stun",{duration=nel_level})
    end

    print("Dementia Runes Effect:")
    print("\tDamage:  ",ability:GetSpecialValueFor("damage_per_ka_lvl") * ka_level)
    print("\tSlot/DoT:",ability:GetSpecialValueFor("slowdot_per_lez_level") * lez_level)
    print("\tStun:    ",nel_level)

    ResetRunes(caster)
end

function ResetRunes(hero)
    local ability = hero:FindAbilityByName("ability_mage_dementia_runes")
    ability.runes = {}
    ability.ka_rune = 0
    ability.lez_rune = 0
    ability.nel_rune = 0
    hero:RemoveModifierByName("modifier_ka_rune")
    hero:RemoveModifierByName("modifier_lez_rune")
    hero:RemoveModifierByName("modifier_nel_rune")
    hero:FindAbilityByName("ability_mage_dementia_runes_invoked"):SetActivated(false)
    if ability.resetTimer then
        Timers:RemoveTimer(ability.resetTimer)
    end
    if hero.rune_particles then
        for k,v in pairs(hero.rune_particles) do
            ParticleManager:DestroyParticle(v, true)
        end
    end
    local start_ability = hero:FindAbilityByName("ability_mage_dementia_runes_start")
    if start_ability and start_ability.particle then
        ParticleManager:DestroyParticle(start_ability.particle,false)
    end
end

function StopRunes(hero)
    if hero.rotatingTimer then
        Timers:RemoveTimer(hero.rotatingTimer)
    end
    if hero.rune_particles then
        for k,v in pairs(hero.rune_particles) do
            ParticleManager:DestroyParticle(v, true)
        end
    end
end

function StartRotatingRunes(hero, level)
    local runes = {"ka_rune","lez_rune","nel_rune"}
    for i=1,3 do
        table.insert(runes, runes[RandomInt(1,#runes)])
    end
    runes = ShuffledList(runes)

    hero.rune_particles = {}
    local points = GenerateNumPointsAround(6, hero:GetAbsOrigin(), 200, 0)
    for k,rune_name in pairs(runes) do
        hero.rune_particles[k] = ParticleManager:CreateParticle("particles/custom/"..rune_name..".vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(hero.rune_particles[k],0,points[k])
    end

    local offset = 0
    hero.rotatingTimer = Timers:CreateTimer(0.03, function()
        local origin = hero:GetAbsOrigin()
        origin.z = origin.z + 32
        points = GenerateNumPointsAround(6, origin, 200, offset)
        for k,particle in pairs(hero.rune_particles) do
            ParticleManager:SetParticleControl(particle,0,points[k])
        end
        offset = offset + level * level
        return 0.03
    end)
end


function GenerateNumPointsAround(num, center, distance, offset)
    local points = {}
    local angle = 360/num
    for i=0,num-1 do
        local rotate_pos = center + Vector(1,0,0) * distance
        table.insert(points, RotatePosition(center, QAngle(0, angle*i + offset, 0), rotate_pos) )
    end
    return points
end


----------------------------------------------------
-- Deprecated
----------------------------------------------------

function NelRune(keys)
    local caster = keys.caster
    local runeInfo = {name = "particles/customgames/capturepoints/cp_fire.vpcf", type = "nelrune", abilityName = "ability_mage_nelrune_spell"}
    AddNewRune(caster,runeInfo)
end

function LezRune(keys)
    local caster = keys.caster
    local runeInfo = {name = "particles/customgames/capturepoints/cp_allied_metal.vpcf", type = "lezrune", abilityName = "ability_mage_lezrune_spell"}
    AddNewRune(caster,runeInfo)
end

function KaRune(keys)
    local caster = keys.caster
    local runeInfo = {name = "particles/customgames/capturepoints/cp_wind_captured.vpcf", type = "karune", abilityName = "ability_mage_karune_spell"}
    AddNewRune(caster,runeInfo)
end

function CasterMovementCheck(caster)
    if caster.runeList ~=nil and HasCasterMoved(caster) then --Redraw rune particles only if the caster has runes poistion in the world has changed.
        RedrawParticles(caster)
    end
    return 1.5
end

function RedrawParticles(caster)
    local particleList = {}
    if caster.demParticles then --Remove old particles
        DestroyParticles(caster.demParticles)
    end
    local particleLocations = GetParticlePositions(caster, #caster.runeList)
    for i,runeInfo in pairs(caster.runeList) do
        local runeParticle  = ParticleManager:CreateParticle(runeInfo.name, PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(runeParticle,0,particleLocations[i])
        table.insert(particleList, runeParticle)
    end
    caster.demParticles = particleList
end

function HasCasterMoved(caster)
    local hasMoved =  false
    local currentPosition = caster:GetAbsOrigin()
    local oldPosition = caster.demLastPosition
    if not oldPosition or (oldPosition.x ~= currentPosition.x or oldPosition.y ~=  currentPosition.y or oldPosition.z ~=  currentPosition.z) then
        caster.demLastPosition = currentPosition
        hasMoved = true
    end
    return hasMoved
end

function DestroyParticles(particleList)
    for _,particle in pairs(particleList) do
        ParticleManager:DestroyParticle(particle, true)
    end
end

function AddNewRune(caster,runeInfo)
    if caster.runeList == nil then
        caster.runeList = {}
        Timers:CreateTimer(DoUniqueString("dementia_runes"),{callback=CasterMovementCheck},caster)
    end
    if #caster.runeList >= 5 then
        for i=1,4  do --Shifting the rune list to get a space for the new rune.
            caster.runeList[i] = caster.runeList[i+1]
        end
        caster.runeList[5] = runeInfo
    else
        table.insert(caster.runeList,runeInfo)
    end
    RedrawParticles(caster)
end

function RemoveRune(caster, runeId)
    table.remove(caster.runeList,runeId)
    RedrawParticles(caster)
end

function GetParticlePositions(caster, numberOfRunes)
    local casterOrigin =  caster:GetAbsOrigin()
    local particleLocations = {}
    local radius =  120
    if numberOfRunes == 1 then
        table.insert(particleLocations,Vector(casterOrigin.x , casterOrigin.y, casterOrigin.z))
    else
        for i=1,numberOfRunes do
            table.insert(particleLocations,Vector(casterOrigin.x + (math.cos(i*2*math.pi/numberOfRunes) * radius), casterOrigin.y + (math.sin(i*2*math.pi/numberOfRunes) * radius), casterOrigin.z))
        end
    end
    return particleLocations
end

function ActivateRunes(keys)
    local caster = keys.caster
    local target = keys.target
    for i,rune in pairs(caster.runeList) do
        Timers:CreateTimer(i-1,function()
            local dummyDementiaRune = CreateUnitByName("dummy_dementia_rune", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
            ParticleManager:CreateParticle(rune.name, PATTACH_ABSORIGIN_FOLLOW, dummyDementiaRune)
            Timers:CreateTimer(0.1, function()
                dummyDementiaRune:MoveToNPC(target)
                dummyDementiaRune.caster = caster
                dummyDementiaRune.target = target
                dummyDementiaRune.runeAbilityName =  rune.abilityName
                Timers:CreateTimer(DoUniqueString("movement_check"),{callback=dummyMovementCheck}, dummyDementiaRune)
                return
            end)
            RemoveRune(caster, 1)
        end)
    end
end

function dummyMovementCheck(dummyDementiaRune)
    local length = (dummyDementiaRune:GetAbsOrigin() - dummyDementiaRune.target:GetAbsOrigin()):Length2D()
    if length <= 130.0 then
        dummyDementiaRune:SetOrigin(dummyDementiaRune.target:GetAbsOrigin())
        local runeAbility = dummyDementiaRune:FindAbilityByName(dummyDementiaRune.runeAbilityName)
        dummyDementiaRune:CastAbilityOnTarget(dummyDementiaRune.target, runeAbility, -1)
        Timers:CreateTimer(1.0, function()
            dummyDementiaRune:ForceKill(true)
        end)
        return nil
    end
    return 0.1
end
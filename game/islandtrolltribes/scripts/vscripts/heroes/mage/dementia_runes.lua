function RunesTelegatherInit(keys)
    local caster = keys.caster
    local target = keys.target
    keys.caster.targetFire = target
end

-- ItemRunes, RunesManip
-- ToggleOn RunesManip:         ItemRunes, RunesManip, Ability1, 2, 3, 4.
function ToggleOnRunes( event )
    local caster = event.caster
    local runesAbilityList = {
        "ability_mage_dementia_runes",
        "ability_mage_karune",
        "ability_mage_lezrune",
        "ability_mage_nelrune"
    }
    HideAllAbilities(caster)
    ShowTheSpellBook(caster, runesAbilityList)
end

-- Turns the layout back to normal
function ToggleOffRunes( event )
    local caster = event.caster
    local spellBook = GameRules.SpellBookInfo[MAGE]["dementia_master"]["book2"]
    HideAllAbilities(caster)
    ShowTheSpellBook(caster, spellBook)
end

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
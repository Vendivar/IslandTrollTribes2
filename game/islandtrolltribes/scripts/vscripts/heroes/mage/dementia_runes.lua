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
    print("NelRune is called..")
    local caster = keys.caster
    local runeInfo = {name = "particles/customgames/capturepoints/cp_fire.vpcf", type = "nelrune"}
    AddNewRune(caster,runeInfo)
end

function LezRune(keys)
    print("LezRune is called..")
    local caster = keys.caster
    local runeInfo = {name = "particles/customgames/capturepoints/cp_allied_metal.vpcf", type = "lezrune"}
    AddNewRune(caster,runeInfo)
end

function KaRune(keys)
    print("KaRune is called..")
    local caster = keys.caster
    local runeInfo = {name = "particles/customgames/capturepoints/cp_wind_captured.vpcf", type = "karune"}
    AddNewRune(caster,runeInfo)
end

function CasterMovementCheck(caster)
    if caster.runeList ~=nil and HasCasterMoved(caster) then --draw the rune particles only if the caster has runes and when he has changed his poistion in the world.
        RedrawParticles(caster)
    end
    return 2.0
end

function RedrawParticles(caster)
    local particleList = {}
    if caster.demParticles then --Remove old particles
        DestroyParticles(caster.demParticles)
    end
    local particleLocations = GetParticlePositions(caster, caster.runeCount)
    for i,runeInfo in pairs(caster.runeList) do
        local runeParticle  = ParticleManager:CreateParticle(runeInfo.name, PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(runeParticle,0,particleLocations[i])
        table.insert(particleList,runeParticle)
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
    print(string.format("User has moved? : %s",hasMoved))
    return hasMoved
end

function DestroyParticles(particleList)
    for _,particle in pairs(particleList) do
        ParticleManager:DestroyParticle(particle, true)
    end
end

function AddNewRune(caster,runeInfo)
    if caster.runeCount == nil then
        caster.runeCount = 0
        caster.runeList = {}
        Timers:CreateTimer(DoUniqueString("dementia_runes"),{callback=CasterMovementCheck},caster)
    end
    if caster.runeCount >= 5 then
        for i=1,4  do
            caster.runeList[i] = caster.runeList[i+1]
        end
        caster.runeList[5] = runeInfo
    else
        table.insert(caster.runeList,runeInfo)
        caster.runeCount = caster.runeCount + 1
    end
    RedrawParticles(caster)
end

function GetParticlePositions(caster, numberOfRunes)
    local casterOrigin =  caster:GetAbsOrigin()
    local particleLocations = {}
    local radius =  120
    if numberOfRunes == 1 then
        table.insert(particleLocations,Vector(casterOrigin.x , casterOrigin.y, casterOrigin.z))
    else
        for i=1,5 do
            table.insert(particleLocations,Vector(casterOrigin.x + (math.cos(i*2*math.pi/numberOfRunes) * radius), casterOrigin.y + (math.sin(i*2*math.pi/numberOfRunes) * radius), casterOrigin.z))
        end
    end
    return particleLocations
end
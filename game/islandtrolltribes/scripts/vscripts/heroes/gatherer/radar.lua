function RadarTelegatherInit(keys)
    local caster = keys.caster
    local target = keys.target

    keys.caster.targetFire = target

end

function RadarManipulations(keys)
    local caster = keys.caster
    local isOpening = (keys.isOpening == "true")
    local ABILITY_radarManipulations = caster:FindAbilityByName("ability_gatherer_radarmanipulations")

    local abilityLevel = ABILITY_radarManipulations:GetLevel()
    print("abilityLevel", abilityLevel)
    local unitName = caster:GetUnitName()
    print(unitName)

    local tableDefaultSkillBook ={
        "ability_gatherer_itemradar",
        "ability_gatherer_radarmanipulations",
        "ability_empty3",
        "ability_empty4",
        "ability_empty5",
        "ability_empty6",
        "ability_empty7"}

    local tableRadarBook ={
        "ability_gatherer_findmushroomstickortinder",
        "ability_gatherer_findhide",
        "ability_gatherer_findclayballcookedmeatorbone",
        "ability_gatherer_findmanacrystalorstone",
        "ability_gatherer_findflint",
        "ability_gatherer_findmagic"
    }

    local numAbilities = abilityLevel + 1

    for i=1,numAbilities do
        print(tableDefaultSkillBook[i], tableRadarBook[i])
        local ability1 = caster:FindAbilityByName(tableDefaultSkillBook[i])
        local ability2 = caster:FindAbilityByName(tableRadarBook[i])
        if ability2:GetLevel() == 0 then
            ability2:SetLevel(1)
        end
        print("isopening",isOpening)
        if isOpening == true then
            print("ability1:", ability1:GetName(), "ability2:", ability2:GetName())
            SwapAbilities(caster, ability1, ability2, false, true)
            caster:FindAbilityByName("ability_gatherer_radarmanipulations"):SetHidden(true)
        else
            SwapAbilities(caster, ability1, ability2, true, false)
            caster:FindAbilityByName("ability_gatherer_radarmanipulations"):SetHidden(false)
            caster:FindAbilityByName("ability_empty3"):SetHidden(true)
            caster:FindAbilityByName("ability_empty4"):SetHidden(true)
            caster:FindAbilityByName("ability_empty5"):SetHidden(true)
            caster:FindAbilityByName("ability_empty6"):SetHidden(true)
        end
    end

end
function RadarTelegatherInit(keys)
    local caster = keys.caster
    local target = keys.target

    keys.caster.targetFire = target

end

function RadarTelegather (keys)
    local hero = EntIndexToHScript( keys.HeroEntityIndex )
    local hasTelegather = hero:HasModifier("modifier_telegather")
    local targetFire = hero.targetFire

    local originalItem = EntIndexToHScript(keys.ItemEntityIndex)
    local newItem = CreateItem(originalItem:GetName(), nil, nil)

    local itemList = {"item_tinder", "item_flint", "item_stone", "item_stick", "item_bone", "item_meat_raw", "item_crystal_mana", "item_clay_ball", "item_river_root", "item_river_stem", "item_thistles", "item_acorn", "item_acorn_magic", "item_mushroom"}
    for key,value in pairs(itemList) do
        if value == originalItem:GetName() then
            print( "Teleporting Item", originalItem:GetName())
            hero:RemoveItem(originalItem)
            local itemPosition = targetFire:GetAbsOrigin() + RandomVector(RandomInt(100,150))
            CreateItemOnPositionSync(itemPosition,newItem)
            newItem:SetOrigin(itemPosition)
        end
    end
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
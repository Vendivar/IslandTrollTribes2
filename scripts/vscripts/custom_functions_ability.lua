-- Global variables
HUNTER = "npc_dota_hero_huskar"
PRIEST = "npc_dota_hero_dazzle"
MAGE = "npc_dota_hero_witch_doctor"
BEASTMASTER = "npc_dota_hero_lycan"
THIEF = "npc_dota_hero_riki"
SCOUT = "npc_dota_hero_lion"
GATHERER = "npc_dota_hero_shadow_shaman"

--general "ping minimap" function
function PingMap(playerID,pos,r,g,b)
    --(PlayerID, position(vector), R, G, B, SizeofDot, Duration)
    GameRules:AddMinimapDebugPoint(5,pos, r, g, b, 500, 6)
    print("x:", pos.x)
    print("y:", pos.y)
    print("z:", pos.z)
    --NEWEST PING ALWAYS CLEARS LAST PING, ONLY ONE PING AT A TIME, THIS FUNCTION SUCKS DICK BUT IT'S ALL WE HAVE TO WORK WITH
end
--Gatherer Ability Functions
--[[Pings the items in parameter ItemTable with their corresponding color]]
function PingItemInRange(keys)
    --PrintTable(keys)
    local caster = keys.caster
    local id = caster:GetPlayerID()
    local team = caster:GetTeamNumber()
    local range = keys.Range
    local itemTable = keys.ItemTable

    --PingMap(caster:GetPlayerID(),caster:GetOrigin(),1,1,1)
    --code above for checking your position.
    print("caster info", caster:GetTeam(), caster:GetOrigin(),range)
    for _,item in pairs( Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetOrigin(), range)) do
        local containedItem = item:GetContainedItem()

        -- Get item color from table, else default white
        local itemColor = itemTable[containedItem:GetAbilityName()]
        if (itemColor == nil) then
            itemColor = "255 255 255"
        end
        -- TODO: ignore raw meat since it is now an item.
        
        -- Iterate over item color string and parse into specific values
        local stringParse = string.gmatch(itemColor, "%d+")
        --need to divide by 255 to convert to 0-1 scale
        local redVal = tonumber(stringParse())/255
        local greenVal = tonumber(stringParse())/255
        local blueVal = tonumber(stringParse())/255
 
        print("pinging", containedItem:GetAbilityName(), "at", item:GetAbsOrigin().x, item:GetAbsOrigin().y, item:GetAbsOrigin().z)
        --maybe use CreateParticleForPlayer(string particleName, int particleAttach, handle owningEntity, handle owningPlayer)
        local thisParticle = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, item)
        ParticleManager:SetParticleControl(thisParticle, 0, item:GetAbsOrigin())
        ParticleManager:SetParticleControl(thisParticle, 1, Vector(redVal, greenVal, blueVal))
        print(containedItem:GetAbilityName(), redVal, greenVal, blueVal)
        ParticleManager:ReleaseParticleIndex(thisParticle)
        item:EmitSound("General.Ping")   --may be deafening
        print("ping color: ", itemColor)
        --Ping Minimap
        --PingMap2(team, caster, item:GetAbsOrigin().x, item:GetAbsOrigin().y, 3)
    end
end

--[[Checks unit inventory for matching recipes. If there's a match, remove all items and add the corresponding potion
    Matches must have the exact number of each ingredient
    Used for both the Mixing Pot and the Herb Telegatherer]]
function MixHerbs(keys)
    print("MixHerbs")
    local caster = keys.caster
    --Table to identify ingredients
    local herbTable = {"item_river_stem", "item_river_root", "item_herb_butsu", "item_herb_orange", "item_herb_purple", "item_herb_yellow", "item_herb_blue"}
    local specialTable = {"item_herb_orange", "item_herb_purple", "item_herb_yellow", "item_herb_blue"}
    --Table used to look up herb recipes, can move this if other functions need it
    local recipeTable = {
        {"item_spirit_wind", {item_river_stem = 2}},
        {"item_spirit_water", {item_river_root = 2}},
        {"item_potion_anabolic", {item_river_stem = 6}},
        {"item_potion_cure_all", {item_herb_butsu = 6}},
        {"item_potion_drunk", {item_river_stem = 2, item_herb_butsu = 2}},
        {"item_potion_healingi", {item_river_root = 1, item_herb_butsu = 1}},
        {"item_potion_healingiii", {item_river_root = 2, item_herb_butsu = 2}},
        {"item_potion_healingiv", {item_river_root = 3, item_herb_butsu = 3}},
        {"item_potion_manai", {item_river_stem = 1, item_herb_butsu = 1}},
        {"item_potion_manaiii", {item_river_stem = 2, item_herb_butsu = 2}},
        {"item_potion_manaiv", {item_river_stem = 3, item_herb_butsu = 3}},
        {"item_rock_dark", {item_river_root = 2, item_river_stem = 2, item_herb_butsu = 2}},
        {"item_potion_twin_island", {item_herb_orange = 3, item_herb_purple = 3}},
        {"item_potion_twin_island", {item_herb_yellow = 3, item_herb_blue = 3}},
        {"item_essence_bees", {item_herb_orange = 1, item_herb_purple = 1, item_herb_yellow = 1, item_herb_blue = 1}},
        {"item_gem_of_knowledge", {item_herb_blue = 1, item_herb_orange = 3, item_herb_yellow}},
        {"item_gem_of_knowledge", {item_herb_blue = 1, item_herb_orange = 3, item_herb_purple}},
        {"item_potion_anti_magic", {special_1 = 6}},
        {"item_potion_fervor", {special_1 = 3, item_herb_butsu = 1}},
        {"item_potion_elemental", {special_1 = 1, item_river_stem = 3, item_river_root = 1}},
        {"item_potion_disease", {special_1 = 2,special_2 = 2, item_river_root = 1}},
        {"item_potion_nether", {special_1 = 1, item_river_stem = 2, item_herb_butsu = 2}},
        {"item_essence_bees", {special_1 = 2, special_2 = 1, special__3 = 1}},
        {"item_potion_acid", {special_1 = 2, special_2 = 2, item_river_stem = 2}}
    }

    --recipes that use special herbs. A bit more complicated
    --[[

    --]]

    local myMaterials = {}
    local itemTable = {}

    --loop through inventory slots
    for i = 0,5 do
        local item = caster:GetItemInSlot(i)    --get the item in the slot
        if item ~= nil then --if the slot is not empty
            local itemName = item:GetName() --get the item's name
            print(i, itemName)  --debug
            --loop through list of possible ingredients to see if the inventory item is one
            for i,herbName in pairs(herbTable) do
                if itemName == herbName then  --if the item is an herb ingredient
                    print("Adding to table", itemName)
                    if myMaterials[itemName] == nil then  --add it to our internal list
                        myMaterials[itemName] = 0
                    end
                    myMaterials[itemName] = myMaterials[itemName] + 1   --increment the count
                    table.insert(itemTable, item)
                end
            end
        else
            print(i, "empty")  --more debug, print empty slot
        end
    end

    print("Check for match")
    --check if player materials matches any recipes
    for i,value in pairs(recipeTable) do  --loop through the recipe table
        local recipeName = recipeTable[i][1]    --get the name of the recipe
        local recipeIngredients = recipeTable[i][2] --get the items needed for the recipe
        if CompareTables(recipeIngredients, myMaterials) then    --if a recipe matches
            print("Match!", i)
            local newItem = CreateItem(recipeName, nil, nil)   --create the resulting item
            for i,removeMe in pairs(itemTable) do   --delete the materials
                caster:RemoveItem(removeMe)
            end
            caster:AddItem(newItem) --add the new item
            return  --end the function, only one item per mix
        end
    end


    print("Check for special match")
    local specialTable = {
        {"item_herb_orange", 0},
        {"item_herb_purple", 0},
        {"item_herb_yellow", 0},
        {"item_herb_blue", 0}
    }

        specialTable[1][2] = myMaterials["item_herb_orange"]
        specialTable[2][2] = myMaterials["item_herb_purple"]
        specialTable[3][2] = myMaterials["item_herb_yellow"]
        specialTable[4][2] = myMaterials["item_herb_blue"]

    for key,val in pairs (specialTable) do
        print(val[1], val[2])
        if val[2] == nil then
            specialTable[key][2] = 0
        end
    end

    print("sort it!")
    table.sort(specialTable, compareHelper)

    for key,val in pairs (specialTable) do
        print(val[1], val[2])
    end

    --replace herb names with special_X
    myMaterials["special_1"] = specialTable[1][2]
    myMaterials[specialTable[1][1]] = nil
    myMaterials["special_2"] = specialTable[2][2]
    myMaterials[specialTable[2][1]] = nil
    myMaterials["special_3"] = specialTable[3][2]
    myMaterials[specialTable[3][1]] = nil
    myMaterials["special_4"] = specialTable[4][2]
    myMaterials[specialTable[4][1]] = nil

    for key,val in pairs (myMaterials) do
        if val == 0 then
            myMaterials[key] = nil
        end
    end

    print("Check for match")
    --check if player materials matches any recipes
    for i,value in pairs(recipeTable) do  --loop through the recipe table
        local recipeName = recipeTable[i][1]    --get the name of the recipe
        local recipeIngredients = recipeTable[i][2] --get the items needed for the recipe
        if CompareTables(recipeIngredients, myMaterials) then    --if a recipe matches
            print("Match!", i)
            local newItem = CreateItem(recipeName, nil, nil)   --create the resulting item
            for i,removeMe in pairs(itemTable) do   --delete the materials
                caster:RemoveItem(removeMe)
            end
            caster:AddItem(newItem) --add the new item
            return  --end the function, only one item per mix
        end
    end

end

--Compares two tables to see if they have the same values
function CompareTables(table1, table2)
    print("Comparing tables")
    if type(table1) ~= "table" or type(table2) ~= "table" then
        return false
    end

    for key,value in pairs(table1) do
        print(key, table1[key], table2[key])
        if table2[key] == nil then
            return false
        elseif table2[key] ~= table1[key] then
            return false
        end
    end

    print("check other table, just in case")

    for key,value in pairs(table2) do
        print(key, table2[key], table1[key])
        if table1[key] == nil then
            return false
        elseif table1[key] ~= table2[key] then
            return false
        end
    end

    print("Match!")
    return true
end

function compareHelper(a,b)
    return a[2] > b[2]
end

function SwapAbilities(unit, ability1, ability2, enable1, enable2)

    --swaps ability1 and ability2, disables 1 and enables 2
    print("swap", ability1:GetName(), ability2:GetName() )
    unit:SwapAbilities(ability1:GetName(), ability2:GetName(), enable1, enable2)
    ability1:SetHidden(enable2)
    ability2:SetHidden(enable1)
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

--Hunter Ability Functions

function EnsnareUnit(keys)
    local caster = keys.caster
    local target = keys.target
    local targetName = target:GetName()
    local dur = 8.0 --default duration for anything besides heros
    if (string.find(targetName,"hero") ~= nil) then --if the target's name includes "hero"
        dur = 3.5   --then we use the hero only duration
	elseif string.find(target:GetUnitName(), "hawk") then --if the target's name includes "hawk"
	target:RemoveModifierByName("modifier_hawk_flight")
	target:RemoveAbility("ability_hawk_flight")
	end
    target:AddNewModifier(caster, nil, "modifier_meepo_earthbind", { duration = dur})
    --target:AddNewModifier(caster, nil, "modifier_ensnare", { duration = dur})   --I could call a modifier applier, but Valve should fix this soon
end

function TrackUnit(keys)
    local ability = keys.ability
    --print("level required to upgrade: "..ability:GetHeroLevelRequiredToUpgrade())
    local caster = keys.caster
    local target = keys.target
    local targetName = target:GetName()
    local dur = tonumber(keys.Duration)
    if (string.find(targetName,"hero") == nil) then --if the target's name does not include "hero", ie an animal
        dur = 30.0
    end

    local dummySpotter = CreateUnitByName("dummy_spotter", target:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
    dummySpotter:SetDayTimeVisionRange(200)
    dummySpotter:SetNightTimeVisionRange(200)
    dummySpotter.startTime = GameRules:GetGameTime()
    dummySpotter.duration = dur
    dummySpotter.target = target
    dummySpotter:SetContextThink("dummy_spotter_thinker"..dummySpotter:GetEntityIndex(), MoveDummySpotter, 0.1)
end

function DysenteryTrackUnit(keys)
    local ability = keys.ability
    --print("level required to upgrade: "..ability:GetHeroLevelRequiredToUpgrade())
    local caster = keys.caster
    local target = keys.target
    local targetName = target:GetName()
    local dur = tonumber(keys.Duration)
    local trailFadeTime = tonumber(keys.TrailFadeTime)
    caster.dysenteryStartTime = GameRules:GetGameTime()
    caster.dysenteryDur = dur
    caster.dysenteryParticleTable = {}
    caster.dysenteryTarget = target
    caster:SetContextThink(target:GetEntityIndex().."dysenteryThink", DysenteryTrackThink, 0.75)
    caster:SetContextThink(target:GetEntityIndex().."dysenteryParticleThink", DysenteryParticleThink, trailFadeTime)
end

function DysenteryTrackThink(caster)
    local target = caster.dysenteryTarget
    print("create track")
    local thisParticle = ParticleManager:CreateParticleForPlayer("particles/econ/courier/courier_trail_fungal/courier_trail_fungal_f.vpcf", PATTACH_ABSORIGIN, caster, caster:GetPlayerOwner())
    table.insert(caster.dysenteryParticleTable, thisParticle)
    ParticleManager:SetParticleControl(thisParticle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(thisParticle, 15, Vector(139,69,19))

    if (GameRules:GetGameTime() - caster.dysenteryStartTime) >= caster.dysenteryDur then
        return nil
    end

    return 0.75
end

function DysenteryParticleThink(caster)
    --kills the first particle of the table, then deletes it from table, shifting other values down
    particle = caster.dysenteryParticleTable[1]
    if particle == nil then
        return nil
    end
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
    table.remove(caster.dysenteryParticleTable, 1)
    return 0.75
end

function MoveDummySpotter(dummySpotter)
    if (dummySpotter.target:IsAlive() == false) then
        print("Creature with dummy spotter died, removing it")
        dummySpotter:ForceKill(true)
        return nil
    end
    dummySpotter:MoveToPosition(dummySpotter.target:GetAbsOrigin())
    if (GameRules:GetGameTime() - dummySpotter.startTime) >= dummySpotter.duration then
        dummySpotter:ForceKill(true)
        --print("spotter is kill")
        return nil
    end
    return 0.1
end

function EnduranceSuccess(keys)
    attacker = keys.attacker
    caster = keys.caster

    local damage = attacker:GetAverageTrueAttackDamage()
    local block = 8
    if damage - block < 3 then
        block = damage - 3
    end

    caster:SetHealth(caster:GetHealth() + block)
end

-- Mage Ability Functons


function SpawnMageFire(keys)
    local caster = keys.caster
    local spawnPosition = caster:GetAbsOrigin() + (caster:GetForwardVector() * 150)

    CreateUnitByName("npc_building_fire_mage",
                        spawnPosition,
                        false,
                        caster,
                        caster,
                        caster:GetTeam())
end

function ReduceFood(keys)
    local target = keys.target
    local reduction = RandomInt(0,2)

    for i=0,5 do
        local item = target:GetItemInSlot(i)
        if item ~= nil then
            local itemName = target:GetItemInSlot(i):GetName()
            if itemName == "item_meat_cooked" then
                local charges = item:GetCurrentCharges()
                local newCharges = charges-reduction
                if newCharges < 1 then
                    item:SetCurrentCharges(1)
                else
                    item:SetCurrentCharges(newCharges)
                end
                break
            end
        end
    end
end

function Metronome(keys)
    local caster = keys.caster
    local target = keys.target
    local targetPosition = target:GetAbsOrigin()
    local dieroll = RandomInt(0, 99)

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
end

function MetronomeSpell(dummy)
    local target = dummy.tar
    local duration = dummy.dur
    local caster = dummy.cas

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

function PullCloser(keys)
    local caster = keys.caster
    local casterPosition = caster:GetAbsOrigin()
    local target = keys.target
    local targetPosition = target:GetAbsOrigin()

    local pull = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_static_link_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(pull,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))

    local direction = casterPosition - targetPosition
    local vec = direction:Normalized() * 30.0
    target:SetAbsOrigin(targetPosition + vec)
    FindClearSpaceForUnit(target,target:GetAbsOrigin(),true)

    -- disabled particle, stays infinitely in current implementation, causing huge lag
    ParticleManager:DestroyParticle(pull,false)
end

function ChainLightning(keys)
    local caster = keys.caster
    local target = keys.target
    local teamnumber = caster:GetTeamNumber()
    local bounces = keys.Bounces
    local radius = keys.BounceRadius
    local dmg = keys.Damage
    local dmgFactor = keys.BounceDamageFactor
    local hitUnits = {}

    -- hit initial target
    local damageTable = {victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL}
    ApplyDamage(damageTable)
    table.insert(hitUnits, target)
    local lightningBolt = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))

    for i=0,bounces do
        targetPosition = target:GetAbsOrigin()
        local units = FindUnitsInRadius(teamnumber,
                                    targetPosition,
                                    nil,
                                    radius,
                                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                                    DOTA_UNIT_TARGET_ALL,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)

        for _,unit in pairs(units) do
            if unit:IsAlive() then
                print("unit found")
                local alreadyHit = 0

                for j = 0, #hitUnits do
                    if hitUnits[j] == unit then
                        alreadyHit = 1
                    end
                end

                if alreadyHit == 0 then
                    local origin = target
                    target = unit
                    dmg = dmg*dmgFactor

                    local damageTable = {victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL}
                    ApplyDamage(damageTable)
                    table.insert(hitUnits, target)
                    lightningBolt = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, origin)
                    ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))
                    break
                end
            end
        end
    end
end

-- Scout Ability Functions

function EnemyRadar(keys)
    local caster = keys.caster
    local range = keys.Range
    local casterPosition = caster:GetAbsOrigin()
    local teamnumber = caster:GetTeamNumber()

    local units = FindUnitsInRadius(teamnumber,
                                casterPosition,
                                nil,
                                range,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_ALL,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_ANY_ORDER,
                                false)

    local redVal = 0
    local greenVal = 0
    local blueVal = 0

    for _, unit in pairs(units) do
        if unit:IsHero() then
            redVal = 255
        elseif unit:IsCreature() then
            blueVal = 255
        end

        local thisParticle = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, caster:GetOwner())
        ParticleManager:SetParticleControl(thisParticle, 0, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(thisParticle, 1, Vector(redVal, greenVal, blueVal))
        PingMap(caster:GetPlayerID(),unit:GetAbsOrigin(),redVal,greenVal,blueVal)
        ParticleManager:ReleaseParticleIndex(thisParticle)
        unit:EmitSound("General.Ping")   --may be deafening
    end
end

function WardArea(keys)
    local caster = keys.caster
    local radius = keys.Radius
    local abilityLevel = caster:FindAbilityByName("ability_scout_wardthearea"):GetLevel()
    local wards = abilityLevel + 1
    local casterPosition = caster:GetAbsOrigin()
    local team = caster:GetTeam()
    
    for i = 1, wards do
        local randomLocation = casterPosition + RandomVector(RandomInt(0,800))
        local ward = CreateUnitByName("scout_ward",randomLocation,true,nil,nil,team)
        local lifetime = ward:FindAbilityByName("ability_scout_ward_lifetime")
        lifetime:SetLevel(abilityLevel)
    end
end

function PlaceWard(keys)
    local caster = keys.caster
    local point = keys.target_points[1]
    local team = caster:GetTeam()
    local ward = CreateUnitByName("scout_ward",point,true,nil,nil,team)
    local lifetime = ward:FindAbilityByName("ability_scout_ward_lifetime")
    lifetime:SetLevel(600)
end

-- Beast Master Ability Functions

function TamePet(keys)
    local caster = keys.caster
    local target = keys.target
    local unitName = target:GetUnitName()
    local owner = caster:GetOwner()
    local maxPets = keys.MaxPets
    local growSpeed = keys.Growth
    local growAbility = "ability_beastmaster_pet_grow1"

    if growSpeed == "Fast" then
        growAbility = "ability_beastmaster_pet_grow1fast"
    end

    if (unitName == "npc_creep_fawn") or (unitName == "npc_creep_wolf_pup") or (unitName == "npc_creep_bear_cub") then
        if target:FindAbilityByName("ability_pet") == nil then
            target.vOwner = owner
            target:AddAbility("ability_pet")
            target:AddAbility(growAbility)
            target:FindAbilityByName("ability_pet"):SetLevel(1)
            target:FindAbilityByName(growAbility):SetLevel(1)
            SetAbilityVisibility(caster,"ability_beastmaster_pet_release", true)
            SetAbilityVisibility(caster,"ability_beastmaster_pet_follow", true)
            SetAbilityVisibility(caster,"ability_beastmaster_pet_stay", true)
        end
    end

    local pets = FindPets(keys)

    if (#pets) >= maxPets then
        print("Maximum amount of pets reached, removing tame pet skill!")
        SetAbilityVisibility(caster, "ability_beastmaster_tamepet", false)
        SetAbilityVisibility(caster, "ability_beastmaster_tamepet2", false)
    end
end

function FindPets(keys)
    local caster = keys.caster
    local owner = caster:GetOwner()
    if owner == nil then
        print("using different owner field")
        owner = caster.vOwner
    end
    local teamnumber = caster:GetTeamNumber()
    local pets = {}

    local units = FindUnitsInRadius(teamnumber,
                                    Vector(0,0,0),
                                    nil,
                                    FIND_UNITS_EVERYWHERE,
                                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                    DOTA_UNIT_TARGET_CREEP,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)
    for _,unit in pairs(units) do
        if unit:HasAbility("ability_pet") and unit.vOwner == owner then
            print("Found a pet!")
            table.insert(pets,unit)
        end
    end

    if pets == {} then
        print("Failed to find pet")
    end

    return pets
end

function GrowPet(keys)
    local pet = keys.caster
    local name = pet:GetUnitName()
    local team = pet:GetTeam()
    local owner = pet.vOwner
    if owner then --only grow if the animal has an owner, wild animals never mature (we can change this, if necessary)
        local hero = owner:GetAssignedHero()
        local heroIsSub = hero:HasAbility("ability_beastmaster_tamepet2")
        local growAbility = "ability_beastmaster_pet_grow2"

        if heroIsSub then
            growAbility = "ability_beastmaster_pet_grow2fast"
        end

        local isBaby = false
        if pet:HasAbility("ability_beastmaster_pet_grow1") or pet:HasAbility("ability_beastmaster_pet_grow1fast") then
            isBaby = true
        end

        local GrowTable = {
                            {"npc_creep_fawn","npc_creep_elk_pet"},
                            {"npc_creep_wolf_pup","npc_creep_wolf_jungle"},
                            {"npc_creep_bear_cub","npc_creep_bear_jungle"},
                            {"npc_creep_elk_pet","npc_creep_elk_adult"},
                            {"npc_creep_wolf_jungle","npc_creep_wolf_jungle_adult"},
                            {"npc_creep_bear_jungle","npc_creep_bear_jungle_adult"}}


        print("Pet is growing into its next stage")

        for _,v in pairs(GrowTable) do
            if v[1] == name then
                local location = pet:GetAbsOrigin()
                pet:RemoveSelf()
                local newPet = CreateUnitByName(v[2],location, true,nil,nil,team)
                newPet.vOwner = owner
                newPet:AddAbility("ability_pet")
                newPet:AddAbility("ability_beastmaster_pet_sleep")
                newPet:FindAbilityByName("ability_beastmaster_pet_sleep"):SetLevel(1)
                if isBaby then
                    newPet:AddAbility(growAbility)
                    newPet:FindAbilityByName(growAbility):SetLevel(1)
                    SetAbilityVisibility(hero, "ability_beastmaster_pet_sleep", true)
                    SetAbilityVisibility(hero, "ability_beastmaster_pet_attack", true)
                end
                break
            end
        end
    end
end

function PetCommand(keys)
    local caster = keys.caster
    local command = keys.Command
    local petNumber = 1

    local pets = FindPets(keys)
    local pet = pets[petNumber]

    if pet ~= nil then
        print(command)
        if command == "release" then
            ReleasePet(caster,pet)
        elseif command == "follow" then
            pet:MoveToNPC(caster)
        elseif command == "stay" then
            pet:Stop()
        elseif command == "sleep" then
            sleep = pet:FindAbilityByName("ability_pet_sleep")
            if sleep ~= nil then
                sleep:SetLevel(1)
                sleep:CastAbility()
            end
        elseif command == "attack" then
            pet:MoveToPositionAggressive(caster:GetAbsOrigin())
        end
    end
end

function PetDeath(keys)
    local pet = keys.caster
    local owner = pet.vOwner
    local hero = owner:GetAssignedHero()

    SetAbilityVisibility(hero,"ability_beastmaster_tamepet", true)
    SetAbilityVisibility(hero,"ability_beastmaster_tamepet2", true)
    SetAbilityVisibility(hero,"ability_beastmaster_pet_release", false)
    SetAbilityVisibility(hero,"ability_beastmaster_pet_follow", false)
    SetAbilityVisibility(hero,"ability_beastmaster_pet_stay", false)
    SetAbilityVisibility(hero,"ability_beastmaster_pet_sleep", false)
    SetAbilityVisibility(hero,"ability_beastmaster_pet_attack", false)

    -- check if BM is within 600 range
    local distance = pet:GetRangeToUnit(hero)
    print(distance)

    if distance <= 600 then
        if hero:HasAbility("ability_beastmaster_empathicrage") then
            local item = CreateItem("item_empathicrage_modifier_applier", hero, hero)
            item:ApplyDataDrivenModifier(hero, hero, "modifier_empathicrage", {duration=10})
        end
    end
end

function ReleasePet(caster,pet)
    print("Releasing pet")
    pet:SetTeam(DOTA_TEAM_NEUTRALS)
    SetAbilityVisibility(caster,"ability_beastmaster_tamepet", true)
    SetAbilityVisibility(caster,"ability_beastmaster_tamepet2", true)
    SetAbilityVisibility(caster,"ability_beastmaster_pet_release", false)
    SetAbilityVisibility(caster,"ability_beastmaster_pet_follow", false)
    SetAbilityVisibility(caster,"ability_beastmaster_pet_stay", false)
    SetAbilityVisibility(caster,"ability_beastmaster_pet_sleep", false)
    SetAbilityVisibility(caster,"ability_beastmaster_pet_attack", false)
end

function HealPet(keys)
    local caster = keys.caster
    local maxHealth = caster:GetMaxHealth()
    local healAmount = maxHealth * 0.025

    caster:Heal(healAmount,nil)
end

function SetSpawnChance(keys)
    local caster = keys.caster
    local target = keys.target
    local level = caster:GetLevel()
    local bonus = 0
    local maxLevel = 4
    -- shitty way of determining whether the BM is pack leader form
    -- easier than copy pasting the massive spirit of the beast ability and only changing one function argument
    local heroIsSub = caster:HasAbility("ability_beastmaster_tamepet2")

    if heroIsSub then
        bonus = 5
        maxLevel = 9
    end

    if keys.Remove == "1" then
        level = 0
    end

    level = level + bonus
    if level > maxLevel then
        level = maxLevel
    end

    target:SetModifierStackCount("modifier_spawn_chance",nil,level)
end

function AttractAnimal(keys)
    local caster = keys.caster
    local target = keys.target
    local position = caster:GetAbsOrigin() + RandomVector(RandomInt(0,100))

    target:MoveToPositionAggressive(position)
end

function CallToBattle(keys)
    local caster = keys.caster
    local pets = FindPets(keys)
    local dur = keys.Duration

    for _,pet in pairs(pets) do
        local item = CreateItem("item_calltobattle_modifier_applier", caster, caster)
        item:ApplyDataDrivenModifier(caster, pet, "modifier_calltobattle", {duration=dur})
    end
end

function FleaAttack(keys)
    local caster = keys.caster
    local level = caster:GetLevel()
    local casterPosition = caster:GetAbsOrigin()
    local teamnumber = caster:GetTeamNumber()
    local particle = keys.Particle
    local cooldown = 0

    -- hero level, cooldown
    local cooldownValues = {
        {1, 1.0},
        {2, 0.95},
        {3, 0.90},
        {5, 0.85},
        {8, 0.80},
        {13,0.75},
        {21,0.70},
        {30,0.70}
    }

    -- get cooldown time
    for i = 1, #cooldownValues do
        local stats = cooldownValues[i]
        if level < stats[1] then
            break
        else
            cooldown = stats[2]
        end
    end

    -- only run if flea attack is off cooldown
    if not caster:HasModifier("modifier_fleacooldown") then
        local target = nil

        -- check for valid targets
        local units = FindUnitsInRadius(teamnumber,
                                casterPosition,
                                nil,
                                400,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_ALL,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_ANY_ORDER,
                                false)
        -- select random target
        local dieRoll = RandomInt(1,#units)
        local target = units[dieRoll]

        if target ~= nil then
            -- fire flea attack projectile
            local info =
            {
                Ability = keys.ability,
                Target = target,
                Source = caster,
                EffectName = particle,
                vSpawnOrigin = casterPosition,
                bProvidesVision = false,
                bDeleteOnHit = true,
                bDodgeable = true,
                flExpireTime = 7.0,
                iMoveSpeed = 1000
            }
            projectile = ProjectileManager:CreateTrackingProjectile(info)
            -- track which target has been hit
            caster.fleaTarget = target

            -- apply cooldown modifier
            local item = CreateItem("item_fleaattackcooldown_modifier_applier", caster, caster)
            item:ApplyDataDrivenModifier(caster, caster, "modifier_fleacooldown", {duration=cooldown})
        end
    end
end

function FleaAttackDamage(keys)
    local caster = keys.caster
    local target = keys.caster.fleaTarget
    local level = caster:GetLevel()

    local dmg = 0
    local dps = 0
    local dpsDur = 2

    local attackValues = {
        {1, 12, 3.0},
        {2, 13, 3.1},
        {3, 14, 3.2},
        {5, 15, 3.3},
        {8, 16, 3.4},
        {13,19, 3.5},
        {21,24, 3.6},
        {30,28, 3.7}
    }

    -- get damage values
    for i = 1, #attackValues do
        local stats = attackValues[i]
        if level < stats[1] then
            break
        else
            dmg = stats[2]
            dps = stats[3]
        end
    end

    -- apply damage
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL
    }
    ApplyDamage(damageTable)

    -- apply DPS
    target.caster = caster
    target.duration = dpsDur
    target.startTime = GameRules:GetGameTime()
    target.dps = dps
    target:SetContextThink("flea_dps", FleaAttackDPS, 1.0)
end

function FleaAttackDPS(target)
    if (GameRules:GetGameTime() - target.startTime) >= target.duration then
        return nil
    else
        local damageTable = {
            victim = target,
            attacker = target.caster,
            damage = target.dps,
            damage_type = DAMAGE_TYPE_MAGICAL
        }
        ApplyDamage(damageTable)
    end
    return 1.0
end

function Shapeshift(keys)
    local caster = keys.caster
    local form = keys.Form

    local formSkills = {
        {"Normal",nil,{}},
        {"Bear","modifier_bearform",{"ability_beastmaster_bash","ability_beastmaster_slam"}},
        {"Wolf","modifier_wolfform",{"ability_beastmaster_howl","ability_beastmaster_criticalstrike"}},
        {"Elk","modifier_elkform",{"ability_beastmaster_magicimmunity","ability_beastmaster_ram"}}
    }

    -- modify skill visibilities, remove modifiers from other forms
    for _,skillList in pairs(formSkills) do
        local isVisible = (form == skillList[1])
        local modifier = skillList[2]
        if form ~= skillList[1] and modifier ~= nil then
            caster:RemoveModifierByName(modifier)
        end
        for _,skill in pairs(skillList[3]) do
            SetAbilityVisibility(caster, skill, isVisible)
        end
    end
end

function RamTarget(keys)
    local caster = keys.caster
    local target = keys.target
    local damage = keys.Damage
    local stunDuration = keys.StunDuration
    local casterPosition = caster:GetAbsOrigin()
    local targetPosition = target:GetAbsOrigin()
    local visible = caster:CanEntityBeSeenByMyTeam(target)
    local teamnumber = caster:GetTeamNumber()
    local hitUnits = {}

    if visible then
        local direction = targetPosition - casterPosition
        local vec = direction:Normalized() * 30
        caster:SetAbsOrigin(casterPosition + vec)
        FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),true)

        -- check collision
        local units = FindUnitsInRadius(teamnumber,
                                casterPosition,
                                nil,
                                100,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_ANY_ORDER,
                                false)
        for _,unit in pairs(units) do
            local alreadyHit = false
            for i = 1, #hitUnits do
                if hitUnits[i] == unit then
                    alreadyHit = true
                end
            end

            if alreadyHit == false then
                local damageTable = {
                    victim = unit,
                    attacker = caster,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_MAGICAL
                }
                ApplyDamage(damageTable)
                unit:AddNewModifier(caster, nil, "modifier_stunned", { duration = stunDuration})
                table.insert(hitUnits, unit)
                target:RemoveModifierByName("modifier_charged")
                local ram = caster:FindAbilityByName("ability_beastmaster_ram")
                ram:EndChannel(true)
            end
        end
    end
end

-- Thief Ability Functions

function Teleport(keys)
    local caster = keys.caster
    local point = keys.target_points[1]

    local dummyTarget = CreateUnitByName("dummy_caster_metronome", point, false, nil, nil,DOTA_TEAM_NEUTRALS)
    local visible = caster:CanEntityBeSeenByMyTeam(dummyTarget)

    if visible then
        FindClearSpaceForUnit(caster, point, false)
    else
        local tp = caster:FindAbilityByName("ability_thief_teleport")
        tp:EndCooldown()
        local mana = tp:GetManaCost(1)
        caster:GiveMana(mana)
    end
end

function DieOnEnemyCollision(keys)
    local caster = keys.caster
    local teamnumber = caster:GetTeamNumber()
    local casterPosition = caster:GetAbsOrigin()
    local radius = keys.Radius

    local units = FindUnitsInRadius(teamnumber,
                                    casterPosition,
                                    nil,
                                    radius,
                                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                                    DOTA_UNIT_TARGET_HERO,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)
    local count = 0
    for _ in pairs(units) do
        count = count + 1
    end
    if count > 0 then
        caster:ForceKill(true)
    end
end

function Jump(keys)
    local caster = keys.caster
    local point = keys.target_points[1]

    local dummyTarget = CreateUnitByName("dummy_caster_metronome", point, false, nil, nil,DOTA_TEAM_NEUTRALS)

    FindClearSpaceForUnit(caster, point, false)
end

-- Priest Ability Functions

function MixHeat(keys)
    local caster = keys.caster
    local target = keys.target

    local heat1 = caster:GetModifierStackCount("modifier_heat_passive", nil)
    local heat2 = target:GetModifierStackCount("modifier_heat_passive", nil)

    newHeat = (heat1+heat2)/2

    caster:SetModifierStackCount("modifier_heat_passive", nil, newHeat)
    target:SetModifierStackCount("modifier_heat_passive", nil, newHeat)
end

function MixEnergy(keys)
    local caster = keys.caster
    local target = keys.target

    local energy1 = caster:GetMana()
    local energy2 = target:GetMana()

    local newMana = (energy1+energy2)/2

    caster:SetMana(newMana)
    target:SetMana(newMana)
end

function MixHealth(keys)
    local caster = keys.caster
    local target = keys.target

    local health1 = caster:GetHealth()
    local health2 = target:GetHealth()

    local newHealth = (health1+health2)/2

    caster:SetHealth(newHealth)
    target:SetHealth(newHealth)
end

function CureAll(keys)
    local caster = keys.caster
    local target = keys.target

    target:RemoveModifierByName("modifier_lizard_slow")
    target:RemoveModifierByName("modifier_disease1")
    target:RemoveModifierByName("modifier_disease2")
    target:RemoveModifierByName("modifier_disease3")
end

--Omnicure purges all units in a radius around the caster. 
--NOTE: will appear not to function due to debuffs acting strangely
function Omnicure(keys)
    local caster = keys.caster
    local radius = keys.Radius
    local teamnumber = caster:GetTeamNumber()

    targetPosition = caster:GetAbsOrigin()
    local units = FindUnitsInRadius(teamnumber, targetPosition, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,unit in pairs(units) do
            print("unit found")
            unit:RemoveModifierByName("modifier_lizard_slow")
            unit:RemoveModifierByName("modifier_disease1")
            unit:RemoveModifierByName("modifier_disease2")
            unit:RemoveModifierByName("modifier_disease3")
    end
end

--Based on pucks orb. 
function CastAngelicElementalOrb( keys )
    
    local caster    = keys.caster
    local ability   = keys.ability
    local point     = keys.target_points[1]

    local radius            = keys.radius
    local maxDist           = keys.max_distance
    local orbSpeed          = keys.orb_speed
    local visionRadius      = keys.orb_vision
    local visionDuration    = keys.vision_duration
    local numExtraVisions   = keys.num_extra_visions

    local travelDuration    = maxDist / orbSpeed
    local extraVisionInterval = travelDuration / numExtraVisions

    local casterOrigin      = caster:GetAbsOrigin()
    local targetDirection   = ( ( point - casterOrigin ) * Vector(1,1,0) ):Normalized()
    local projVelocity      = targetDirection * orbSpeed

    local startTime     = GameRules:GetGameTime()
    local endTime       = startTime + travelDuration

    local numExtraVisionsCreated = 0
    local isKilled      = false

    -- Create linear projectile
    local projID = ProjectileManager:CreateLinearProjectile( {
        Ability             = ability,
        EffectName          = keys.proj_particle,
        vSpawnOrigin        = casterOrigin,
        fDistance           = maxDist,
        fStartRadius        = radius,
        fEndRadius          = radius,
        Source              = caster,
        bHasFrontalCone     = false,
        bReplaceExisting    = false,
        iUnitTargetTeam     = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        iUnitTargetFlags    = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType     = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime         = endTime,
        bDeleteOnHit        = false,
        vVelocity           = projVelocity,
        bProvidesVision     = true,
        iVisionRadius       = visionRadius,
        iVisionTeamNumber   = caster:GetTeamNumber(),
    } )

    --print("projID = " .. projID)

    -- Create sound source
    local thinker = CreateUnitByName( "npc_dota_thinker", casterOrigin, false, caster, caster, caster:GetTeamNumber() )
    ability:ApplyDataDrivenModifier( caster, thinker, keys.proj_modifier, { duration = -1 } )

    --
    -- Track the projectile
    --
    Timers:CreateTimer( function ( )
        
        local elapsedTime   = GameRules:GetGameTime() - startTime
        local currentOrbPosition = casterOrigin + projVelocity * elapsedTime
        currentOrbPosition = GetGroundPosition( currentOrbPosition, thinker )

        -- Update position of the sound source
        thinker:SetAbsOrigin( currentOrbPosition )

        -- Try to create new extra vision
        if elapsedTime > extraVisionInterval * (numExtraVisionsCreated + 1) then
            ability:CreateVisibilityNode( currentOrbPosition, visionRadius, visionDuration )
            numExtraVisionsCreated = numExtraVisionsCreated + 1
        end

        -- Remove if the projectile has expired
        if elapsedTime >= travelDuration or isKilled then
            thinker:RemoveModifierByName( keys.proj_modifier )

            return nil
        end

        return 0.03

    end )

end

function StopSound( keys )
        StopSoundEvent( keys.sound_name, keys.target ) 
end

function HealingWave(keys)
    local caster = keys.caster
    local target = keys.target
    local teamnumber = caster:GetTeamNumber()
    local bounces = keys.Bounces
    local radius = keys.BounceRadius
    local healing = keys.Healing
    local healFactor = keys.BounceHealingFactor
    local healedUnits = {}

    -- heal initial target
    target:Heal(healing,caster)
    table.insert(healedUnits, target)
    local healingWave = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(healingWave,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))

    for i=0,bounces do
        targetPosition = target:GetAbsOrigin()
        local units = FindUnitsInRadius(teamnumber,
                                    targetPosition,
                                    nil,
                                    radius,
                                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                    DOTA_UNIT_TARGET_ALL,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)

        for _,unit in pairs(units) do
            if unit:IsAlive() then
                print("unit found")
                local alreadyHealed = 0

                for j = 0, #healedUnits do
                    if healedUnits[j] == unit then
                        alreadyHealed = 1
                    end
                end

                if alreadyHealed == 0 then
                    local origin = target
                    target = unit
                    healing = healing*healFactor
                    target:Heal(healing,caster)
                    table.insert(healedUnits, target)
                    lightningBolt = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, origin)
                    ParticleManager:SetParticleControl(healingWave,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))
                    break
                end
            end
        end
    end
end

--Omnicure purges all units in a radius around the caster. 
--NOTE: Purge is working but not for poison? Cureall is the same way
function Omnicure(keys)
    local caster = keys.caster
    local radius = keys.Radius
    local teamnumber = caster:GetTeamNumber()

    targetPosition = caster:GetAbsOrigin()
    local units = FindUnitsInRadius(teamnumber, targetPosition, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,unit in pairs(units) do
            print("unit found")
            unit:RemoveModifierByName("modifier_lizard_slow")
            unit:RemoveModifierByName("modifier_disease1")
            unit:RemoveModifierByName("modifier_disease2")
            unit:RemoveModifierByName("modifier_disease3")
    end
end

--utility functions
function SwapSpellBook(keys)
    local caster = keys.caster
    local book = keys.activeBook
    local class = caster:GetClassname()
    local book1 = {}
    local book2 = {}

    mage_book1Spells = {
        "ability_mage_swap1",
        "ability_mage_nulldamage",
        "ability_mage_pumpup",
        "ability_mage_magefire",
        "ability_mage_reducefood"
    }
    mage_book2Spells = {
        "ability_mage_swap2",
        "ability_mage_negativeblast",
        "ability_mage_flamespray",
        "ability_mage_depress",
        "ability_mage_metronome"
    }
    priest_book1Spells = {
        "ability_priest_swap1",
        "ability_priest_theglow",
        "ability_priest_cureall",
        "ability_priest_resistall",
        "ability_priest_pumpup",
        "ability_priest_sprayhealing",
    }
    priest_book2Spells = {
        "ability_priest_swap2",
        "ability_priest_pacifyingsmoke",
        "ability_priest_mixheat",
        "ability_priest_mixenergy",
        "ability_priest_mixhealth",
    }

    local Book1Visibility = (book == 2)
    local Book2Visibiltiy = (book == 1)

    if class == MAGE then
        book1 = mage_book1Spells
        book2 = mage_book2Spells
    elseif class == PRIEST then
        book1 = priest_book1Spells
        book2 = priest_book2Spells
    end

    for _,spell in pairs(book1) do
        SetAbilityVisibility(caster, spell, Book1Visibility)
    end
    for _,spell in pairs(book2) do
        SetAbilityVisibility(caster, spell, Book2Visibility)
    end
end

function callModApplier( caster, modName, abilityLevel)
    if abilityLevel == nil then
        abilityLevel = 1
    end
    local applier = modName .. "_applier"
    local ab = caster:FindAbilityByName(applier)
    if ab == nil then
        caster:AddAbility(applier)
        ab = caster:FindAbilityByName( applier )
        ab:SetLevel(abilityLevel)
        print("trying to cast ability ", applier, "level", ab:GetLevel())
    end
    caster:CastAbilityNoTarget(ab, -1)
    caster:RemoveAbility(applier)
end

function RestoreMana(keys)
    local target = keys.target
    if target == nil then
        target = keys.caster
    end
    target:GiveMana(keys.ManaRestored)
end

function RemoveMana(keys)
    local target = keys.target
    local manaloss = keys.ManaRemoved

    if target == nil then
        target = keys.caster
    end

    local mana = target:GetMana()
    target:SetMana(mana-manaloss)
end

function ToggleAbility(keys)
    local caster = keys.caster

    if caster:HasAbility(keys.Ability) then
        local ability = caster:FindAbilityByName(keys.Ability)
        if ability:IsActivated() == true then
            ability:SetActivated(false)
        else
            ability:SetActivated(true)
        end
    end
end

function SetAbilityVisibility(unit, abilityName, visibility)
    local ability = unit:FindAbilityByName(abilityName)
    local hidden = (visibility == false)
    if ability ~= nil and unit ~= nil then
        ability:SetHidden(hidden)
    end
end

function KillDummyUnit(keys)
    local unitName = keys.UnitName
    local caster = keys.caster
    local teamnumber = caster:GetTeamNumber()
    local casterPosition = caster:GetAbsOrigin()

    local units = FindUnitsInRadius(teamnumber,
                                    casterPosition,
                                    nil,
                                    0,
                                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                    DOTA_UNIT_TARGET_ALL,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)

    for _,unit in pairs(units) do
        if unit:GetName() == unitName then
            unit:ForceKill(true)
        end
    end
end

function PackUp(keys)
    local building = keys.caster
    local buildingName = building:GetUnitName()

    local stringParse = string.gmatch(buildingName, "%a+")
    local itemName = "item"
    local str = stringParse()
    while str ~= nil do
        if str ~= "npc" then
            itemName = itemName .. "_" .. str
        end
        if str == "building" then
            itemName = itemName .. "_kit"
        end
        str = stringParse()
    end
    print("Packing up "..buildingName.." into "..itemName)
    local itemKit = CreateItem(itemName, nil, nil)
    CreateItemOnPositionSync(building:GetAbsOrigin(), itemKit)
    building:RemoveBuilding(2,false)
    building:RemoveSelf()
end

function RemoveEntity(keys)
    local building = keys.caster
    building:RemoveSelf()
end

function QuickDrop(keys)
    local caster = keys.caster
    local position = caster:GetAbsOrigin()

    for i=0,5 do
        local item = caster:GetItemInSlot(i)
        caster:DropItemAtPositionImmediate(item,position+RandomVector(RandomInt(50,75)))
    end
end

function DropAllItems(keys)
    local caster = keys.caster
    if caster:HasInventory() then
        for itemSlot = 0, 5, 1 do
            local Item = caster:GetItemInSlot( itemSlot )
            if Item ~= nil then
                local itemCharges = Item:GetCurrentCharges()
                local newItem = CreateItem(Item:GetName(), nil, nil)
                newItem:SetCurrentCharges(itemCharges)
                CreateItemOnPositionSync(caster:GetOrigin() + RandomVector(RandomInt(100,160)), newItem)
                caster:RemoveItem(Item)
            end
        end
    end
end

function CookFood(keys)
    print("Cooking Food")
    local caster = keys.caster
    local range = keys.Range

    for _,item in pairs( Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetOrigin(), range)) do
        local containedItem = item:GetContainedItem()
        if containedItem:GetAbilityName() == "item_meat_raw" then
            local newItem = CreateItem("item_meat_cooked", nil, nil)
            CreateItemOnPositionSync(item:GetAbsOrigin(), newItem)
            UTIL_RemoveImmediate(containedItem)
            UTIL_RemoveImmediate(item)
        end
    end
end

function BushZoneMajority(users, default)
    local good = users[DOTA_TEAM_GOODGUYS]
    local bad = users[DOTA_TEAM_BADGUYS]
    local custom = users[DOTA_TEAM_CUSTOM_1]

    local majority = default
    if good > bad and good > custom then majority = DOTA_TEAM_GOODGUYS
    elseif bad > good and bad > custom then majority = DOTA_TEAM_BADGUYS
    elseif custom > good and custom > bad then majority = DOTA_TEAM_CUSTOM_1
    end
    if good + bad + custom == 0 then majority = DOTA_TEAM_NEUTRALS end

    return majority
end

function BushZoneIn(keys)
    local target = keys.target
    local me = keys.ability
    local bush = me:GetOwner()
    local team = target:GetTeamNumber()

    if not me.users then
        me.users = {};
        me.users[DOTA_TEAM_GOODGUYS] = 0;
        me.users[DOTA_TEAM_BADGUYS] = 0;
        me.users[DOTA_TEAM_CUSTOM_1] = 0;
    end

    if(bush:GetUnitName() =="npc_bush_scout" and target:GetClassname() ~="npc_dota_hero_lion") then
        return --exits if bush is used by anything other than a scout
    end


    if(bush:GetUnitName() =="npc_bush_thief" and target:GetClassname() ~="npc_dota_hero_riki") then
        return --exits if bush is used by anything other than a thief
    end
    me.users[team] = me.users[team] + 1

    local majority = BushZoneMajority(me.users, bush:GetTeamNumber())
    -- print(tostring(majority) .. " has the majority in")
    -- DeepPrintTable(me.users)
    bush:SetTeam(majority)
end

function BushZoneOut(keys)
    local target = keys.target
    local me = keys.ability
    local bush = me:GetOwner()
    local team = target:GetTeamNumber()

    me.users[team] = me.users[team] - 1
    local majority = BushZoneMajority(me.users, bush:GetTeamNumber())
    -- print(tostring(majority) .. " has the majority out")
    -- DeepPrintTable(me.users)

    bush:SetTeam(majority)

end

function MammothBlockSuccess(keys)
    attacker = keys.attacker
    caster = keys.caster

    local damage = attacker:GetAverageTrueAttackDamage()
    local block = 17
    if damage - block < 1 then
        block = damage - 1
    end

    caster:SetHealth(caster:GetHealth() + block)
end

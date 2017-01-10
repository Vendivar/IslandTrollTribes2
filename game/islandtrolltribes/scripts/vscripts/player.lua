local classes = {
    [1] = "hunter",
    [2] = "gatherer",
    [3] = "scout",
    [4] = "thief",
    [5] = "priest",
    [6] = "mage",
    [7] = "beastmaster",
}

local class_limits = {
  hunter = 1,
  gatherer = 2,
  scout = 1,
  thief = 1,
  priest = 1,
  mage = 1,
  beastmaster = 1
}

local same_team_classes = {}
local team_classes = {}

local hero_selection = {}

--Handler for class selection at the beginning of the game
function ITT:OnClassSelected(event)
    local playerID = event.PlayerID
    local class_name = event.selected_class
    local team = PlayerResource:GetTeam(playerID)

    -- Handle random selection
    if class_name == "random" then
        class_name = classes[RandomInt(1,7)]

        -- Random should respect team class limits.
        if team_classes[team] then
            while team_classes[team][class_name] == class_limits[class_name] do
                class_name = classes[RandomInt(1,7)]
            end
        end
    end

    if not team_classes[team] then
        team_classes[team] = {}
    end

    if not team_classes[team][class_name] then
        team_classes[team][class_name] = 0
    end -- Respect the limits!
    team_classes[team][class_name] = team_classes[team][class_name] + 1

    local hero_name = GameRules.ClassInfo['Classes'][class_name]

    if not PlayerTables:TableExists("hero_selection_picks") then
        PlayerTables:CreateTable("hero_selection_picks", {}, true)
    end
    PlayerTables:SetTableValue("hero_selection_picks", playerID, class_name, team)

    --local player_name = PlayerResource:GetPlayerName(playerID)
    --if player_name == "" then player_name = "Player "..playerID end

    print("SelectClass "..hero_name)

    --CustomGameEventManager:Send_ServerToTeam(team, "team_update_class", { class_name = class_name, player_name = player_name})

    if ITT.voting_ended then
        ITT:SpawnHero(hero_name, playerID)
    else
        hero_selection[playerID] = hero_name
    end
end

function ITT:SpawnAlreadySelected()
    for playerID, hero_name in pairs(hero_selection) do
        ITT:SpawnHero(hero_name, playerID)
    end
end

function ITT:SpawnRandoms(pickmode)
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            local class_name = classes[RandomInt(1,7)]
            if pickmode == "SAME_HERO" then
                local team = PlayerResource:GetTeam(playerID)
                if not same_team_classes[team] then
                    same_team_classes[team] = classes[RandomInt(1,7)]
                end
                class_name = same_team_classes[team]
            end

            local hero_name = GameRules.ClassInfo['Classes'][class_name]
            ITT:SpawnHero(hero_name, playerID)
        end
    end
end

function ITT:SpawnHero(hero_name, playerID)
    local team = PlayerResource:GetTeam(playerID)
    PrecacheUnitByNameAsync(hero_name, function()
        --local hero = CreateHeroForPlayer(hero_name, player)
        local hero = PlayerResource:ReplaceHeroWith(playerID, hero_name, 0, 0)
        print("[ITT] CreateHeroForPlayer: ", playerID, hero_name, team)
		


        -- Move to the first unassigned starting position for the assigned team-isle
        ITT:SetHeroIslandPosition(hero, team)

        -- Health Label
        local color = ITT:ColorForTeam( team )
        hero:SetCustomHealthLabel( hero.Tribe.." Tribe", color[1], color[2], color[3] )

        if not PlayerTables:TableExists("pickingover_"..playerID) then
            PlayerTables:CreateTable("pickingover_"..playerID, {over = true}, {playerID})
        end
    end, playerID)
end

function ITT:SetHeroIslandPosition(hero, teamID)

    hero.Tribe = TEAM_ISLANDS[teamID]
    if not hero.Tribe then
        print("ERROR: No Hero Tribe assigned to team ",teamID)
        DeepPrintTable(TEAM_ISLANDS)
        return
    end

    local possiblePositions = GameRules.StartingPositions[hero.Tribe]

    for k,v in pairs(possiblePositions) do
        if v.playerID == hero:GetPlayerID() or  v.playerID == -1 then
            FindClearSpaceForUnit(hero, v.position, true)
            hero:SetRespawnPosition(v.position)
            v.playerID = hero:GetPlayerID()
            print("[ITT] Position for Hero in "..hero.Tribe.." Tribe: ".. VectorString(v.position))
            break
        end
    end
end


function ITT:OnHeroInGame( hero )
    -- Remove starting gold
    hero:SetGold(0, false)

    -- Add Innate Skills
    ITT:AdjustSkills(hero)

    if not ITT.voting_ended then return end

    -- Create locked slots
    ITT:CreateLockedSlots(hero)

    -- Initial Heat
    Heat:Start(hero)

    -- Initial skills
    TeachAbility(hero, "ability_drop_items")

    -- Init Meat, Health and Energy Loss
	
	local item = CreateItem("item_apply_modifiers", hero, hero)
	item:ApplyDataDrivenModifier(hero, hero, "modifier_meat_passive", {})
	item:ApplyDataDrivenModifier(hero, hero, "modifier_hunger_health", {})
	item:ApplyDataDrivenModifier(hero, hero, "modifier_hunger_mana", {})
	
    -- Set Wearables
    ITT:SetDefaultCosmetics(hero)

    -- Adjust Stats
    Stats:ModifyBonuses(hero)
	
	--Remove Talents
	ITT:RemoveTalents(hero)
	
	--Secondary adjustments

    -- This handles spawning heroes through dota_bot_populate
    --[[if PlayerResource:IsFakeClient(hero:GetPlayerID()) then
        Timers:CreateTimer(1, function()
            ITT:SetHeroIslandPosition(hero, hero:GetTeamNumber())
        end)
    end]]
end

function ITT:RemoveTalents( hero )
	--Remove talent abilities that mess up ability index
		for i=0, 23 do
		  local ability = hero:GetAbilityByIndex(i)
		  if ability then
			local abilityName = ability:GetAbilityName()
			if string.find(abilityName, "special") then
			  hero:RemoveAbility(abilityName)
			end
		  end
		end
		
		print("removing talent",abilityName,hero)
end

function ITT:OnHeroRespawn( hero )

    -- Setting the position of the respawned hero
    ITT:SetHeroIslandPosition(hero, hero:GetTeamNumber())

    -- Restart Heat
    Heat:Start(hero)

    -- Restart Meat tracking
    ApplyModifier(hero, "modifier_meat_passive")

    

    -- Kill grave
    if hero.grave then
        UTIL_Remove(hero.grave)
        hero.grave = nil
    end
end

-- This handles locking a number of inventory slots for some classes
-- This means that players do not need to manually reshuffle them to craft
function ITT:CreateLockedSlots(hero)

    local lockedSlotsTable = GameRules.ClassInfo['LockedSlots']
    local className = hero:GetHeroClass()
    local lockedSlotNumber = lockedSlotsTable[className]

    local lockN = 5
    for n=0,lockedSlotNumber-1 do
        hero:AddItem(CreateItem("item_slot_locked", hero, spawnedUnit))
        hero:SwapItems(0, lockN)
        lockN = lockN -1
    end
--	local item = spawnedUnit:AddItemByName("item_slot_locked")
--	spawnedUnit:SwapItems(0, 6)
--	local item2 = spawnedUnit:AddItemByName("item_slot_locked")
--	spawnedUnit:SwapItems(0, 7)
--	local item3 = spawnedUnit:AddItemByName("item_slot_locked")
--	spawnedUnit:SwapItems(0, 8)
	
end

function ITT:CreateLockedSlotsForUnits(unit, lockedSlotCount)
    local lockN = 5
    for n=0,lockedSlotCount-1 do
        unit:AddItem(CreateItem("item_slot_locked", nil, nil))
        unit:SwapItems(0, lockN)
        lockN = lockN -1
    end
end

-- Sets the hero skills for the level as defined in the 'SkillProgression' class_info.kv
-- Called on spawn and every time a hero gains a level or chooses a subclass
function ITT:AdjustSkills( hero )
    local skillProgressionTable = GameRules.ClassInfo['SkillProgression']
    local class = hero:GetHeroClass()
    local level = hero:GetLevel() --Level determines what skills to add or levelup
    hero:SetAbilityPoints(0) --All abilities are learned innately

	
    -- If the hero has a subclass, use that table instead
    if hero:HasSubClass() then
        class = hero:GetSubClass()
    end

    local class_skills = skillProgressionTable[class]
    if not class_skills then
        print("ERROR: No 'SkillProgression' table found for",class,"!")
        return
    end

    -- For every level past 6, we need to check for old levels of abilities could have been missed
    if hero.subclass_leveled and hero.subclass_leveled > 6 then

        for level = 6, hero.subclass_leveled do
		
            ITT:UnlearnAbilities(hero, class_skills, level)
            ITT:LearnAbilities(hero, class_skills, level)
        end

        hero.subclass_leveled = nil --Already subclassed, next time it will just adjust skills normally
    else
	    Timers:CreateTimer({
      endTime = 0.1,
      callback = function()
         ITT:UnlearnAbilities(hero, class_skills, level)
      end
    })
		Timers:CreateTimer({
      endTime = 0.3,
      callback = function()
        ITT:LearnAbilities(hero, class_skills, level)
      end
    })
    end
	
	Timers:CreateTimer({
      endTime = 0.5,
      callback = function()
		EnableSpellBookAbilities(hero)
		PrintAbilities(hero)
      end
    })

    PlayerResource:RefreshSelection()
end

-- Check for any skill in the 'unlearn' subtable
function ITT:UnlearnAbilities(hero, class_skills, level)
    Timers:CreateTimer({
        callback = function()
        local unlearn_skills = class_skills['unlearn']
        if unlearn_skills then
            local unlearn_skills_level = unlearn_skills[tostring(level)]
            if unlearn_skills_level then
                local unlearn_ability_names = split(unlearn_skills_level, ",")
                for _,abilityName in pairs(unlearn_ability_names) do
                    local ability = hero:FindAbilityByName(abilityName)

                    if ability then
                        local kv = ability:GetAbilityKeyValues()
                        --print("unlearning " .. abilityName)
                        if kv["Modifiers"] then
                            for i,v in pairs(kv["Modifiers"]) do
                                --print("removing modifier ".. i)
                                hero:RemoveModifierByName(i)
                            end
                        end
                        hero:RemoveAbility(abilityName)
                    end
                end
            end
        end
    end})
end

-- Learn/Upgrade all abilities for this level
function ITT:LearnAbilities(hero, class_skills, level)
    local level_skills = class_skills[tostring(level)]
    local class = hero:GetHeroClass().." ("..hero:GetSubClass()..")"
    if level_skills and level_skills ~= "" then
        print("[ITT] AdjustSkills for "..class.." at level "..level)
        local ability_names = split(level_skills, ",")

        -- If the ability already exists, upgrade it, otherwise add it at level 1
        for _,abilityName in pairs(ability_names) do
            local ability = hero:FindAbilityByName(abilityName)
            if ability then
                ability:SetHidden(false)
                ability:UpgradeAbility(false)
            else
                TeachAbility(hero, abilityName)
            end
        end
        print("------------------------------")
    else
        print("No skills to change for "..class.." at level "..level)
    end
end

function EnableSpellBookAbilities(hero)
    Timers:CreateTimer({    -- Needs to happen on the next frame.
        callback = function()
            local toggleAbilityName
            local heroClass = hero:GetHeroClass()
            --print("Heroclass: "..heroClass)
            if heroClass == "mage" then
                toggleAbilityName = "ability_mage_spellbook_toggle"
            elseif heroClass == "priest" then
                toggleAbilityName = "ability_priest_toggle_spellbar"
            elseif heroClass == "gatherer" and hero:GetSubClass() == "herbal_master_telegatherer" then
                toggleAbilityName = "ability_gatherer_findherb"
            elseif heroClass == "beastmaster" and hero:GetSubClass() ~= "shapeshifter" then
                toggleAbilityName = "ability_beastmaster_petcontroll"
            end

            if toggleAbilityName then
                local spellBookAbility = hero:FindAbilityByName(toggleAbilityName)
				SpellBookTrickery(hero,spellBookAbility)
            end
        end
    })
end



function SpellBookTrickery(hero,spellBookAbility )
	Timers:CreateTimer(1, function()
        spellBookAbility:ToggleAbility()
    end
  )
  
  	Timers:CreateTimer(2, function()
        spellBookAbility:ToggleAbility()
    end
  )
  
  print("casting",spellBookAbility,"on",hero)
end

---------------------------------------------------------------------------
-- Gets a list of playerIDs on a team
---------------------------------------------------------------------------
function ITT:GetPlayersOnTeam( teamNumber )
    local players = {}
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:GetTeam(playerID) == teamNumber then
            table.insert(players, playerID)
        end
    end
    return players
end

------------------------------------------------
--              Ability functions             --
------------------------------------------------

-- Global variables
HUNTER = "npc_dota_hero_huskar"
PRIEST = "npc_dota_hero_dazzle"
MAGE = "npc_dota_hero_witch_doctor"
BEASTMASTER = "npc_dota_hero_lycan"
THIEF = "npc_dota_hero_riki"
SCOUT = "npc_dota_hero_lion"
GATHERER = "npc_dota_hero_shadow_shaman"

function IsCastableWhileHidden( abilityName )
    return GameRules.AbilityKV[abilityName] and GameRules.AbilityKV[abilityName]["IsCastableWhileHidden"]
end

function SetAbilityVisibility(unit, abilityName, visibility)
    local ability = unit:FindAbilityByName(abilityName)
    local hidden = (visibility == false)
    if ability ~= nil and unit ~= nil then
        ability:SetHidden(hidden)
    end
end

function TeachAbility( unit, ability_name, level )
    if not level then level = 1 end
    if unit:HasAbility(ability_name) then
        unit:FindAbilityByName(ability_name):SetLevel(tonumber(level))
        return
    end

    if GameRules.AbilityKV[ability_name] then
        unit:AddAbility(ability_name)
        local ability = unit:FindAbilityByName(ability_name)
        if ability then
            ability:SetLevel(tonumber(level))
            return ability
        end
    else
        print("ERROR: ability "..ability_name.." is not defined")
        return nil
    end
end

function PrintAbilities( unit )
    print("List of Abilities in "..unit:GetUnitName())
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability then
            local output = i.." - "..ability:GetAbilityName()
            if ability:IsHidden() then output = output.." (Hidden)" end
            print(output)
        end
    end
end

function ClearAbilities( unit )
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability then
            unit:RemoveAbility(ability:GetAbilityName())
        end
    end
end

function GetAllAbilities( unit )
    local abilityList = {}
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability then
            table.insert(abilityList,ability)
        end
    end
    return abilityList
end

function EnableAllAbilities( unit, visibility )
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability then
--            SetAbilityVisibility(unit,ability:GetAbilityName(),visibility)
            ability:SetActivated(visibility)
        end
    end
end

function QuickDrop(keys)
    local caster = keys.caster
    local point = keys.target_points[1]
  	local itemsToDrop = {}
    for i=0,5 do
        local item = caster:GetItemInSlot(i)
    		if item then
      		table.insert(itemsToDrop, item)
        end
    end

  	local itemCount = #itemsToDrop
		if itemCount > 0 then
        local origin = caster:GetAbsOrigin()
        local rotate_pos = point + Vector(1,0,0) * 50
        local angle = 360 / itemCount
        for k,item in pairs(itemsToDrop) do
            local position = RotatePosition(point, QAngle(0, angle*k, 0), rotate_pos)
     				caster:DropItemAtPositionImmediate(item, origin) --Drops the item where the unit is standing
            DropLaunch(caster, item, 0.75, position)
           -- print(k)
           -- DebugDrawCircle(point, Vector(255,0,0), 100, 50, true, 10)
        end
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

function DropAllItemsTool(keys)
    local caster = keys.caster
    local itemName = item:GetName()--get the item's name
    if caster:HasInventory() then
        for itemSlot = 0, 5, 1 do
            local Item = caster:GetItemInSlot( itemSlot )
            if Item ~= nil and itemName ~= "item_slot_locked" then
                local itemCharges = Item:GetCurrentCharges()
                local newItem = CreateItem(Item:GetName(), nil, nil)
                newItem:SetCurrentCharges(itemCharges)
                CreateItemOnPositionSync(caster:GetOrigin() + RandomVector(RandomInt(100,160)), newItem)
                caster:RemoveItem(Item)
            end
        end
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

function ToggleOn(ability)
    if ability:GetToggleState() == false then
        ability:ToggleAbility()
    end
end

function ToggleOff(ability)
    if ability:GetToggleState() == true then
        ability:ToggleAbility()
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
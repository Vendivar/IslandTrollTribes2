------------------------------------------------
--            Global item applier             --
------------------------------------------------
function ApplyModifier( unit, modifier_name )
    GameRules.APPLIER:ApplyDataDrivenModifier(unit, unit, modifier_name, {})
end

------------------------------------------------
--               Class functions              --
------------------------------------------------

-- Unit Label for now
function GetHeroClass( hero )
    return hero:GetUnitLabel()
end

function GetSubClass( hero )
    return hero.subclass or 'none'
end

function HasSubClass( hero )
    return GetSubClass(hero) ~= 'none'
end

------------------------------------------------
--              Ability functions             --
------------------------------------------------

function SetAbilityVisibility(unit, abilityName, visibility)
    local ability = unit:FindAbilityByName(abilityName)
    local hidden = (visibility == false)
    if ability ~= nil and unit ~= nil then
        ability:SetHidden(hidden)
    end
end

function TeachAbility( unit, ability_name, level )
    if not level then level = 1 end
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

------------------------------------------------

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

------------------------------------------------

--general "ping minimap" function
function PingMap(playerID,pos,r,g,b)
    --(PlayerID, position(vector), R, G, B, SizeofDot, Duration)
    GameRules:AddMinimapDebugPoint(5,pos, r, g, b, 500, 6)
    print("x:", pos.x)
    print("y:", pos.y)
    print("z:", pos.z)
    --NEWEST PING ALWAYS CLEARS LAST PING, ONLY ONE PING AT A TIME, THIS FUNCTION SUCKS DICK BUT IT'S ALL WE HAVE TO WORK WITH
end

------------------------------------------------
--               Layout manipulation          --
------------------------------------------------

function SetAbilityLayout( unit, layout_size )
    unit:RemoveModifierByName("modifier_ability_layout4")
    unit:RemoveModifierByName("modifier_ability_layout5")
    unit:RemoveModifierByName("modifier_ability_layout6")
    
    ApplyModifier(unit, "modifier_ability_layout"..layout_size)
end

function AdjustAbilityLayout( unit )
    local required_layout_size = GetVisibleAbilityCount(unit)

    if required_layout_size > 6 then
        required_layout_size = 6
    elseif required_layout_size < 4 then
        required_layout_size = 4
    end

    SetAbilityLayout(unit, required_layout_size)
end

function GetVisibleAbilityCount( unit )
    local count = 0
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability and not ability:IsHidden() and (ability:GetAbilityName() ~= "attribute_bonus") then
            count = count + 1
            ability:MarkAbilityButtonDirty()
        end
    end
    return count
end

function FindAbilityWithName( unit, ability_name_section )
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability and string.match(ability:GetAbilityName(), ability_name_section) then
            return ability
        end
    end
end

function GetAbilityOnVisibleSlot( unit, slot )
    local visible_slot = 0
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability and not ability:IsHidden() then
            visible_slot = visible_slot + 1
            if visible_slot == slot then
                return ability
            end
        end
    end
end

----------------------------------------------
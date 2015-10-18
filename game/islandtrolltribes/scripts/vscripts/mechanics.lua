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
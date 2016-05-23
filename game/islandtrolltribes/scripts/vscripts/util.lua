-- Prints recursively contents of a table
function checkKeys(keys)
    for key, value in pairs(keys) do
        print (key,value)
        checkType(value)
    end
end    

-- helper function for checkKeys
function checkType(stuff)
    if (type(stuff)=="table") then
            for k, v in pairs(stuff) do
                print(k,v)
                checkType(v)
            end
    end
end

--bmd's print table
function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..":")
                PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end

-- Gets a random vector in a specific area
function GetRandomVectorGivenBounds(minx, miny, maxx, maxy)
    return Vector(RandomFloat(minx, miny),RandomFloat(maxx, maxy),0)
end

-- Checks whether the vector is bound to the given cordinates.
function IsVectorInBounds(vector, minx, maxx, miny,  maxy)
    if vector.x >= minx and vector.x <= maxx and vector.y  >= miny and vector.y <=maxy then
        return true
    end
    return false
end

-- Gets a random vector on the map
function GetRandomVectorInBounds()
    return Vector(RandomFloat(GetWorldMinX(), GetWorldMaxX()),RandomFloat(GetWorldMinY(), GetWorldMaxY()),0)
end

function tableContains(list, element)
    if list == nil then return false end
    for i=1,#list do
        if list[i] == element then
            return true
        end
    end
    return false
end

function getIndex(list, element)
    if list == nil then return false end
    for i=1,#list do
        if list[i] == element then
            return i
        end
    end
    return -1
end

function getIndexTable(list, element)
    if list == nil then return false end
    for k,v in pairs(list) do
        if v == element then
            return k
        end
    end
    return -1
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ShuffledList( orig_list )
    local list = shallowcopy( orig_list )
    local result = {}
    local count = #list
    for i = 1, count do
        local pick = RandomInt( 1, #list )
        result[ #result + 1 ] = list[ pick ]
        table.remove( list, pick )
    end
    return result
end


function TableCount( t )
    local n = 0
    for _ in pairs( t ) do
        n = n + 1
    end
    return n
end

function TableFindKey( table, val )
    if table == nil then
        print( "nil" )
        return nil
    end

    for k, v in pairs( table ) do
        if v == val then
            return k
        end
    end
    return nil
end

function MergeTables( t1, t2 )
    for name,info in pairs(t2) do
        t1[name] = info
    end
end

function split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end

--Compares two tables to see if they have the same values
function CompareTables(table1, table2)
    if type(table1) ~= "table" or type(table2) ~= "table" then
        return false
    end

    for key,value in pairs(table1) do
        if table2[key] == nil then
            return false
        elseif table2[key] ~= table1[key] then
            return false
        end
    end

    for key,value in pairs(table2) do
        print(key, table2[key], table1[key])
        if table1[key] == nil then
            return false
        elseif table1[key] ~= table2[key] then
            return false
        end
    end
    
    return true
end

function compareHelper(a,b)
    return a[2] > b[2]
end

function table_slice (values,i1,i2)
    local res = {}
    local n = #values
    -- default values for range
    i1 = i1 or 1
    i2 = i2 or n

    if i2 < 0 then
        i2 = n + i2 + 1
    elseif i2 > n then
        i2 = n
    end

    if i1 < 0 or i1 > n then
        return {}
    end

    local k = 1
    for i = i1,i2 do
        res[k] = values[i]
        k = k + 1
    end

    return res
end

function StringStartsWith( fullstring, substring )
    local strlen = string.len(substring)
    local first_characters = string.sub(fullstring, 1 , strlen)
    return (first_characters == substring)
end

function DebugPrint(...)
    local spew = Convars:GetInt('debug_spew') or -1
    if spew == -1 and DEBUG_SPEW then
        spew = 1
    end

    if spew == 1 then
        print(...)
    end
end

function VectorString(v)
    return '[' .. v.x .. ', ' ..v.y .. ', ' .. v.z .. ']'
end

function tobool(s)
    if s=="true" or s=="1" or s==1 then
        return true
    else --nil "false" "0"
        return false
    end
end

-- passing a table like {255, 100, 20}
function rgbToHex(rgb)
    local hexadecimal = '#'

    for key, value in pairs(rgb) do
        local hex = ''

        while(value > 0)do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub('0123456789ABCDEF', index, index) .. hex           
        end

        if(string.len(hex) == 0)then
            hex = '00'

        elseif(string.len(hex) == 1)then
            hex = '0' .. hex
        end

        hexadecimal = hexadecimal .. hex
    end

    return hexadecimal
end

function DebugPrint(...)
    local spew = Convars:GetInt('debug_spew') or -1
    if spew == -1 and DEBUG_SPEW then
        spew = 1
    end

    if spew == 1 then
        print(...)
    end
end

function GenerateNumPointsAround(num, center, distance)
    local points = {}
    local angle = 360/num
    for i=0,num-1 do
        local rotate_pos = center + Vector(1,0,0) * distance
        table.insert(points, RotatePosition(center, QAngle(0, angle*i, 0), rotate_pos) )
    end
    return points
end
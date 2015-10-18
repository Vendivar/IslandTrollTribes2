
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
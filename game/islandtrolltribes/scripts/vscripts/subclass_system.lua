--[[
    TODO: Destroy particles from cosmetics such as immortals
--]]

function ITT:PrecacheSubclassModels(context)
    local subclassInfo = LoadKeyValues("scripts/kv/class_info.kv").SubClasses

    for key,subTable in pairs(subclassInfo) do
        if subTable['Model'] then
            PrecacheModel(subTable['Model'], context)
        end

        if subTable['defaults'] then
            for k,v in pairs(subTable['defaults']) do
                PrecacheModel(v, context)
            end 
        end

        if subTable['Wearables'] then
            for k,v in pairs(subTable['Wearables']) do
                if string.find(v, ".vmdl") then
                    PrecacheModel(v, context)
                end
            end
        end
    end
end

-- When a hero gets ingame, check its cosmetics, find out the slot and replace by the defaults
function ITT:SetDefaultCosmetics(hero)
    local class = GetHeroClass(hero)
    local subclassInfo = GameRules.ClassInfo['SubClasses']
    local subclassTable = subclassInfo[class]
    local defaultWearables = subclassTable['defaults']

    if not defaultWearables then
        print("ERROR: No 'defaults' table found for the class "..class)
        return
    end

    print("SetDefaultCosmetics for "..class)

    local wearable = hero:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            local wearableName = wearable:GetModelName()
            if wearableName ~= "" then
                local slot = modelmap[wearableName] or "weapon" --Default main weapons don't have an item_slot in items_game.txt
                local defaultWearableName = defaultWearables[slot]

                --print(wearableName,"at",slot)
                --print("Default item at",slot,"is:",defaultWearableName)
                if wearableName and defaultWearableName and wearableName ~= defaultWearableName then
                    SwapWearable(hero, wearableName, defaultWearableName)
                end
                --print("-------------------------------------------------")
            end
        end
        wearable = wearable:NextMovePeer()
    end

     -- Handle Hunter hidden wearables
    Timers:CreateTimer(function()
        local hideSlots = subclassTable['hide']
        if hideSlots then
            local hats = hero:GetChildren()
            for k,wearable in pairs(hats) do
                if wearable:GetClassname() == "dota_item_wearable" then
                    local wearableName = wearable:GetModelName()
                    if wearableName ~= "" then
                        local slot = modelmap[wearableName] or "weapon"
                        local defaultWearableName = defaultWearables[slot]

                        if subclassTable['hide'][slot] then
                            --print("Hiding",wearableName,wearable)
                            wearable:AddEffects(EF_NODRAW)
                            wearable.hidden = true
                        end
                    end
                end
            end
        end
    end)
end

function ITT:OnSubclassChange(event)
    local playerID = event.PlayerID
    local subclassID = tostring(event.subclassID)

    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local class = GetHeroClass(hero)
    print("Current class:",class)

    -- Reset subclass (just for testing purposes)
    if GetSubClass(hero) ~= "none" then
        ITT:ResetSubclass(playerID)
    end

    local subclassInfo = GameRules.ClassInfo['SubClasses']
    local subclassTable = subclassInfo[class]

    local new_name = subclassTable[subclassID]

    print("New Subclass:", new_name)
    hero.subclass = new_name
    if hero.subclassAvailableParticle then
        ParticleManager:DestroyParticle(hero.subclassAvailableParticle, false)
        EmitSoundOnClient("SubSelected", PlayerResource:GetPlayer(playerID))
        local subParticle = ParticleManager:CreateParticle("particles/custom/subclass_selection.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
        ParticleManager:SetParticleControl( subParticle, 0, hero:GetAbsOrigin() )
        ParticleManager:SetParticleControl( subParticle, 1, hero:GetAbsOrigin() )
        ParticleManager:SetParticleControl( subParticle, 2, hero:GetAbsOrigin() )
        ParticleManager:SetParticleControl( subParticle, 3, hero:GetAbsOrigin() )
    end
    -- Change Vision range
    local stats = subclassInfo[new_name]['Vision']
    if stats then
        hero:SetDayTimeVisionRange(stats['VisionDaytimeRange'])
        hero:SetDayTimeVisionRange(stats['VisionNighttimeRange'])
    end

    -- Give bonus attack, mana, health, attack rate and MS
    local modifier_name = "modifier_"..class.."_"..new_name
    ApplyModifier(hero, modifier_name)
    hero.subclassModifierName = modifier_name

    -- Handle MODIFIER_PROPERTY_MODEL_CHANGE
    local modifier_lua = subclassInfo[new_name]['modifier_lua']
    if modifier_lua then
        print("Adding",modifier_lua)
        hero:AddNewModifier(hero, nil, modifier_lua, {})
        hero.modelChangeModifierName = modifier_lua
    end

    -- Learn all the skills for the new class
    local subClassAbilities = GameRules.ClassInfo['SkillProgression'][new_name]
    for _,v in pairs(subClassAbilities) do
        if type(v) ~= "table" then
            print("String is "..v)
            local learn_ability_names = split(v, ",")
            for _,abilityName in pairs(learn_ability_names) do
                if not hero:HasAbility(abilityName) then
                    print("Adding "..abilityName)
                    hero:AddAbility(abilityName)
                    local ability = hero:FindAbilityByName(abilityName)
                    if ability then
                        ability:SetLevel(0)
                    else
                        print("ERROR: couldn't add ability "..abilityName)
                    end
                end
            end
        end
    end

    -- Update skills
    ITT:AdjustSkills( hero )

    -- Change the default wearables by new ones for that class
    local defaultWearables = subclassTable['defaults']
    local newWearables = subclassInfo[new_name]['Wearables']

    if not defaultWearables or not newWearables then
        return
    end

    for slot,modelName in pairs(defaultWearables) do
        SwapWearable(hero, defaultWearables[slot], newWearables[slot])
    end
end

-- Change the current wearables by defaults
function ITT:ResetSubclass(playerID)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local class = GetHeroClass(hero)
    local subclass = GetSubClass(hero)
    print("Current class and subclass:",class, subclass)

    local subclassInfo = GameRules.ClassInfo['SubClasses']
    local subclassTable = subclassInfo[class]

    local subclassTable = subclassInfo[class]
    local subclassInfo = GameRules.ClassInfo['SubClasses']
    local defaultWearables = subclassTable['defaults']
    local currentWearables = subclassInfo[subclass]['Wearables']

    print("Resetting subclass")
    hero.subclass = nil

    -- Update skills
    ITT:AdjustSkills( hero )

    -- Handle model change modifier
    if hero.modelChangeModifierName then
        hero:RemoveModifierByName(hero.modelChangeModifierName)
        hero.modelChangeModifierName = nil
    end

    -- Remove subclass stats
    if (hero.subclassModifierName) then
        hero:RemoveModifierByName(hero.subclassModifierName)
        hero.subclassModifierName = nil
    end

    if not defaultWearables or not currentWearables then 
        return
    end

    for slot,modelName in pairs(defaultWearables) do
        SwapWearable(hero, currentWearables[slot], defaultWearables[slot])
    end
end

------------------------------------------------------

-- Swaps a target model for another
function SwapWearable( unit, target_model, new_model )
    local wearable = unit:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if wearable:GetModelName() == target_model then
                wearable:SetModel( new_model )
                print("Swapped Wearable ",target_model,"->",new_model)
                -- If the original wearable was hidden, and we are replacing it by a new one, reveal it
                if wearable.hidden then
                    print("Set Wearable revealed")
                    wearable:RemoveEffects(EF_NODRAW)
                end

                return
            end
        end
        wearable = wearable:NextMovePeer()
    end
end

-- Hides all dem hats
function HideWearables( hero )
    hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(hero.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( hero )
    for i,v in pairs(hero.hiddenWearables) do
        v:RemoveEffects(EF_NODRAW)
        if v.originalModel then
            v:SetModel(originalModel)
        end
    end
end

------------------------------------------------------

function MapModels()
    for k,v in pairs(itemskeys) do
        if v.model_player then
            modelmap[v.model_player] = v.item_slot or "weapon"
        end
    end
end

function ModelForItemID(itemID)
    return itemskeys[tostring(itemID)].model_player
end

function SlotForItemID(itemID)
    return itemskeys[tostring(itemID)].item_slot
end

function SlotForModel(model)
    return modelmap[model]
end

function GetModelForSlot(clothes, slot)
    for k,v in pairs(clothes) do
        local itemID = v["ItemDef"]
        local newslot = SlotForItemID(itemID)
        if newslot == slot then return ModelForItemID(itemID) end
    end
end
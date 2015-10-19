--[[
wearableTable = items_game['items'][ID]
wearableName = wearableTable['name']
wearableType = wearableTable['prefab'] -- "wearable" or "default_item"
modelName = wearableTable['model_player']

-- If necessary:
particles = wearableTable['particle_folder'] + wearableTable['visuals'] + items_game['attribute_controlled_attached_particles']
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
                PrecacheModel(v, context)
            end
        end
    end

end

function ITT:OnSubclassChange(event)
    local playerID = event.playerID
    local subclassID = event.subclassID

    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local class = GetHeroClass(hero)
    print("Current class:",class)

    -- Reset subclass (just for testing purposes)
    if GetSubClass(hero) ~= "none" then
        ITT:ResetSubclass(playerID)
    end

    local subclassInfo = GameRules.ClassInfo['SubClasses']
    local subclassNames = subclassInfo[class]

    local new_name = subclassNames[subclassID]

    print("New Subclass:", new_name)
    hero.subclass = new_name

    -- Change the default wearables by new ones for that class
    local defaultWearables = subclassNames['defaults']
    local newWearables = subclassInfo[new_name]['Wearables']

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
    local subclassNames = subclassInfo[class]

    local subclassNames = subclassInfo[class]
    local subclassInfo = GameRules.ClassInfo['SubClasses']
    local defaultWearables = subclassNames['defaults']
    local currentWearables = subclassInfo[subclass]['Wearables']

    print("Resetting subclass")
    hero.subclass = "none"

    for slot,modelName in pairs(defaultWearables) do
        SwapWearable(hero, currentWearables[slot], defaultWearables[slot])
    end
end

-- Swaps a target model for another
function SwapWearable( unit, target_model, new_model )
    local wearable = unit:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if wearable:GetModelName() == target_model then
                wearable:SetModel( new_model )
                return
            end
        end
        wearable = wearable:NextMovePeer()
    end
end
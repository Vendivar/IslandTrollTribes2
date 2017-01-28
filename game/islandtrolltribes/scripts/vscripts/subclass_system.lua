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
    local defaultWearables = GameRules.ClassInfo['SubClasses'][hero:GetHeroClass()]['defaults']
    local hideSlots = GameRules.ClassInfo['SubClasses'][hero:GetHeroClass()]['hide']

    if IsServer() then
		--RemoveAllWearables(hero) --Could be replaced by adding "DisableWearables" "1" on every hero (FUNCTION IS BROKEN FOR THE REMOVAL PART, CRASHES ON LEVEL UP)
        hero.wearables = {}
        for _,modelName in pairs(defaultWearables) do
            hero:AttachWearable(modelName)			
		print("attaching wearables for",hero,modelName)
        end
    else

        -- Handle Hunter hidden wearables
        Timers:CreateTimer(function()
            if hideSlots then
                local hats = hero:GetChildren()
                for k,wearable in pairs(hats) do
                    if wearable:GetClassname() == "dota_item_wearable" then
                        local wearableName = wearable:GetModelName()
                        if wearableName ~= "" then
                            local slot = modelmap[wearableName] or "weapon"
                            if hideSlots[slot] then
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
end

-- Create a wearable model unit to follow the hero entity
function CDOTA_BaseNPC_Hero:AttachWearable(modelPath)
    local wearable = CreateUnitByName("wearable_model", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NOTEAM)
	print("2attaching wearables for",hero)
    local oldSet = wearable.SetModel
    wearable.SetModel = function(self, model)
        oldSet(self, model)
        self:SetOriginalModel(model)
    end

    wearable:SetModel(modelPath)
    wearable:FollowEntity(self, true)
    wearable:AddNewModifier(wearable, nil, "modifier_wearable_visuals", {})
    table.insert(self.wearables, wearable)

    return wearable
end

function ITT:OnSubclassChange(event)
    local playerID = event.PlayerID
    local subclassID = tostring(event.subclassID)

    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local level = hero:GetLevel()
    local class = hero:GetHeroClass()
    print("Current class:",class)

    -- Reset subclass (just for testing purposes)
    if hero:HasSubClass() and IsInToolsMode() then
        ITT:ResetSubclass(playerID)
    end

    local subclassInfo = GameRules.ClassInfo['SubClasses']
    local subclassTable = subclassInfo[class]

    local new_name = subclassTable[subclassID]

    print("New Subclass:", new_name)
    hero.subclass = new_name
    hero.subclass_leveled = level --Keep track of when the hero invested into a subclass
    if hero.subclassAvailableParticle then
        ParticleManager:DestroyParticle(hero.subclassAvailableParticle, false)
        EmitSoundOnClient("SubSelectedQ", hero)
		hero:EmitSound("SubSelected")
        local subParticle = ParticleManager:CreateParticle("particles/custom/subclass_selection.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    end
    -- Change Vision range
    local stats = subclassInfo[new_name]['Vision']
    if stats then
        hero:SetDayTimeVisionRange(stats['VisionDaytimeRange'])
        hero:SetDayTimeVisionRange(stats['VisionNighttimeRange'])
    end
    -- Change Size
    local stats = subclassInfo[new_name]['Size']
    if stats then
        hero:SetModelScale(stats['ModelSizeChange'])
    end
    -- Give bonus attack, mana, health, attack rate and MS
    local modifier_name = "modifier_"..class.."_"..new_name
	
	local item = CreateItem("item_apply_modifiers", hero, hero)
	item:ApplyDataDrivenModifier(hero, hero, modifier_name, {})
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

    -- Post subclass select actions
    PostSubclassSelectActions(hero)

    -- Update skills
    ITT:AdjustSkills(hero)

    -- Lets adjust the layout just in case, with a delay.

    -- Change the default wearables by new ones for that class
    local defaultWearables = subclassTable['defaults']
    local newWearables = subclassInfo[new_name]['Wearables']

    if not defaultWearables or not newWearables then
        return
    end
	
    HideWearables(hero)
	
		hero.wearables = {}
        for _,modelName in pairs(newWearables) do
		hero:AttachWearable(modelName)			
		print("attaching wearables for",hero,modelName)
        end
end

function PostSubclassSelectActions(hero)
    if (hero.subclass == "chicken_form"  or hero.subclass == "shapeshifter") and hero.pets then
        for _,pet in pairs(hero.pets) do
            pet:ForceKill(false)
        end
    end

    -- Drop axes and gloves
    if hero.subclass == "chicken_form" then
        for i=0,5 do
            local item = hero:GetItemInSlot(i)
            if item then
                local itemSlotRestriction = GameRules.ItemInfo['ItemSlots'][item:GetAbilityName()]
                if itemSlotRestriction == "Axes" or itemSlotRestriction == "Gloves" then
                    hero:DropItemAtPositionImmediate(item, hero:GetAbsOrigin())
                end
            end
        end
    end
end

------------------------------------------------------

function FindWearableByModelName(wearableList, modelName)
    for _,wearable in pairs(wearableList) do
        if wearable:GetModelName() == modelName then
            return wearable
        end
    end
end

function GetCurrentlyWornWearables(unit)
    local wearables = {}
    local wearable = unit:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            table.insert(wearables, wearable)
        end
        wearable = wearable:NextMovePeer()
    end
    return wearables
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

function RemoveAllWearables( hero )
    local wearables = hero:GetChildren()
    for _,v in pairs(wearables) do
        if v:GetClassname() == "dota_item_wearable" and IsValidEntity(v) then
            if v:GetMoveParent() == hero then
                if v:GetModelName() == "models/pets/armadillo/armadillo.vmdl" then
                    v:AddEffects(EF_NODRAW)
                else
                    UTIL_Remove(v)
                end
            end
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

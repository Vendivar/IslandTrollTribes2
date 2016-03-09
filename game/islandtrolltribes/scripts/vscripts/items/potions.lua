--Not finished, need to find and ping spirit wards and bosses
function PotionTwinUse(keys)
  local caster = keys.caster
  local range = keys.Range
  local casterPosition = caster:GetAbsOrigin()
  local teamnumber = caster:GetTeamNumber()

  local units = FindUnitsInRadius(teamnumber,
    casterPosition,
    nil,
    range,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false)
    
  local redVal = 0
  local greenVal = 0
  local blueVal = 0
  local color = "white"

  for _, unit in pairs(units) do
    if unit:IsHero() then
      redVal = 255
      color = "red"
    end

    local thisParticle = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, caster:GetOwner())
    ParticleManager:SetParticleControl(thisParticle, 0, unit:GetAbsOrigin())
    ParticleManager:SetParticleControl(thisParticle, 1, Vector(redVal, greenVal, blueVal))
    PingMap(caster:GetPlayerID(),unit:GetAbsOrigin(),color, teamnumber)
    ParticleManager:ReleaseParticleIndex(thisParticle)
    unit:EmitSound("General.Ping")   --may be deafening
  end
  
  --So for the spirit ward, I was thinking of changing building itself to be a tower, and then use isTower(), but I had some errors and never got around to it
    
--  local spiritWards = FindUnitsInRadius(teamnumber,
--    casterPosition,
--    nil,
--    range,
--    DOTA_UNIT_TARGET_TEAM_ENEMY,
--    DOTA_UNIT_TARGET_ALL,
--    DOTA_UNIT_TARGET_FLAG_NONE,
--    FIND_ANY_ORDER,
--    false)
--  
--  for _, spiritWard in pairs(spiritWards) do
--    if spiritWard:isTower() then
--      blueVal = 255
--    
--      local thisParticle = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, caster:GetOwner())
--      ParticleManager:SetParticleControl(thisParticle, 0, spiritWard:GetAbsOrigin())
--      ParticleManager:SetParticleControl(thisParticle, 1, Vector(redVal, greenVal, blueVal))
--      PingMap(caster:GetPlayerID(),spiritWard:GetAbsOrigin(),redVal,greenVal,blueVal)
--      ParticleManager:ReleaseParticleIndex(thisParticle)
--      spiritWard:EmitSound("General.Ping")   --may be deafening
--    end
--  end
end

function PotionManaUse(keys)
    local caster = keys.caster

    local startingMana = caster:GetMana()
    caster:SetMana(startingMana + keys.ManaRestored)
end

function PotionDrunkUse(keys)
    local caster = keys.caster
    local target = keys.target

    local dur = 13.0
    if (target:IsHero()) then --if the target is a hero unit, shorter duration
        dur = 9.0
    end
    
    target:AddNewModifier(caster, nil, "modifier_brewmaster_drunken_haze", {duration = dur, movement_slow = 10, miss_chance = 50})    
end

function AntiMagicPotionUse(keys)
  local caster = keys.caster

  caster:Purge(false, true, false, true, false)
end

function PotionFervorUse(keys)
    local caster = keys.caster
    local target = keys.target

    local pumpUpDur = 20.0
    local stoneSkin = CreateItem( "item_scroll_stoneskin", caster, caster)
    stoneSkin:ApplyDataDrivenModifier( caster, caster, "modifier_scroll_stoneskin_buff", {duration=45})

    local dummyCaster = CreateUnitByName("dummy_caster", caster:GetOrigin(), false, caster, caster, caster:GetTeamNumber())
    dummyCaster:AddAbility("ability_mage_pumpup")
    local ability = dummyCaster:FindAbilityByName("ability_mage_pumpup")
    ability:SetLevel(1)
    --need a delay before casting and killing the dummy due to cast points
    Timers:CreateTimer(0.1, function()
            dummyCaster:CastAbilityOnTarget(caster, ability, caster:GetPlayerID())
            return
            end
            )
    Timers:CreateTimer(0.2, function()
            dummyCaster:ForceKill(true)
            return
            end
            )
end

function PotionFervorSecondary(keys)
    local caster = keys.caster
    local entangleDur = 5
    local entangleDur = 7.5
    local entangle = CreateItem( "item_scroll_entangling", caster, caster)
    local thistles = CreateItem( "item_gun_blow_thistles", caster, caster)

    local enemiesInRange = FindUnitsInRadius(
        caster:GetTeam(),
        caster:GetOrigin(),
        nil, 300,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 
        FIND_CLOSEST,
        false)
    
    print(#enemiesInRange)
        
    if #enemiesInRange > 0 then
        for i = 1, #enemiesInRange do
            local randomNum = RandomInt(0, 1)
            if randomNum == 0 then
                entangle:ApplyDataDrivenModifier( caster, enemiesInRange[i], "modifier_scroll_entanglingroots", {duration=entangleDur})
            else
                thistles:ApplyDataDrivenModifier( caster, enemiesInRange[i], "modifier_gun_blow_thistles", {duration=thistleDur})
            end
        end
    end
end

function CastPurge(keys)
    print("PURGE")
    local caster = keys.caster
    local target = keys.target
    if target == nil then
        target = caster
    end
    local abilityName = "ability_custom_purge"
    caster:AddAbility(abilityName)
    ab = caster:FindAbilityByName(abilityName)
    ab:SetLevel(1)
    print("trying to cast ability ", abilityName, "level", ab:GetLevel(), "on")
    caster:CastAbilityOnTarget(target, ab, -1)
    caster:RemoveAbility(abilityName)
    --dummy_caster:ForceKill(true)
end

function PotionPoisonUse(keys)
    local caster = keys.caster
    local oldItemName = keys.OldItemName
    local newItemName = keys.NewItemName
        for itemSlot = 0, 5, 1 do
        if caster ~= nil then
            local Item = killedUnit:GetItemInSlot( itemSlot )
            if Item ~= nil and Item:GetName() == oldItemName then
                local itemCharges = Item:GetCurrentCharges()
                local newItem = CreateItem(newItemName, nil, nil) 
                newItem:SetCurrentCharges(itemCharges)
                caster:RemoveItem(Item)
                caster:AddItem(itemName)
                return
            end
        end
    end
end


--The following code written by Internet Veteran, handle with care.
--It is suppose to do one of three different things after a 33% chance has succeded. Once suceeded it calls this function.
function PotionDiseaseUse(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local dieRoll = RandomInt(0, 2)
    
    print("Test your luck! " .. dieRoll)
    
    if dieRoll == 0 then
        ability:ApplyDataDrivenModifier(caster, target, "modifier_disease1", {duration = 10})
    elseif dieRoll == 1 then
        ability:ApplyDataDrivenModifier(caster, target, "modifier_disease2", { duration = 30})
    elseif dieRoll == 2 then
        ability:ApplyDataDrivenModifier(caster, target, "modifier_disease3", { duration = 15})
    end
end

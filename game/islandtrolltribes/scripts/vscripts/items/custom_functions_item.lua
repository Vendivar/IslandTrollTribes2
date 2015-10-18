--[[function DropItemOnDeath(keys) -- keys is the information sent by the ability
	print( '[ItemFunctions] DropItemOnDeath Called' )
	local killedUnit = EntIndexToHScript( keys.caster_entindex ) -- EntIndexToHScript takes the keys.caster_entindex, which is the number assigned to the entity that ran the function from the ability, and finds the actual entity from it.
	local itemName = tostring(keys.ability:GetAbilityName()) -- In order to drop only the item that ran the ability, the name needs to be grabbed. keys.ability gets the actual ability and then GetAbilityName() gets the configname of that ability such as juggernaut_blade_dance.
	if killedUnit:IsHero() or killedUnit:HasInventory() then -- In order to make sure that the unit that died actually has items, it checks if it is either a hero or if it has an inventory.
		for itemSlot = 0, 5, 1 do --a For loop is needed to loop through each slot and check if it is the item that it needs to drop
			if killedUnit ~= nil then --checks to make sure the killed unit is not nonexistent.
				local Item = killedUnit:GetItemInSlot( itemSlot ) -- uses a variable which gets the actual item in the slot specified starting at 0, 1st slot, and ending at 5,the 6th slot.
				if Item ~= nil and Item:GetName() == itemName and Item:GetName() ~= "item_slot_locked" then -- makes sure that the item exists and making sure it is the correct item
					local itemCharges = Item:GetCurrentCharges()
					local newItem = CreateItem(itemName, nil, nil) -- creates a new variable which recreates the item we want to drop and then sets it to have no owner
					newItem:SetCurrentCharges(itemCharges)
					CreateItemOnPositionSync(killedUnit:GetOrigin() + RandomVector(RandomInt(20,100)), newItem) -- takes the newItem variable and creates the physical item at the killed unit's location
					killedUnit:RemoveItem(Item) -- finally, the item is removed from the original units inventory.
				end
			end
		end
	end
end]]

function NetEnsnare(keys)
	local caster = keys.caster
	local target = keys.target
	local targetName = target:GetName()
	local dur = 8.0	--default duration for anything besides heros
	if (target:IsHero()) then --if the target's name includes "hero"
		dur = 3.5	--then we use the hero only duration
	elseif string.find(target:GetUnitName(), "hawk") then --if the target's name includes "hawk"
	target:RemoveModifierByName("modifier_hawk_flight")
	target:RemoveAbility("ability_hawk_flight")
	end
	target:AddNewModifier(caster, nil, "modifier_meepo_earthbind", {duration = dur})
end

function StoneStun(keys)
	local caster = keys.caster
	local target = keys.target
	local targetName = target:GetName()
	local dur = 7.0	--default duration for anything besides heros
	if (target:IsHero()) then --if the target's name includes "hero"
		dur = 1.0	--then we use the hero only duration
	end
	print("Stone Stunned!")
	target:AddNewModifier(caster, nil, "modifier_stunned", { duration = dur})
end

function EatMeatRaw(keys)	--triggers the meat eating channel ability
	---[[
	local caster = keys.caster
	local abilityName = "ability_item_eat_meat_raw"
	local ability = caster:FindAbilityByName(abilityName)
	if ability == nil then
		caster:AddAbility(abilityName)
		ability = caster:FindAbilityByName( abilityName )
		ability:SetLevel(1)		
	end
	print("trying to cast ability ", abilityName)
	caster:CastAbilityNoTarget(ability, -1)
	--caster:RemoveAbility(abilityName)
	--]]
end

function EatMeat( event )
	local ability = event.ability
	local caster = event.caster
	local heal = event.heal_amount

	if caster:HasModifier("modifier_priest_increasemetabolism") then
		if ability:GetName() == "ability_item_eat_meat_raw" then
			caster:Heal(1, caster)
		else
			caster:Heal(10, caster)
		end
	end
	caster:Heal(heal, caster)
end

function MageMasherManaBurn(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.Damage
	local targetName = target:GetUnitName()
	--look for mage and priests only
	if ((string.find(targetName,"mage") ~= nil) or (string.find(targetName,"priest")~= nil) or (string.find(targetName,"dazzle")~= nil) or (string.find(targetName,"witch")~= nil)) then
		--print("Burning " .. damage .. " mana")
		local startingMana = target:GetMana()
		target:SetMana(startingMana - damage)
		--print("Old mana " .. startingMana .. ". New Mana " .. target:GetMana())
		
		local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL}						

		ApplyDamage(damageTable)
		
		local thisParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:ReleaseParticleIndex(thisParticle)
		target:EmitSound("Hero_NyxAssassin.ManaBurn.Target")
	else
		print(targetName .. " is not Mage or Priest")
	end	
end

function SpearDarkThrow(keys)
	local caster = keys.caster
	local target = keys.target
	local damageMin = keys.DamageMin
	local damageMax = keys.DamageMax
	local randomDamage = RandomInt(damageMin, damageMax)
	-- damage energy here
	local dur = 2.0
	if (target:IsHero()) then --if the target's name includes "hero"
		dur = 0.5	--then we use the hero only duration
	end
	local startingMana = target:GetMana()
	target:SetMana(startingMana - randomDamage)
	
	local damageTable = {
	victim = target,
	attacker = caster,
	damage = randomDamage,
	damage_type = DAMAGE_TYPE_MAGICAL}

	ApplyDamage(damageTable)
	target:AddNewModifier(caster, nil, "modifier_stunned", { duration = dur})
	print("Spear hit! Burning " .. randomDamage .. " mana")
end

function SpearPoisonThrowInit(keys)
	local caster = keys.caster
	local target = keys.target
	local moveSpeedSlowPercent = keys.MoveSpeedSlow
	local attackSpeedSlowPercent = keys.AttackSpeedSlow

	if target.startingMoveSpeed == nil then
		print("fresh start")
		startingAttackTime = target:GetBaseAttackTime()
		startingMoveSpeed = target:GetBaseMoveSpeed()
		keys.target.startingMoveSpeed = startingMoveSpeed
		keys.target.startingAttackTime = startingAttackTime
	else
		print("refreshing")
		target:SetBaseMoveSpeed(target.startingMoveSpeed)
		target:SetBaseAttackTime(target.startingAttackTime)
		startingAttackTime = target:GetBaseAttackTime()
		startingMoveSpeed = target:GetBaseMoveSpeed()
	end

	print("Starting Movespeed: ".. target:GetBaseMoveSpeed() .. " AttackTime: " .. target:GetBaseAttackTime())

	local moveSpeedReduction = startingMoveSpeed*(moveSpeedSlowPercent/100)
	local attackSpeedReduction = startingAttackTime*(attackSpeedSlowPercent/100)

	target:SetBaseMoveSpeed(startingMoveSpeed - moveSpeedReduction)
	target:SetBaseAttackTime(startingAttackTime + attackSpeedReduction)	--higher base attack time = slower attack

	local numTicks = 30
	keys.target.moveSpeedSlowTick = moveSpeedReduction / numTicks
	keys.target.attackSpeedSlowTick = attackSpeedReduction / numTicks
	keys.target.tickNum = 0
	print("MS tick: ".. keys.target.moveSpeedSlowTick .. " AS tick: " .. keys.target.attackSpeedSlowTick)
	print("Slowed Movespeed: ".. target:GetBaseMoveSpeed() .. " AttackTime: " .. target:GetBaseAttackTime())
end

function SpearPoisonThrowTick(keys)
	local caster = keys.caster
	local target = keys.target

	target:SetBaseMoveSpeed(target.startingMoveSpeed - target.moveSpeedSlowTick*(30-target.tickNum))
	target:SetBaseAttackTime(target:GetBaseAttackTime() - target.attackSpeedSlowTick)
	keys.target.tickNum = keys.target.tickNum + 1
	print("Movespeed: ".. target:GetBaseMoveSpeed() .. " AttackTime: " .. target:GetBaseAttackTime())
end

function SpearPoisonEnd(keys)
	local caster = keys.caster
	local target = keys.target

	print(target, target.startingMoveSpeed)

	target:SetBaseMoveSpeed(target.startingMoveSpeed)
	target:SetBaseAttackTime(target.startingAttackTime)

	keys.target.startingMoveSpeed = nil
	keys.target.startingAttackTime = nil

	print("Ending Movespeed: ".. target:GetBaseMoveSpeed() .. " AttackTime: " .. target:GetBaseAttackTime())
end

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

  for _, unit in pairs(units) do
    if unit:IsHero() then
      redVal = 255
    end

    local thisParticle = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, caster:GetOwner())
    ParticleManager:SetParticleControl(thisParticle, 0, unit:GetAbsOrigin())
    ParticleManager:SetParticleControl(thisParticle, 1, Vector(redVal, greenVal, blueVal))
    PingMap(caster:GetPlayerID(),unit:GetAbsOrigin(),redVal,greenVal,blueVal)
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

function ReloadItem(keys)
	local caster = keys.caster
	local ammoItem = keys.ability
	local ammoCharges = ammoItem:GetCurrentCharges()
	local maximumAmmo = keys.MaxStacks
	if maximumAmmo == nil then
		maximumAmmo = 3
	end
	if ammoCharges == 0 then
		ammoCharges = 1 --to account for ammo like bone, with no charges
	end
	local emptyItem = keys.EmptyItem
	local loadedItem = keys.LoadedItem

	--looks for already loaded weapon of the same type first, then looks for empty
	for itemSlot = 0, 5, 1 do
		if caster ~= nil then
			local Item = caster:GetItemInSlot( itemSlot )
			if Item ~= nil and Item:GetName() == loadedItem then
				local itemCharges = Item:GetCurrentCharges() + ammoCharges
				if itemCharges > maximumAmmo then
					ammoItem:SetCurrentCharges(itemCharges - maximumAmmo)
					Item:SetCurrentCharges(maximumAmmo)
				else
					Item:SetCurrentCharges(itemCharges)
					caster:RemoveItem(ammoItem)
					return
				end
			end
		end
	end
	for itemSlot = 0, 5, 1 do
		if caster ~= nil then
			local Item = caster:GetItemInSlot( itemSlot )
			if Item~= nil and Item:GetName() == emptyItem then
				local itemCharges = Item:GetCurrentCharges() + ammoCharges
				local newItem = CreateItem(loadedItem, nil, nil)
				if itemCharges > maximumAmmo then
					ammoItem:SetCurrentCharges(itemCharges - maximumAmmo)
					newItem:SetCurrentCharges(maximumAmmo)
					caster:RemoveItem(Item)
					caster:AddItem(newItem)
				else
					newItem:SetCurrentCharges(ammoCharges)
					caster:RemoveItem(Item)
					caster:AddItem(newItem)
					caster:RemoveItem(ammoItem)
					return
				end

			end
		end
	end
end

function GunBlowCheckEmpty(keys)
	local caster = keys.caster
	local item = keys.ability

	if item:GetCurrentCharges() <= 0 then
		local emptyGun = CreateItem("item_gun_blow_empty", nil, nil)
		caster:RemoveItem(item)
		caster:AddItem(emptyGun)
	end
end

function SummonSkeleton(keys)
	local caster = keys.caster

	local skeleton1 = CreateUnitByName("npc_creature_scroll_skeleton", caster:GetOrigin() + RandomVector(RandomInt(100,200)), true, nil, caster, keys.caster:GetTeam())
	skeleton1.position = 90
	local skeleton2 = CreateUnitByName("npc_creature_scroll_skeleton", caster:GetOrigin() + RandomVector(RandomInt(100,200)), true, nil, caster, keys.caster:GetTeam())
	skeleton2.position = -90

end

function RawMagicUse(keys)
	local caster = keys.caster
	local dieRoll = RandomInt(0, 100)

	print("Test your luck! " .. dieRoll)
	if dieRoll <= 30 then -- 30% lose % hp
		local percentHealth = RandomFloat(0.10, 0.99)
		local damageTable = {
		victim = caster,
		attacker = caster,
		damage = caster:GetHealth()*percentHealth,
		damage_type = DAMAGE_TYPE_PURE}

		ApplyDamage(damageTable)
		print("Unlucky! " .. percentHealth .. " health damage")	
	elseif dieRoll <= 40 then -- 10% full heal
		caster:Heal(caster:GetMaxHealth(), nil)
		print("Lucky! Full heal!")
	elseif dieRoll <= 50 then -- 10% death
		caster:Kill(nil, caster)
		print("Unlucky! Death!")
	elseif dieRoll <= 60 then -- 10% time = midnight
		GameRules:SetTimeOfDay(0.00)
		print("Lucky? Midnight")
	elseif dieRoll <= 70 then -- 10% meteor
		local abilityName = "ability_magic_raw_meteor"
		local ability_magic_raw_meteor = caster:FindAbilityByName(abilityName)
		if ability_magic_raw_meteor == nil then
			caster:AddAbility(abilityName)
			ability_magic_raw_meteor = caster:FindAbilityByName(abilityName)
		end
		print("trying to cast ability_magic_raw_meteor")
		caster:CastAbilityOnPosition(caster:GetOrigin(), ability_magic_raw_meteor, -1)
		caster:RemoveAbility(abilityName)
		print("BOOM")
	elseif dieRoll <= 80 then -- 10% mana crystals
		local item1 = CreateItem("item_crystal_mana", nil, nil)
		local item2 = CreateItem("item_crystal_mana", nil, nil)
		CreateItemOnPositionSync(caster:GetOrigin() + RandomVector(RandomInt(20,100)), item1)
		CreateItemOnPositionSync(caster:GetOrigin() + RandomVector(RandomInt(20,100)), item2)
		print("Lucky! Crystals!")
	else -- 20% disco duck
		if (duckBoss == nil) then
			duckBoss = CreateUnitByName("npc_boss_disco_duck", Vector(0,0,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
			print(duckBoss:GetClassname())
			print(duckBoss:GetUnitName())
			print("AN ANCIENT EVIL HAS AWOKEN")
			ShowCustomHeaderMessage("#DiscoDuckSpawnMessage", -1, -1, 5)
		end
	end
end

function RawMagicMeteor(keys)
	local caster = keys.caster
	local startPoint = caster:GetAbsOrigin()
	startPoint.z = 3000
	startPoint = startPoint + RandomVector(RandomInt(-150,150))
	local endPoint = caster:GetAbsOrigin()
	endPoint.z = -3000
	local duration = Vector(0.75,0,0)

	print(startPoint, endPoint)

	local particle = ParticleManager:CreateParticle('particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf', PATTACH_CUSTOMORIGIN, dummy_unit)
	ParticleManager:SetParticleControl(particle, 0, startPoint)
	ParticleManager:SetParticleControl(particle, 1, endPoint)
	ParticleManager:SetParticleControl(particle, 2, duration)
	
	caster:SetContextThink(DoUniqueString('meteor_timer'),
			function()
				local endMeteor = ParticleManager:CreateParticle('particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf', PATTACH_CUSTOMORIGIN, dummy_unit)
				ParticleManager:SetParticleControl(endMeteor, 0, endPoint)
				ParticleManager:DestroyParticle(endMeteor, false)
				ParticleManager:ReleaseParticleIndex(endMeteor)
				ParticleManager:DestroyParticle(particle, true)
				ParticleManager:ReleaseParticleIndex(particle)
			end,
			0.75)

end

function TsunamiProjectiles(keys)
	local caster = keys.caster
	--A Liner Projectile must have a table with projectile info
	local info = 
	{
		--Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_morphling/morphling_waveform.vpcf",
        iMoveSpeed = 1215,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 615,
        fStartRadius = 0,
        fEndRadius = 0,
        Source = keys.caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
	}
	--Creates the 7 projectiles in the 57.5 degree cone
	for i=-15,15,(15) do
		info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * info.iMoveSpeed
		fDistance = 615/math.cos(math.rad(i))
		print(i, math.sin(math.rad(i)), math.rad(i), fDistance)
		projectile = ProjectileManager:CreateLinearProjectile(info)
	end
end

function TsunamiDestroyFire(keys)
	local target = keys.target
	local targetName = target:GetUnitName()
	if (string.find(targetName,"fire") ~= nil) then
		target:ForceKill(true)
		print(targetName)
		--Should spawn a firekit at that position
	end
end

--The following code written by Internet Veteran, handle with care.
--It is suppose to do one of three different things after a 33% chance has succeded. Once suceeded it calls this function.
function PotionDiseaseUse(keys)
	local caster = keys.caster
	local target = keys.target
	local dieRoll = RandomInt(0, 2)
	
	print("Test your luck! " .. dieRoll)
	
	if dieRoll == 0 then
		target:AddNewModifier(caster, nil, "modifier_disease1", { duration = 100})
	elseif dieRoll == 1 then
		target:AddNewModifier(caster, nil, "modifier_disease2", { duration = 300})
	elseif dieRoll == 2 then
		target:AddNewModifier(caster, nil, "modifier_disease3", { duration = 150})
	end
end

function CloakProtectFail(keys)
	local caster = keys.caster
	local attackingUnit = keys.attacker
	print(attackingUnit:GetName(), attackingUnit:GetAverageTrueAttackDamage())

	local damageTable = {
		victim = caster,
		attacker = attackingUnit,
		damage = attackingUnit:GetAverageTrueAttackDamage(),
		damage_type = DAMAGE_TYPE_PHYSICAL}						

		ApplyDamage(damageTable)
end

function CloakCamouflageInvis(keys)
	local caster = keys.caster
	ParticleManager:CreateParticle("particles/status_fx/status_effect_medusa_stone_gaze.vpcf", PATTACH_ROOTBONE_FOLLOW, caster)

	--print("attempt cloak")

	if GridNav:IsNearbyTree(caster:GetOrigin(), 150, true) then
		
		caster.invisLocation = caster:GetOrigin()
		caster.startTime = GameRules:GetGameTime()
		caster:SetContextThink("CloakCamouflageInvis", CamouflageInvisCheck, 1.0)
	end
end

function CamouflageInvisCheck(caster)
	local originalPos = caster.invisLocation
	if math.ceil(GameRules:GetGameTime() - caster.startTime) == 3 then
		--print("invis fade time over")
		local modApplier = CreateItem("item_coat_camouflage", caster, caster)
		modApplier:ApplyDataDrivenModifier(caster, caster, "modifier_coat_camouflage_invis", {duration = -1})
		caster:AddNewModifier(caster, nil, "modifier_persistent_invisibility", {duration = -1, hidden = true})
	end

	if math.ceil(GameRules:GetGameTime() - caster.startTime) % 3 == 0 then
		--print("losing more stats!")
		local heat = caster:GetModifierStackCount("modifier_heat_passive", nil)
		caster:SetModifierStackCount("modifier_heat_passive", nil, heat - 2)
		caster:ReduceMana(2)
		caster:ModifyHealth(caster:GetHealth()-2, caster,true,-2)
	end

	if caster:GetOrigin() ~= originalPos then
		--print("invis broken")
		caster:RemoveModifierByName("modifier_coat_camouflage_invis")
		caster:RemoveModifierByName("modifier_persistent_invisibility")
		return nil
	end

	return 1.0
end

function SonarCompassUse(keys)
	local caster = keys.caster
    local unitTable = keys.UnitTable
    print("SonarCompassUse")
    PrintTable(unitTable)
    local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                      Vector(0, 0, 0),
                      nil,
                      FIND_UNITS_EVERYWHERE,
                      DOTA_UNIT_TARGET_TEAM_BOTH,
                      DOTA_UNIT_TARGET_ALL,
                      DOTA_UNIT_TARGET_FLAG_NONE,
                      FIND_ANY_ORDER,
                      false)
    for _,unit in pairs(units) do
    	for unitName,unitColor in pairs(unitTable) do
    		if unitName == unit:GetUnitName() then
	    		if unitColor == nil then
		            unitColor = "255 255 255"
		        end
		        local stringParse = string.gmatch(unitColor, "%d+")
		    
		        --need to divide by 255 to convert to 0-1 scale
		        local redVal = tonumber(stringParse())/255
		        local greenVal = tonumber(stringParse())/255
		        local blueVal = tonumber(stringParse())/255

		        print("pinging", unit:GetUnitName(), "at", unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, unit:GetAbsOrigin().z)
                --maybe use CreateParticleForPlayer(string particleName, int particleAttach, handle owningEntity, handle owningPlayer)
                local thisParticle = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, unit)
                ParticleManager:SetParticleControl(thisParticle, 0, unit:GetAbsOrigin())
                ParticleManager:SetParticleControl(thisParticle, 1, Vector(redVal, greenVal, blueVal))
                print(itemName, redVal, greenVal, blueVal)
                ParticleManager:ReleaseParticleIndex(thisParticle)
                unit:EmitSound("General.Ping")   --may be deafening
    		end
    	end
	end


end

function AddHeat(keys)
	local caster = keys.caster
	local target = keys.target

	if target == nil then
		target = caster
	end
	local heatToAdd = keys.Heat
	local heatStackCount = target:GetModifierStackCount("modifier_heat_passive", nil) + heatToAdd
	if heatStackCount > 100 then
		heatStackCount = 100
	end
	if heatStackCount <= 0 then
		heatStackCount = 1
	end
    target:SetModifierStackCount("modifier_heat_passive", nil, heatStackCount)
end

function PrintTest(keys)
	print("Test ")
end

function DebugSpawnAllHeroes(keys)
	local caster = keys.caster
	local unitTable = {		
		"npc_dota_hero_shadow_shaman",
		"npc_hero_herbmaster_tele_gatherer",
		"npc_hero_radar_tele_gatherer",
		"npc_hero_remote_tele_gatherer",
		"npc_dota_hero_huskar",
		"npc_hero_hunter_tracker",
		"npc_hero_hunter_warrior",
		"npc_hero_hunter_juggernaught",
		"npc_dota_hero_witch_doctor",
		"npc_hero_mage_elementalist",
		"npc_hero_mage_hypnotist",
		"npc_hero_mage_dementia_master",
		"npc_dota_hero_lion",
		"npc_hero_scout_observer",
		"npc_hero_scout_radar",
		"npc_hero_scout_spy",
		"npc_dota_hero_riki",
		"npc_hero_thief_escape_artist",
		"npc_hero_thief_contortionist",
		"npc_hero_thief_assassin",
		"npc_dota_hero_lycan",
		"npc_hero_beastmaster_packleader",
		"npc_hero_beastmaster_form_chicken",
		"npc_hero_beastmaster_shapeshifter",
		"npc_dota_hero_dazzle",
		"npc_hero_priest_booster",
		"npc_hero_priest_master_healer",
		"npc_hero_priest_sage"}

	for key,value in pairs(unitTable) do
		local spawnLocationX = (key-1)%4
		spawnLocationY = math.floor((key-1)/4)
		spawnLocation = Vector(1,0,0)*spawnLocationX*200 + Vector(0,-1,0)*spawnLocationY*300 + Vector(1,0,0)*200
		local unit = CreateUnitByName(value, caster:GetOrigin() + spawnLocation, true, nil, nil, caster:GetTeam())
		unit.vOwner = caster:GetOwner()
		unit:SetControllableByPlayer(caster:GetOwner():GetPlayerID(), true )
		unit:SetForwardVector(Vector(0,-1,0))
	end
end

function DebugSpawnAllCreeps(keys)
	print("Debug: Spawn All Creeps")
	local caster = keys.caster
	local owner = caster:GetOwner()
	local unitTable = {
		"npc_creep_fawn",
		"npc_creep_wolf_pup",
		"npc_creep_bear_cub",
		"npc_creep_mammoth_baby",
		"npc_creep_elk_pet",
		"npc_creep_elk_adult",
		"npc_creep_bear_jungle_adult",
		"npc_creep_drake_bone",
		"npc_creep_harpy_red",
		"npc_creep_bat_forest",
		"npc_creep_drake_nether",
		"npc_creep_fish",
		"npc_creep_fish_green",
		"npc_creep_elk_wild",
		"npc_creep_hawk",
		"npc_creep_wolf_jungle",
		"npc_creep_wolf_ice",
		"npc_creep_wolf_jungle_adult",
		"npc_creep_bear_jungle",
		"npc_creep_lizard",
		"npc_creep_panther",
		"npc_creep_panther_elder"
}
	for key,npcName in pairs(unitTable) do
		local spawnLocationX = (key-1)%6
		spawnLocationY = math.floor((key-1)/6)
		spawnLocation = Vector(1,0,0)*spawnLocationX*200 + Vector(0,-1,0)*spawnLocationY*300 + Vector(1,0,0)*200
		local unit = CreateUnitByName(npcName, caster:GetOrigin() + spawnLocation, true, nil, nil, caster:GetTeam())
		if unit == nil then
			print(npcName)
		end
		unit.vOwner = caster:GetOwner()
		unit:SetControllableByPlayer(caster:GetOwner():GetPlayerID(), true )
		unit:SetForwardVector(Vector(0,-1,0))
	end
end

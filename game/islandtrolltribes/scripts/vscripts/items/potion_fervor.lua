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
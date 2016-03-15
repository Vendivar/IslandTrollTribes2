require('libraries/selection')


function CheckForBeacon(evt)
	local unit = evt.caster;
	local players = ITT:GetPlayersOnTeam(DOTA_TEAM_GOODGUYS)

	if unit:GetUnitName() == "npc_building_teleport_beacon" then
		if (unit:GetLevel() < 4) then
			evt.ability:RemoveSelf()
			unit:CreatureLevelUp(1)
			local particleName = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf"
			ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, unit)
			local teleport_ability = unit:GetAbilityByIndex(0)
			teleport_ability:UpgradeAbility(false)
			for i, v in pairs( players ) do
				if PlayerResource:IsUnitSelected(v,unit) then
					PlayerResource:ResetSelection(v)
					Timers:CreateTimer(0.03, function()
					   PlayerResource:NewSelection(v, unit)
				    end)
				end
			end
		end
	end
end
teleport_beacon = class({})

function Activate(event)

	CustomGameEventManager:RegisterListener("player_teleport_beacon", Dynamic_Wrap(teleport_beacon, "OnRightClick"))
end

function Spawn(entityKeyValues)
    local lockedSlotCount = 5
    ITT:CreateLockedSlotsForUnits(thisEntity, lockedSlotCount)
 end 

function teleport_beacon:OnRightClick(event)

	local playerHero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
	local building = EntIndexToHScript(event.entityIndex)

	local spell = building:GetAbilityByIndex(0)
	building:CastAbilityOnTarget(playerHero, spell, event.PlayerID)
end
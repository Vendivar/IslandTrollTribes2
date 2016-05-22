if not CraftMaster then
    CraftMaster = class({})
end

function CraftMaster:Spawn()
    local ent = Entities:FindByName(nil, "craftmaster")
    local position = ent and ent:GetAbsOrigin() or Vector(0,0,388)
    print("Spawning CraftMaster at "..VectorString(position))

    self.unit = BuildingHelper:PlaceBuilding(-1, "npc_building_craftmaster", position)
    self.unit:AddNewModifier(self.unit, nil, "modifier_invulnerable", {})
    self.currentOwner = DOTA_TEAM_NEUTRALS
    self.radius = 600

    Timers:CreateTimer(1, function()
        self:Think()
        return 1
    end)

end

function CraftMaster:Think()
    local newOwner
    local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS
    local heroes = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, self.unit:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, flags, FIND_CLOSEST, false)
    if #heroes > 0 then
        for _,hero in pairs(heroes) do
            -- First player to enter the area sets the ownership and share-ability of the building while inside its usage radius. 
            if not newOwner then
                newOwner = hero:GetTeamNumber()
            -- If another player from an enemy team comes near, they will have to kill the players who were in possession of the building earlier.
            elseif newOwner ~= hero:GetTeamNumber() then
                newOwner = self.currentOwner
            end
        end
    else
        newOwner = DOTA_TEAM_NEUTRALS
    end

    if newOwner ~= self.currentOwner then
        self.currentOwner = newOwner
        self.unit:SetTeam(self.currentOwner)
        print("[CraftMaster] Ownership changed to "..TEAM_NAMES[self.currentOwner])

        if newOwner ~= DOTA_TEAM_NEUTRALS then
            local players = ITT:GetPlayersOnTeam(newOwner)
            for _,playerID in pairs(players) do
                if PlayerResource:GetSelectedHeroEntity(playerID) then
                    print("[CraftMaster] Now in control of Player "..playerID)
                    self.unit:SetOwner(PlayerResource:GetSelectedHeroEntity(playerID))
                    self.unit:SetControllableByPlayer(playerID, true)
                    break
                end
            end
        end
    end
end
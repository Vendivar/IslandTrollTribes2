XP_RANGE = 1200
XP_MULTIPLIER = 4
XP_BOUNTY_TABLE = {
    25, --1
    40, --2 +15
    60, --3 +20
    85, --4 +25
    115,--5 +30
    150,--6 +35
    190,--7 +40
    235,--8 +45
    285,--9 +50
    340--10 +55
}
XP_BOUNTY_TABLE[0] = 25

function CDOTA_BaseNPC_Creature:SplitExperienceBounty(teamID)
    local killed = self
    local level = killed:GetLevel()
    local killedTeam = killed:GetTeamNumber()
    local XPGain = XP_BOUNTY_TABLE[killed:GetLevel()] * XP_MULTIPLIER

    local heroesNearby = FindUnitsInRadius(killed:GetTeamNumber(), killed:GetAbsOrigin(), nil, XP_RANGE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
    local validHeroes = {}
    for _,hero in pairs(heroesNearby) do
        if hero:IsRealHero() and hero:GetTeamNumber() ~= killedTeam then
            -- If the hero in range was part of who did the last hit, always give XP
            if hero:GetTeamNumber() == teamID then
                table.insert(validHeroes, hero)

            -- Otherwise, they need to have done damage to the killed creep
            elseif killed.attackers and killed.attackers[hero:GetEntityIndex()] then
                table.insert(validHeroes, hero)
            end
        end
    end

    for _,hero in pairs(validHeroes) do
        local xp = math.floor( XPGain / #validHeroes )
        hero:AddExperience(xp, 0, false, false)
        PopupExperience(hero, xp)
    end
end
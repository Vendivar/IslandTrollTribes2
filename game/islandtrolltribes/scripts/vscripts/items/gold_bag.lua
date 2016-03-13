function GrantGold( event )
    local caster = event.caster
    local item = event.ability
    local teamID = caster:GetTeamNumber()
    local gold = item.gold -- Stored on player death
    local split_radius = 500

    local heroesNearby = FindUnitsInRadius(teamID, caster:GetAbsOrigin(), nil, split_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
    local validHeroes = {}
    for _,hero in pairs(heroesNearby) do
        if hero:IsRealHero() then
            table.insert(validHeroes, hero)
        end
    end

    local gold_per_hero = math.floor(gold/#validHeroes+0.5)
    for _,hero in pairs(validHeroes) do
        hero:ModifyGold(gold_per_hero, false, 0)
        PopupGoldGain(hero, gold_per_hero, teamID)
    end

    item:RemoveSelf()
end
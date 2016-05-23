-- Lose all gold, create a bag containing all of it, can be picked up by allies or enemies
function CreateGoldBag(hero)
    local gold = hero:GetGold()
    hero:SetGold(0, true)
    hero:SetGold(0, false)

    -- Don't make a gold bag with 0 gold
    if not gold or gold == 0 then
        return
    end

    local pos = hero:GetAbsOrigin()
    local goldBag = CreateItem("item_gold_bag", nil, nil)
    local pos_launch = pos + Vector(64,0,0)
    local goldBagLaunch = CreateItemOnPositionSync(pos, goldBag)
    goldBag:LaunchLoot(false, 300, 1, pos_launch)

    gold = gold > 500 and 500 or gold --Restrict the size to 2.0
    local size = (gold / 500) + 1
    if goldBag then
        local drop = goldBag:GetContainer()
        goldBagLaunch.gold = gold
        goldBag.gold = gold
        if drop then
            drop:SetModelScale(size)
        end
    end
end

function SplitGoldBag(hero, item)
    local teamNumber = hero:GetTeamNumber()
    local gold = item.gold or 0 -- Stored on player death
    local split_radius = 500

    local heroesNearby = FindUnitsInRadius(teamNumber, hero:GetAbsOrigin(), nil, split_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
    local validHeroes = {}
    for _,hero in pairs(heroesNearby) do
        if hero:IsRealHero() then
            table.insert(validHeroes, hero)
        end
    end

    local gold_per_hero = math.ceil(gold/#validHeroes)
    for _,v in pairs(validHeroes) do
        v:ModifyGold(gold_per_hero, false, 0)
        PopupGoldGain(v, gold_per_hero, teamNumber)
    end

    UTIL_Remove(item)
end
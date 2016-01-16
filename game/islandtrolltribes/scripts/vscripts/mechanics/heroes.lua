------------------------------------------------
--               Class functions              --
------------------------------------------------

function GetHeroClass( hero )
    return GameRules.ClassInfo['HeroClassNames'][hero:GetUnitName()]
end

function GetSubClass( hero )
    return hero.subclass or 'none'
end

function HasSubClass( hero )
    return GetSubClass(hero) ~= 'none'
end


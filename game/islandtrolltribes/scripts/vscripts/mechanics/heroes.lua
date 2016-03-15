------------------------------------------------
--               Class functions              --
------------------------------------------------

function CDOTA_BaseNPC_Hero:GetHeroClass()
    return GameRules.ClassInfo['HeroClassNames'][self:GetUnitName()]
end

function CDOTA_BaseNPC_Hero:GetSubClass()
    return self.subclass or 'none'
end

function CDOTA_BaseNPC_Hero:HasSubClass()
    return self:GetSubClass() ~= 'none'
end
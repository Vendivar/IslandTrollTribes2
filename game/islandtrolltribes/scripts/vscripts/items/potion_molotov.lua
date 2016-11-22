function MolotovHit(event)
    local caster = event.caster
    local item = event.ability
    local radius = item:GetLevelSpecialValueFor("radius", 1)
    local duration_building = item:GetLevelSpecialValueFor("duration_building", 1)
    local duration_creep = item:GetLevelSpecialValueFor("duration_creep", 1)
    local duration_hero = item:GetLevelSpecialValueFor("duration_hero", 1)

    local teamNumber = caster:GetTeamNumber()
    local casterOrigin = caster:GetOrigin()
    local units = FindUnitsInRadius(teamNumber, casterOrigin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

    for _,enemy in pairs(units) do
        enemy:EmitSound("molotov.hit")
        if string.find(enemy:GetUnitName(), "npc_building_")  then
            item:ApplyDataDrivenModifier(caster, enemy, "modifier_molotov_burn", {duration=duration_building})
            enemy:EmitSound("molotov.burn")
        elseif enemy:IsHero() then
            item:ApplyDataDrivenModifier(caster, enemy, "modifier_molotov_burn", {duration=duration_hero})
            enemy:EmitSound("molotov.burn")
        elseif not enemy:IsMagicImmune() then
            item:ApplyDataDrivenModifier(caster, enemy, "modifier_molotov_burn", {duration=duration_creep})
            enemy:EmitSound("molotov.burn")
        end
    end
end

function MolotovDamage(event)
    local damage = 2 --can't use ability handle because the item is removed
    local caster = event.caster
    local target = event.target
    target:EmitSound("molotov.burn")

    if string.find(target:GetUnitName(), "npc_building_") then
        DamageBuilding(target, damage, nil, caster)
    else
        ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, })
    end
end


function MolotovSoundStop( event )
	local caster = event.caster
	
	target:StopSound("Hero_Juggernaut.HealingWard.Loop")
end
function molotov(event)
    local caster = event.caster
    local item = event.ability
    local radius = item:GetLevelSpecialValueFor("radius", 1)
    local duration= item:GetLevelSpecialValueFor("duration_building", 1)
    --local aoeParticle = "particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf"

    local teamNumber = caster:GetTeamNumber()
    local casterOrigin = caster:GetOrigin()
    local units = FindUnitsInRadius(teamNumber, casterOrigin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    
    --print("testing EMP, x: " .. casterOrigin.x .. " y: " .. casterOrigin.y .. " dur: " .. duration .. " radius " .. radius)

    for _,enemy in pairs(units) do
        enemy:EmitSound("molotov.hit")
        --print("found enemy: " .. enemy:GetUnitName())
         if string.find(enemy:GetUnitName(), "npc_building_")  then
            print("disabling " .. enemy:GetUnitName())
            item:ApplyDataDrivenModifier(caster, enemy, "modifier_molotov_burn", {duration=duration})
            ApplyDamage({victim = target, attacker = caster, damage = 100, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS})
        end
    end

end
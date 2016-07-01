function EMP(event)
    local caster = event.caster
    local item = event.ability
    local radius = item:GetLevelSpecialValueFor("radius", 1)
    local duration= item:GetLevelSpecialValueFor("duration", 1)
    local aoeParticle = "particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf"

    local teamNumber = caster:GetTeamNumber()
    local casterOrigin = caster:GetOrigin()
    local units = FindUnitsInRadius(teamNumber, casterOrigin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,  DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    
    --print("testing EMP, x: " .. casterOrigin.x .. " y: " .. casterOrigin.y .. " dur: " .. duration .. " radius " .. radius)

    for _,enemy in pairs(units) do
        enemy:EmitSound("Hero_Disruptor.ThunderStrike.Target")
        --print("found enemy: " .. enemy:GetUnitName())
        if (enemy:GetUnitName() == "npc_building_tower_omni") or (enemy:GetUnitName() == "npc_building_ensnare_trap") then
            --print("disabling " .. enemy:GetUnitName())
            item:ApplyDataDrivenModifier(caster, enemy, "modifier_emp", {duration=duration})
        end
    end

    --Remove charges
    item:SetCurrentCharges(item:GetCurrentCharges() - 1)
    print("charges" .. item:GetCurrentCharges())
    if item:GetCurrentCharges() <= 0 then
        item:RemoveSelf()
    end
end
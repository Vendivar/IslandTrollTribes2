function NetGround( event )
    local caster = event.caster
    local item = event.ability
    local point = event.target_points[1]
    local speed = item:GetSpecialValueFor("projectile_speed")
    local radius = item:GetSpecialValueFor("radius")
    local duration_hero = item:GetSpecialValueFor("duration_hero")
    local duration_animal = item:GetSpecialValueFor("duration_animal")
    local particleName = "particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf"

    local projectile = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(projectile, 0, caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")))
    ParticleManager:SetParticleControl(projectile, 1, point)
    ParticleManager:SetParticleControl(projectile, 2, Vector(speed, 0, 0))
    ParticleManager:SetParticleControl(projectile, 3, point)

    local distanceToTarget = (caster:GetAbsOrigin() - point):Length2D()
    local time = distanceToTarget/speed
    Timers:CreateTimer(time, function()
        ParticleManager:DestroyParticle(projectile, false)
        
        local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, 0, 0, false)
        for _,enemy in pairs(units) do
            enemy:EmitSound("Hero_Meepo.Earthbind.Target")
            if enemy:IsHero() then
                item:ApplyDataDrivenModifier(caster, enemy, "modifier_hunting_ensnare", {duration=duration_hero})
            else
                item:ApplyDataDrivenModifier(caster, enemy, "modifier_hunting_ensnare", {duration=duration_animal})
            end
        end

        -- Remove charges
        item:SetCurrentCharges(item:GetCurrentCharges() - 1)
        if item:GetCurrentCharges() == 0 then
            item:RemoveSelf()
        end
    end)
end
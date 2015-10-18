function FleaAttack(keys)
    local caster = keys.caster
    local level = caster:GetLevel()
    local casterPosition = caster:GetAbsOrigin()
    local teamnumber = caster:GetTeamNumber()
    local particle = keys.Particle
    local cooldown = 0

    -- hero level, cooldown
    local cooldownValues = {
        {1, 1.0},
        {2, 0.95},
        {3, 0.90},
        {5, 0.85},
        {8, 0.80},
        {13,0.75},
        {21,0.70},
        {30,0.70}
    }

    -- get cooldown time
    for i = 1, #cooldownValues do
        local stats = cooldownValues[i]
        if level < stats[1] then
            break
        else
            cooldown = stats[2]
        end
    end

    -- only run if flea attack is off cooldown
    if not caster:HasModifier("modifier_fleacooldown") then
        local target = nil

        -- check for valid targets
        local units = FindUnitsInRadius(teamnumber,
                                casterPosition,
                                nil,
                                400,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_ALL,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_ANY_ORDER,
                                false)
        -- select random target
        local dieRoll = RandomInt(1,#units)
        local target = units[dieRoll]

        if target ~= nil then
            -- fire flea attack projectile
            local info =
            {
                Ability = keys.ability,
                Target = target,
                Source = caster,
                EffectName = particle,
                vSpawnOrigin = casterPosition,
                bProvidesVision = false,
                bDeleteOnHit = true,
                bDodgeable = true,
                flExpireTime = 7.0,
                iMoveSpeed = 1000
            }
            projectile = ProjectileManager:CreateTrackingProjectile(info)
            -- track which target has been hit
            caster.fleaTarget = target

            -- apply cooldown modifier
            local item = CreateItem("item_fleaattackcooldown_modifier_applier", caster, caster)
            item:ApplyDataDrivenModifier(caster, caster, "modifier_fleacooldown", {duration=cooldown})
        end
    end
end

function FleaAttackDamage(keys)
    local caster = keys.caster
    local target = keys.caster.fleaTarget
    local level = caster:GetLevel()

    local dmg = 0
    local dps = 0
    local dpsDur = 2

    local attackValues = {
        {1, 12, 3.0},
        {2, 13, 3.1},
        {3, 14, 3.2},
        {5, 15, 3.3},
        {8, 16, 3.4},
        {13,19, 3.5},
        {21,24, 3.6},
        {30,28, 3.7}
    }

    -- get damage values
    for i = 1, #attackValues do
        local stats = attackValues[i]
        if level < stats[1] then
            break
        else
            dmg = stats[2]
            dps = stats[3]
        end
    end

    -- apply damage
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL
    }
    ApplyDamage(damageTable)

    -- apply DPS
    target.caster = caster
    target.duration = dpsDur
    target.startTime = GameRules:GetGameTime()
    target.dps = dps
    target:SetContextThink("flea_dps", FleaAttackDPS, 1.0)
end

function FleaAttackDPS(target)
    if (GameRules:GetGameTime() - target.startTime) >= target.duration then
        return nil
    else
        local damageTable = {
            victim = target,
            attacker = target.caster,
            damage = target.dps,
            damage_type = DAMAGE_TYPE_MAGICAL
        }
        ApplyDamage(damageTable)
    end
    return 1.0
end
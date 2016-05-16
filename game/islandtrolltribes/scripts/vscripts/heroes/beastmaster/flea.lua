function FleaAttack(keys)
    local caster = keys.caster
    local ability = keys.ability
    local level = caster:GetLevel()
    local casterPosition = caster:GetAbsOrigin()
    local teamnumber = caster:GetTeamNumber()
    local particleName = "particles/custom/weaver_base_attack.vpcf"

    local cooldown = ability:GetLevelSpecialValueFor("cooldown", level-1)

    if ability:IsCooldownReady() then

        -- check for valid targets
        local units = FindUnitsInRadius(teamnumber, casterPosition, nil, ability:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
        
        if #units > 0 then
            for k,v in pairs(units) do
                -- if not IsFlyingUnit(v) then
            
                    -- select random target
                    local target = units[RandomInt(1,#units)]

                    -- fire flea attack projectile
                    local info =
                    {
                        Ability = ability,
                        Target = target,
                        Source = caster,
                        EffectName = particleName,
                        vSpawnOrigin = casterPosition,
                        bProvidesVision = false,
                        bDeleteOnHit = true,
                        bDodgeable = true,
                        iMoveSpeed = 1000
                    }
                    projectile = ProjectileManager:CreateTrackingProjectile(info)

                    -- apply cooldown
                    ability:StartCooldown(cooldown)

                    break
            end
        end
    end
end

function FleaAttackHit(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local level = caster:GetLevel()

    local dmg = ability:GetLevelSpecialValueFor("damage", level-1)
    local dpsDur = 1.65
    
    -- apply damage
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL
    }
    ApplyDamage(damageTable)

    -- apply DPS
    ability:ApplyDataDrivenModifier(caster, target, "modifier_flea_debuff", {duration = dpsDur})
end
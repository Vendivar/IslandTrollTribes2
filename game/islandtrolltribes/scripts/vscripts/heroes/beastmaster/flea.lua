function FleaAttack(keys)
    local caster = keys.caster
    local ability = keys.ability
    local level = caster:GetLevel()
    local casterPosition = caster:GetAbsOrigin()
    local teamnumber = caster:GetTeamNumber()
    local particleName = "particles/custom/weaver_base_attack.vpcf"

    local cooldown = ability:GetLevelSpecialValueFor("cooldown", level-1)

    if ability:IsCooldownReady() and not caster:HasModifier("modifier_brewmaster_storm_cyclone") then

        -- check for valid targets
        local units = FindUnitsInRadius(teamnumber, casterPosition, nil, ability:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
        

        if #units > 0 then
            units = ShuffledList(units) --randomize
            for k,v in pairs(units) do
              --  if not IsFlyingUnit(v) then
                    -- fire flea attack projectile
                    local info =
                    {
                        Ability = ability,
                        Target = v,
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
                -- end
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
    local damageTable1 = {
        victim = target,
        attacker = caster,
        damage = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
    }
    ApplyDamage(damageTable1)
else
    local damageTable2 = {
        victim = target,
        attacker = caster,
        damage = dmg,
        damage_type = DAMAGE_TYPE_PHYSICAL,
    }
    ApplyDamage(damageTable2)
    end
    -- apply DPS
    ability:ApplyDataDrivenModifier(caster, target, "modifier_flea_debuff", {duration = dpsDur})
end
end

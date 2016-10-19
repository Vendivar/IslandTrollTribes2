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
                if not v:GetUnitName():match("npc_creep_corpse") and (not v:IsMagicImmune() or v:GetUnitName():match("building")) then
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
                end
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
    local dpsDur = 0.8
    local name = target:GetUnitName()

    if target:IsMagicImmune() then
        -- Do Building Damage
        local currentHP = target:GetHealth()
        local newHP = currentHP - dmg

        -- If the HP would hit 0 with this damage, kill the unit
        if newHP <= 0 then
            target:Kill(ability, caster)
        else
            target:SetHealth(newHP)
        end
    else
        ApplyDamage({victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, })
    end

    -- apply DPS
    ability:ApplyDataDrivenModifier(caster, target, "modifier_flea_debuff", {duration = dpsDur})
end

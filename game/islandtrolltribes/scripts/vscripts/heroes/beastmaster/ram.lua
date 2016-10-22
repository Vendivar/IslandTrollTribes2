function RamTarget(keys)
    local caster = keys.caster
    local target = keys.target
    local damage = keys.Damage
    local stunDuration = keys.StunDuration
    local casterPosition = caster:GetAbsOrigin()
    local targetPosition = target:GetAbsOrigin()
    local visible = caster:CanEntityBeSeenByMyTeam(target)
    local teamnumber = caster:GetTeamNumber()
    local hitUnits = {}

    if visible and target and not target.HasFlyMovementCapability and not IsFlyingUnit(target) then
        local direction = targetPosition - casterPosition
        local vec = direction:Normalized() * 30
        caster:SetAbsOrigin(casterPosition + vec)
        FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),true)

        -- check collision
        local units = FindUnitsInRadius(teamnumber,
                                casterPosition,
                                nil,
                                100,
                                DOTA_UNIT_TARGET_TEAM_ENEMY,
                                DOTA_UNIT_TARGET_HERO,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_ANY_ORDER,
                                false)
        for _,unit in pairs(units) do
            local alreadyHit = false
            for i = 1, #hitUnits do
                if hitUnits[i] == unit then
                    alreadyHit = true
                end
            end

            if alreadyHit == false then
                local damageTable = {
                    victim = unit,
                    attacker = caster,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_MAGICAL
                }
                ApplyDamage(damageTable)
                unit:AddNewModifier(caster, nil, "modifier_stunned", { duration = stunDuration})
                table.insert(hitUnits, unit)
                target:RemoveModifierByName("modifier_charged")
                local ram = caster:FindAbilityByName("ability_beastmaster_ram")
                ram:EndChannel(true)
            end
        end
    end
end
function SpearPoisonThrowInit(keys)
    local caster = keys.caster
    local target = keys.target
    local moveSpeedSlowPercent = keys.MoveSpeedSlow
    local attackSpeedSlowPercent = keys.AttackSpeedSlow

    if target.startingMoveSpeed == nil then
        print("fresh start")
        startingAttackTime = target:GetBaseAttackTime()
        startingMoveSpeed = target:GetBaseMoveSpeed()
        keys.target.startingMoveSpeed = startingMoveSpeed
        keys.target.startingAttackTime = startingAttackTime
    else
        print("refreshing")
        target:SetBaseMoveSpeed(target.startingMoveSpeed)
        target:SetBaseAttackTime(target.startingAttackTime)
        startingAttackTime = target:GetBaseAttackTime()
        startingMoveSpeed = target:GetBaseMoveSpeed()
    end

    print("Starting Movespeed: ".. target:GetBaseMoveSpeed() .. " AttackTime: " .. target:GetBaseAttackTime())

    local moveSpeedReduction = startingMoveSpeed*(moveSpeedSlowPercent/100)
    local attackSpeedReduction = startingAttackTime*(attackSpeedSlowPercent/100)

    target:SetBaseMoveSpeed(startingMoveSpeed - moveSpeedReduction)
    target:SetBaseAttackTime(startingAttackTime + attackSpeedReduction) --higher base attack time = slower attack

    local numTicks = 30
    keys.target.moveSpeedSlowTick = moveSpeedReduction / numTicks
    keys.target.attackSpeedSlowTick = attackSpeedReduction / numTicks
    keys.target.tickNum = 0
    print("MS tick: ".. keys.target.moveSpeedSlowTick .. " AS tick: " .. keys.target.attackSpeedSlowTick)
    print("Slowed Movespeed: ".. target:GetBaseMoveSpeed() .. " AttackTime: " .. target:GetBaseAttackTime())
end

function SpearPoisonThrowTick(keys)
    local caster = keys.caster
    local target = keys.target

    target:SetBaseMoveSpeed(target.startingMoveSpeed - target.moveSpeedSlowTick*(30-target.tickNum))
    target:SetBaseAttackTime(target:GetBaseAttackTime() - target.attackSpeedSlowTick)
    keys.target.tickNum = keys.target.tickNum + 1
    print("Movespeed: ".. target:GetBaseMoveSpeed() .. " AttackTime: " .. target:GetBaseAttackTime())
end

function SpearPoisonEnd(keys)
    local caster = keys.caster
    local target = keys.target

    print(target, target.startingMoveSpeed)

    target:SetBaseMoveSpeed(target.startingMoveSpeed)
    target:SetBaseAttackTime(target.startingAttackTime)

    keys.target.startingMoveSpeed = nil
    keys.target.startingAttackTime = nil

    print("Ending Movespeed: ".. target:GetBaseMoveSpeed() .. " AttackTime: " .. target:GetBaseAttackTime())
end

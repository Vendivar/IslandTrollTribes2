function StartDespawnTimer(keys)
    local babyAnimal = keys.caster
    local lifeTime = keys.Lifetime
    lifeTime = RandomFloat(lifeTime, lifeTime + 60.0)
--    print("Life time of the spawned baby animal is set to "..lifeTime.." seconds")
    Timers:CreateTimer(DoUniqueString("baby_animal"), {callback=Despawn, endTime = lifeTime}, babyAnimal)
end

function Despawn(unit)
    if not unit:IsNull() and unit:IsAlive() and unit:HasModifier("modifier_baby_animal") then
        unit:ForceKill(false)
    end
end

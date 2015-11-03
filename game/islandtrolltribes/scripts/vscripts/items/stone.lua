function Hide( event )
    local caster = event.caster
    local origin = caster:GetAbsOrigin()
    origin.z = -128
    local item = event.ability

    caster:DropItemAtPositionImmediate(item, origin)
    item:GetContainer():SetAbsOrigin(Vector(-8000,-8000,0))
end

function Remove( event )
    local item = event.ability
    item:GetContainer():RemoveSelf()
end
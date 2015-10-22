-- This checks both health and mana to kill the hero if it ever hits < 1 health or mana
function HungerCheck( event )
    local hero = event.target
    local health = hero:GetHealth()
    local mana = hero:GetMana()

    if health <= 1 then
        hero:ForceKill(true)
    elseif mana < 1 then
        hero:ForceKill(true)
    end 

end
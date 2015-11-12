-- This checks both health and mana to kill the hero if it ever hits < 1 health or mana
function HungerCheck( event )
    local hero = event.target
    local health = hero:GetHealth()
    local mana = hero:GetMana()
    local ability = "sleep_outside"
    if health <= 1 then
        hero:ForceKill(true)
  --pleasefix elseif mana < 10 then 
       --pleasefix      hero:CastAbilityNoTarget("sleep_outside", -1)
    elseif mana < 1 then
        hero:ForceKill(true)
    end 

end
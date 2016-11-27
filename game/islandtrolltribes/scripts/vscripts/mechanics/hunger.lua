-- This checks both health and mana to kill the hero if it ever hits < 1 health or mana
function HungerCheck( event )
    local hero = event.target
    local health = hero:GetHealth()
    local mana = hero:GetMana()
    local ability = "sleep_outside"
    if health <= 1 then
        hero:ForceKill(true)
        
   elseif mana < 10 then 
       if hero then
        local abilityName = "sleep_outside"
        local ability = hero:FindAbilityByName(abilityName)
        if not ability then
            ability = TeachAbility(hero, abilityName, 1)
        end
        if ability:IsFullyCastable() then
            hero:CastAbilityNoTarget(ability, -1)
            local playerID = hero:GetPlayerID()
            SendErrorMessage(playerID, "#error_mana_low")
        end
    end
  end
  ---  elseif mana < 1 then
  ---      hero:ForceKill(true)
  ---  end 

end
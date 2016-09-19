function EnchantStart( event )
    local ability = event.ability
    local target = event.target
    ability.target_of_ability = target
end

function Enchant( event )
    local ability = event.ability
    local target_of_ability = ability.target_of_ability
    local target = event.target

    target:SetForceAttackTarget(nil)
    target_of_ability:SetForceAttackTarget(nil)

    if target_of_ability:IsAlive() and target_of_ability ~= target then
        local order = 
        {
            UnitIndex = target:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = target_of_ability:entindex()
        }

        ExecuteOrderFromTable(order)
    else
        target:RemoveModifierByName(event.modifier)
    end

    target:SetForceAttackTarget(target_of_ability)
	--HELP: should be instead a random teammate and have that on a .5 thinker.
end

function EnchantEnd( event )
    local target = event.target
    local ability = event.ability
    local target_of_ability = ability.target_of_ability
    target:SetForceAttackTarget(nil)
    target_of_ability:SetForceAttackTarget(nil)
end



function SpeechEnchant( event )
	local caster = event.caster

  local dieRoll = RandomInt(0, 2)

    print("Test your luck! " .. dieRoll)
    if dieRoll == 0 then 
        caster:AddSpeechBubble(1,"#en_enchant1",2.0,0,0)
		 caster:EmitSound("en.enchant3")
		 print("1")
    elseif dieRoll == 1 then
        caster:AddSpeechBubble(1,"#en_enchant2",2.0,0,0)
		 caster:EmitSound("en.enchant3")
		print("2")
	elseif dieRoll == 2 then
           caster:AddSpeechBubble(1,"#en_enchant3",2.0,0,0)
			caster:EmitSound("en.enchant3")
		   print("3")
        end
    end
	
	
function SpeechTaunt( event )
	local caster = event.caster

  local dieRoll = RandomInt(0, 1)

    print("Test your luck! " .. dieRoll)
    if dieRoll == 0 then 
        caster:AddSpeechBubble(1,"#en_taunt1",2.0,0,0)
		 caster:EmitSound("en.taunt1")
		 print("1")
    elseif dieRoll == 1 then
        caster:AddSpeechBubble(1,"#en_taunt2",2.0,0,0)
		 caster:EmitSound("en.taunt2")
		print("2")
        end
    end
	
	
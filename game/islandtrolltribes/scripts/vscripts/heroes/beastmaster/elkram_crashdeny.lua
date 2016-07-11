function CrashDeny(event)
  local player = event.caster
  local name = PlayerResource:GetPlayerName(player:GetPlayerID())

  print("Denying crash for "..name)
  Timers:CreateTimer("crashdeny_for_"..name, {
    callback = function()
      --print("I'm executed whenever elk form is on!")

      if not player:FindModifierByName("modifier_silence") and
         player:FindModifierByName("modifier_elkform") and
         player:FindModifierByName("modifier_spirit_breaker_charge_of_darkness") then
          player:AddNewModifier(nil,nil,"modifier_silence",nil)
      end

      if player:FindModifierByName("modifier_silence") and
         not player:FindModifierByName("modifier_spirit_breaker_charge_of_darkness") then
          player:RemoveModifierByName("modifier_silence")
      end

      return 0.1
    end
  })
end

function CrashDenyRemove(event)
  local player = event.caster
  local name = PlayerResource:GetPlayerName(player:GetPlayerID())

  print("Removing crash deny from "..name)
  Timers:RemoveTimer("crashdeny_for_"..name)
end

--filename: modifier_ability_revive.lua
modifier_ability_revive = class({})

function modifier_ability_revive:OnCreated()
   self:GetAbility().modifier = self
end

function modifier_ability_revive:IsHidden()
  return true
end
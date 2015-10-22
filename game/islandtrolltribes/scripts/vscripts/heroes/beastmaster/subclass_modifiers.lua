modifier_chicken_form = class({})
function modifier_chicken_form:DeclareFunctions()
    return {MODIFIER_PROPERTY_MODEL_CHANGE}
end

function modifier_chicken_form:GetModifierModelChange()
    return "models/items/courier/mighty_chicken/mighty_chicken.vmdl"
end

function modifier_chicken_form:IsHidden() 
  return true
end

modifier_pack_leader  = class({})
function modifier_pack_leader:DeclareFunctions()
    return {MODIFIER_PROPERTY_MODEL_CHANGE}
end

function modifier_pack_leader:GetModifierModelChange()
    return "models/items/lycan/ultimate/alpha_trueform9/alpha_trueform9.vmdl"
end

function modifier_pack_leader:IsHidden() 
  return true
end

modifier_shapeshifter = class({})
function modifier_shapeshifter:DeclareFunctions()
    return {MODIFIER_PROPERTY_MODEL_CHANGE}
end

function modifier_shapeshifter:GetModifierModelChange()
    return "models/items/lone_druid/true_form/rabid_black_bear/rabid_black_bear.vmdl"
end

function modifier_shapeshifter:IsHidden() 
  return true
end
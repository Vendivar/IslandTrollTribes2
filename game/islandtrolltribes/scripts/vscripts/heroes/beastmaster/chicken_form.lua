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

function modifier_chicken_form:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

LinkLuaModifier("modifier_chicken_form", "heroes/beastmaster/chicken_form.lua", LUA_MODIFIER_MOTION_NONE)

function SetModel(keys)
    local target = keys.target
    local duration = keys.Duration
local item = CreateItem("item_apply_modifiers", target, target)
item:ApplyDataDrivenModifier(target, target, "modifier_chicken_form", {})
end
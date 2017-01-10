modifier_pack_leader = class({})
function modifier_pack_leader:DeclareFunctions()
    return {MODIFIER_PROPERTY_MODEL_CHANGE}
end

function modifier_pack_leader:GetModifierModelChange()
    return "models/items/lycan/ultimate/alpha_trueform9/alpha_trueform9.vmdl"
end

function modifier_pack_leader:IsHidden()
    return true
end

function modifier_pack_leader:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

LinkLuaModifier("modifier_pack_leader", "heroes/beastmaster/pack_leader.lua", LUA_MODIFIER_MOTION_NONE)

function SetModel(keys)
    local target = keys.target
    local duration = keys.Duration
	local item = CreateItem("item_apply_modifiers", target, target)
	item:ApplyDataDrivenModifier(target, target, "modifier_pack_leader", {})
	item:ApplyDataDrivenModifier(target, target, "modifier_packleader", {})
end
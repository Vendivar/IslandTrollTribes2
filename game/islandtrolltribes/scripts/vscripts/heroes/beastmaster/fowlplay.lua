modifier_fowlplay_chicken = class({})
function modifier_fowlplay_chicken:DeclareFunctions()
    return {MODIFIER_PROPERTY_MODEL_CHANGE}
end

function modifier_fowlplay_chicken:GetModifierModelChange()
    return "models/props_gameplay/chicken.vmdl"
end

function modifier_fowlplay_chicken:IsHidden()
    return true
end

function modifier_fowlplay_chicken:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

LinkLuaModifier("modifier_fowlplay_chicken", "heroes/beastmaster/fowlplay.lua", LUA_MODIFIER_MOTION_NONE)

function SetModel(keys)
    local target = keys.target
    local duration = keys.Duration	
	local item = CreateItem("item_apply_modifiers", target, target)
	item:ApplyDataDrivenModifier(target, target, "modifier_fowlplay_chicken", {})
    Timers:CreateTimer(DoUniqueString("fowlplay"),{callback=ResetModel, endTime = duration}, target)
end

function ResetModel(target)
    target:RemoveModifierByName("modifier_fowlplay_chicken")
end
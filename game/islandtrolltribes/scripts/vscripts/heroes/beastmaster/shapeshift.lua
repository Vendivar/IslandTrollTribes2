function Shapeshift(keys)
    local caster = keys.caster
    local form = keys.Form

    local formSkills = {
        {"Normal",nil,{}},
        {"Bear","modifier_bearform",{"ability_beastmaster_bash","ability_beastmaster_slam"}},
        {"Wolf","modifier_wolfform",{"ability_beastmaster_howl","ability_beastmaster_criticalstrike"}},
        {"Elk","modifier_elkform",{"ability_beastmaster_magicimmunity","ability_beastmaster_ram"}}
    }

    -- modify skill visibilities, remove modifiers from other forms
    for _,skillList in pairs(formSkills) do
        local isVisible = (form == skillList[1])
        local modifier = skillList[2]
        if form ~= skillList[1] and modifier ~= nil then
            caster:RemoveModifierByName(modifier)
        end
        for _,skill in pairs(skillList[3]) do
            SetAbilityVisibility(caster, skill, isVisible)
        end
    end
end
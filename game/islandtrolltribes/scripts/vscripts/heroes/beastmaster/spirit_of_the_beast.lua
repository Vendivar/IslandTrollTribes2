function SetSpawnChance(keys)
    local caster = keys.caster
    local target = keys.target
    local level = caster:GetLevel()
    local bonus = 0
    local maxLevel = 4

    -- shitty way of determining whether the BM is pack leader form
    -- easier than copy pasting the massive spirit of the beast ability and only changing one function argument
    local heroIsSub = caster:HasAbility("ability_beastmaster_tamepet2")

    if heroIsSub then
        bonus = 5
        maxLevel = 9
    end

    if keys.Remove == "1" then
        level = 0
    end

    level = level + bonus
    if level > maxLevel then
        level = maxLevel
    end

    target:SetModifierStackCount("modifier_spawn_chance",nil,level)
end

function AttractAnimal(keys)
    local caster = keys.caster
    local target = keys.target
    if target.state == "flee" then
        return
    end
    local position = caster:GetAbsOrigin() + RandomVector(RandomInt(0,100))
    if not string.find(target:GetUnitName(), "npc_creep_fish") and not string.find(target:GetUnitName(), "npc_creep_hawk") then
        target:MoveToPositionAggressive(position)
	end
end



function SpiritAttacked(keys)
    local caster = keys.caster
    local target = keys.target
    local attacker = keys.attacker
    local ability = keys.ability
	
		if not attacker:IsHero() then	
		ApplyDamage({victim = attacker, attacker = caster, damage = 2, damage_type = DAMAGE_TYPE_MAGICAL, })		
		attacker:AddNewModifier(caster, ability, "modifier_spiritofthebeastslow", {duration = 3, hidden = false})
		end
end


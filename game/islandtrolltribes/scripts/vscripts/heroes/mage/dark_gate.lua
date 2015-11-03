function DarkGatePhaseStart( event )
	caster = event.caster
	modifier = event.modifier

	if caster:HasModifier(modifier) then
		caster:RemoveModifierByName(modifier)
		caster:Stop()
	end
end

function DarkGateStart( event )
	ability = event.ability
	ability.start_time = GameRules:GetGameTime()
	ability.logs = {}
	ability.spell_names = {"ability_mage_giganegativeblast",
						"ability_mage_quantum_nulldamage",
						"ability_mage_reducefood",
						"ability_mage_maddeningdischarge"}
end

function DarkGateThink( event )
	local ability = event.ability
	local caster = event.caster
	local target = event.target

    local spellNames = ability.spell_names

    local random = RandomInt(1, 4)

    local dummy = CreateUnitByName("dummy_caster",
	                                target:GetAbsOrigin(),
	                                false,
	                                caster,
	                                caster,
	                                caster:GetTeam())

    for key, value in pairs(spellNames) do
    	dummy:AddAbility(value)
    end

    local spells = {dummy:FindAbilityByName(spellNames[1]),
				    dummy:FindAbilityByName(spellNames[2]),
				    dummy:FindAbilityByName(spellNames[3]),
				    dummy:FindAbilityByName(spellNames[4])}

    Timers:CreateTimer(0.1, function()
    		dummy:CastAbilityOnTarget(target, spells[random], 0)
    		return
    	end)
end

function DarkGateDamaged( event )
	local ability = event.ability
	local caster = event.caster

	local damage = event.attack_damage
	local threshold = event.damage_threshold
	local modifier = event.modifier

	local logs = ability.logs
	local startTime = ability.start_time

	local elapsed = GameRules:GetGameTime() - startTime

	for key, value in pairs(logs) do
		if (elapsed - value[1] > 3) then
			table.remove(logs, key)
		end
	end

	table.insert(logs, {elapsed, damage})

	local sum = 0
	for  key, value in pairs(logs) do
		sum = sum + value[2]
	end

	if sum > threshold then
		caster:RemoveModifierByName(modifier)
	end
end

function DarkGateStop ( event )
	local ability = event.ability
	local startTime = ability.start_time

	local elapsed = GameRules:GetGameTime() - startTime
	local cooldown = event.cooldown

	if elapsed < cooldown then
		ability:StartCooldown(cooldown - elapsed)
	end
end
function Ensnare( event )
	local ability = event.ability
	local caster = event.caster
	local target = event.target
	local modifier = event.modifier
	local durationHero = event.duration_hero
	local durationAnimal = event.duration_animal

	local dur = durationAnimal
	if string.find(target:GetName(), "hero") then
		dur = durationHero
	end
	ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = dur})
end
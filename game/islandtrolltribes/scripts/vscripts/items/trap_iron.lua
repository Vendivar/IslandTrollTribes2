function MakeTrap( keys )
    local caster = keys.caster
	local target_point = keys.target_points[1]

   --  local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_furion/furion_sprout.vpcf", PATTACH_CUSTOMORIGIN, nil )
   -- ParticleManager:SetParticleControl( particle, 0, target_point )
   -- ParticleManager:SetParticleControl( particle, 1, Vector( 0.0, -30, 0.0 ) )

	CreateUnitByName("npc_building_trap_iron", target_point, true, caster, caster, caster:GetTeam())

end



function KillTrap ( keys )
    local caster = keys.caster
	caster:EmitSound("trap.iron")
    caster:ForceKill(true)
	caster:AddEffects(EF_NODRAW) --Hide it, so that it's still accessible after this script
end


function TrapCheck ( keys )
    local target = keys.target
    local caster = keys.caster
	local ability = keys.ability

    if not (string.find(target:GetUnitName(), "elk") or string.find(target:GetUnitName(), "fish") or string.find(target:GetUnitName(), "hawk")) then
	ability:ApplyDataDrivenModifier(caster, target, 'modifier_irontrap_ensnare', {})
	print("found target for trap")
	end
end
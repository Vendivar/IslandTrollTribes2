function Teleport (event)
	--PrintTable(event.target)

	print('keke')

	local hTarget = event.target;
	local hCaster = event.caster;

	local vPosTarget = hTarget:GetOrigin()
	local vPosCaster = hCaster:GetOrigin()

	local v = vPosCaster - vPosTarget

	local v2 = v * 2

	local v3 = vPosTarget + v2

	hTarget:SetOrigin(v3)
	FindClearSpaceForUnit(hTarget, v3, true )

	local nCasterFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster )
	ParticleManager:SetParticleControlEnt( nCasterFX, 1, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), false )
	ParticleManager:ReleaseParticleIndex( nCasterFX )
 
	local nTargetFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControlEnt( nTargetFX, 1, hCaster, PATTACH_ABSORIGIN_FOLLOW, nil, hCaster:GetOrigin(), false )
	ParticleManager:ReleaseParticleIndex( nTargetFX )
 
	EmitSoundOn( "Hero_VengefulSpirit.NetherSwap", hCaster )
	EmitSoundOn( "Hero_VengefulSpirit.NetherSwap", hTarget )

	hTarget:Interrupt()
	--local vFromTargetToTower = Vector(hCaster.x - hTarget.x, hCaster.y - hTarget.y, hCaster.z - hTarget.z)

	-- local vDestination = vPosTarget + (2 * vFromTargetToTower)

end
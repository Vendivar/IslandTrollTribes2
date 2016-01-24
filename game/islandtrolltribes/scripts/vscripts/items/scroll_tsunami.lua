function TsunamiProjectiles(keys)
	local caster = keys.caster
	--A Liner Projectile must have a table with projectile info
	local info = 
	{
		--Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_morphling/morphling_waveform.vpcf",
        iMoveSpeed = 1215,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 615,
        fStartRadius = 0,
        fEndRadius = 0,
        Source = keys.caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
	}
	--Creates the 7 projectiles in the 57.5 degree cone
	for i=-15,15,(15) do
		info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * info.iMoveSpeed
		fDistance = 615/math.cos(math.rad(i))
		print(i, math.sin(math.rad(i)), math.rad(i), fDistance)
		projectile = ProjectileManager:CreateLinearProjectile(info)
	end
end

function TsunamiDestroyFire(keys)
	local target = keys.target
	local targetName = target:GetUnitName()
	if (string.find(targetName,"fire") ~= nil) then
		target:ForceKill(true)
		print(targetName)
		--Should spawn a firekit at that position
	end
end
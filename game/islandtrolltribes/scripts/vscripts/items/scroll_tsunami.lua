function TsunamiProjectiles(keys)
	local caster = keys.caster
    local item = keys.ability

	--A Liner Projectile must have a table with projectile info
	local info = 
	{
		Ability = item,
        EffectName = "particles/units/heroes/hero_morphling/morphling_waveform.vpcf",
        iMoveSpeed = 1215,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 615,
        fStartRadius = 100,
        fEndRadius = 100,
        Source = keys.caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
	}

	--Creates the 7 projectiles in the 57.5 degree cone
	for i=-15,15,(15) do
		info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * info.iMoveSpeed
		fDistance = 615/math.cos(math.rad(i))
		projectile = ProjectileManager:CreateLinearProjectile(info)
	end


end

function TsunamiDestroyFire(keys)
	local target = keys.target
	local targetName = target:GetUnitName()
	local caster = keys.caster
	
    if string.find(target:GetUnitName(), "npc_building_") then
        DamageBuilding(target, 25, nil, caster)
    end
	
	if (string.match(targetName,"_fire")) then
		target:ForceKill(true)
	end
    
	if (string.match(targetName,"_trap")) then
		target:ForceKill(true)
	end
    if (string.match(targetName,"ensnare")) then
		target:ForceKill(true)
	end
    if target:HasModifier("modifier_molotov_burn_building") then
    target:RemoveModifierByName("modifier_molotov_burn_building")
    target:StopSound("molotov.burn")
    end
end
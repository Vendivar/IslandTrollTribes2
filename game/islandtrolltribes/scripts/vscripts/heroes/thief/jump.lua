
function Jump( keys )
	local caster = keys.caster
	local ability = keys.ability
	local leap_distance = ability:GetLevelSpecialValueFor("leap_distance", (ability:GetLevel() - 1))
	local leap_duration = ability:GetLevelSpecialValueFor("leap_duration", (ability:GetLevel() - 1))
	local leap_vertical_speed = ability:GetLevelSpecialValueFor("leap_vertical_speed", (ability:GetLevel() - 1))
	local modifier_leap_immunity = keys.modifier_leap_immunity

	-- Clears any current command
	caster:Stop()

	-- Physics
	local casterPosition = caster:GetAbsOrigin()
	local finalPosition = CalculateFinalPosition(caster, leap_distance)
	local leapHorizontalSpeed = leap_distance / leap_duration
	local gravity = CalculateVerticalAcceleration(casterPosition.z, finalPosition.z, leap_vertical_speed, leap_duration)
	local velocityVector = (caster:GetForwardVector() * leapHorizontalSpeed) + Vector(0, 0, leap_vertical_speed)

	Physics:Unit(caster)

	caster:PreventDI(true)
	caster:SetAutoUnstuck(false)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)	
	caster:SetPhysicsVelocity(velocityVector)
	caster:SetPhysicsAcceleration(Vector(0, 0, gravity))
	caster:SetPhysicsFriction(0.0)

	-- HVH: plays flight animation, disjoints projectiles, and applies immunity
	StartAnimation(caster, {duration=leap_duration, activity=ACT_DOTA_RUN, rate=1.0, translate="haste"})
	ProjectileManager:ProjectileDodge(caster)
	ability:ApplyDataDrivenModifier(caster, caster, modifier_leap_immunity, {duration=leap_duration})

	-- Do the landing
	-- Adding a single frame to this because we want to disable the physics
	-- right after he's touched the ground which is 1 frame after the leap duration.
	Timers:CreateTimer(leap_duration + .03, function()
		caster:SetPhysicsAcceleration(Vector(0,0,0))
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:OnPhysicsFrame(nil)
		caster:PreventDI(false)
		caster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
		caster:SetAutoUnstuck(true)
		caster:FollowNavMesh(true)
		caster:SetPhysicsFriction(.05)
		
		-- HVH prevents getting stuck, removes immunity
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)

		return nil	
	end)
end

function CalculateVerticalAcceleration(initialHeight, finalHeight, initialVerticalSpeed, endTime)
	local finalVerticalSpeed = ((2 * (finalHeight - initialHeight)) - (initialVerticalSpeed * endTime)) / endTime
	local verticalAcceleration = (finalVerticalSpeed - initialVerticalSpeed) / endTime
	return verticalAcceleration
end

function CalculateFinalPosition(caster, leapDistance)
	local casterPosition = caster:GetAbsOrigin()
	local forward = caster:GetForwardVector()
	local theta = math.atan2(forward.y, forward.x)
	local xOffset = leapDistance * math.cos(theta)
	local yOffset = leapDistance * math.sin(theta)
	local finalPosition = GetGroundPosition(Vector(casterPosition.x + xOffset, casterPosition.y + yOffset, casterPosition.z), caster)
	--DebugDrawLine(casterPosition, finalPosition, 255, 0, 0, true, 3)
	return finalPosition
end
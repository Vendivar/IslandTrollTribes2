-- Modifier living clay caster starts
modifier_living_clay_caster = class({})
-- Modifier living clay caster ends

LinkLuaModifier("modifier_living_clay_caster", "items/living_clay.lua", LUA_MODIFIER_MOTION_NONE)


function LivingClayCheckStacks(keys)
    local caster = keys.caster
    local ability = keys.ability
    local curstacks = target:GetModifierStackCount("modifier_living_claycount", caster)
	print(target,caster,curstacks)
	
    if curstacks >= 10 then
        SendErrorMessage(caster:GetPlayerOwnerID(),"#error_toomanyclay")
        caster:Interrupt()
        ability:StartCooldown(1.0)
    else
    print("else")
    end
end

function PlaceClay( keys )
    local caster = keys.caster
	local target_point = keys.target_points[1]

   --  local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_furion/furion_sprout.vpcf", PATTACH_CUSTOMORIGIN, nil )
   -- ParticleManager:SetParticleControl( particle, 0, target_point )
   -- ParticleManager:SetParticleControl( particle, 1, Vector( 0.0, -30, 0.0 ) )

	local livingclay = CreateUnitByName("npc_clay_living", target_point, false, caster, caster, caster:GetTeam())
	livingclay:AddNewModifier(caster, nil, "modifier_invisible",{duration = -1, hidden = true})

end


function LivingClayActivate(keys)
    local caster = keys.caster
    local target = keys.target

	if target:IsHero() and target:HasModifier("modifier_living_clay") then
	print("Gotcha")
	end
	
end


function MakeClayExplosion(keys)
    local caster = keys.caster
    local origin =  keys.target_points[1]
    local dieRoll = RandomInt(0, 3)
    for i=1,dieRoll do
        local pos_launch = origin + RandomVector(RandomInt(1,200))
        local item = CreateItem("item_clay_living", nil, nil)
        local drop = CreateItemOnPositionSync( origin, item )
        item:LaunchLoot(false, 200, 0.75, pos_launch)
    end
		print("Die roll for clay explosion: "..dieRoll)
end




function KillTrap ( keys )
    local caster = keys.caster
	caster:EmitSound("item.livingclayburst")
    caster:ForceKill(true)
	caster:AddEffects(EF_NODRAW) --Hide it, so that it's still accessible after this script
end


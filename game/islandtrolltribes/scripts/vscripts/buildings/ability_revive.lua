ability_revive = class({})

function ability_revive:OnSpellStart()
    local ability = self
    local caster = ability:GetCaster()
    local target = ability:GetCursorTarget()
    self.reviving = target.hero --Hero reference stored on the grave
    local revivingTime = target.hero:GetLevel() * self:GetSpecialValueFor("revive_duration") / 1.5
    self.revivingTime = revivingTime
    self:StartCooldown(revivingTime)
    CustomNetTables:SetTableValue("ability_revive", tostring(caster:GetEntityIndex()), { revivingTime = revivingTime })
end

function ability_revive:GetChannelTime()
    local reviveTime = CustomNetTables:GetTableValue("ability_revive",tostring(self:GetCaster():GetEntityIndex())).revivingTime
    if IsServer() then
        reviveTime = self.revivingTime
		local channelParticle = ParticleManager:CreateParticle("particles/custom/spirit_ward_rez_green.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)	
		ParticleManager:SetParticleControl(channelParticle, 0, self:GetAbsOrigin())
		ParticleManager:SetParticleControl(channelParticle, 1, Vector(reviveTime,0,0))
		EmitSoundOn( "spiritward.revive.channel", self )
		
		  Timers:CreateTimer(reviveTime, function()
	
     ParticleManager:DestroyParticle(channelParticle,false)
    end
  )
        return reviveTime
    end
    return reviveTime
end

function ability_revive:OnChannelFinish( bInterrupted )
    if IsServer() then
        local caster = self:GetCaster()
        local hero = self.reviving

        if not bInterrupted and not hero:IsAlive() then
            hero:SetRespawnPosition(caster:GetAbsOrigin())
            hero:RespawnUnit()
            if hero:GetSubClass() == "none" then
                ITT:SetDefaultCosmetics(hero)     --Reset default wearables and hides the wearables need to be hidden
            else
                ITT:SetDefaultWearables(hero)     --Reset default wearables and doesn't hide wearables
                ITT:SetSubclassCosmetics(hero)
            end
            FindClearSpaceForUnit(hero, caster:GetAbsOrigin(), true)
			
			 local id = hero:GetPlayerID()
			CustomGameEventManager:Send_ServerToTeam(hero:GetTeam(), "team_member_up", {hero = PlayerResource:GetSelectedHeroName(id),player = id})
		
        end
    end
end

--------------------------------------------------------------------------------
 
function ability_revive:CastFilterResultTarget( target )
    local ability = self
    local caster = ability:GetCaster()

    local casterTeam = caster:GetTeamNumber()
    local targetTeam = target:GetTeamNumber()
    local allied = casterTeam == targetTeam

    -- Check allied gravestone
    if not allied or target:GetUnitName() ~= "gravestone" then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end
  
function ability_revive:GetCustomCastErrorTarget( target )
    local ability = self
    local caster = ability:GetCaster()

    local casterTeam = caster:GetTeamNumber()
    local targetTeam = target:GetTeamNumber()
    local allied = casterTeam == targetTeam

    -- Check allied gravestone
    if not allied or target:GetUnitName() ~= "gravestone" then
        return "#error_must_target_allied_gravestone"
    end
 
    return ""
end
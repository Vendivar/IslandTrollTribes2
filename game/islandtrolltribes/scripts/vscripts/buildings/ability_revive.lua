ability_revive = class({})

function ability_revive:OnSpellStart()
    local ability = self
    local caster = ability:GetCaster()
    local target = ability:GetCursorTarget()
    ability:StartCooldown(target:GetLevel()*4)

    self.reviving = target.hero --Hero reference stored on the grave
end

function ability_revive:OnChannelFinish( bInterrupted )
    if IsServer() then
        local caster = self:GetCaster()
        local hero = self.reviving

        if not bInterrupted and not hero:IsAlive() then
            hero:SetRespawnPosition(caster:GetAbsOrigin())
            hero:RespawnUnit()
            FindClearSpaceForUnit(hero, caster:GetAbsOrigin(), true)
            --caster:EmitSound("Hero_SkeletonKing.Reincarnation") --Gotta precache, not sure how to, in KV or here?
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
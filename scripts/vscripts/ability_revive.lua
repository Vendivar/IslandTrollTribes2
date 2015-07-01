ability_revive = class({})
nPlayerID = 0
reviveTime = 0
LinkLuaModifier("modifier_ability_revive",LUA_MODIFIER_MOTION_NONE)

function ability_revive:OnSpellStart()
print("OnSpellStart")
  local caster = self:GetCaster()
  for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
    local player = PlayerResource:GetPlayer(nPlayerID)
    if PlayerResource:IsValidPlayer(nPlayerID) then
      if PlayerResource:GetTeam(nPlayerID) == caster:GetTeamNumber() then
        if PlayerResource:HasSelectedHero( nPlayerID ) then
          local hero = player:GetAssignedHero()
          if hero ~= nil then
            if not hero:IsAlive() then
              reviveTime = hero:GetLevel() * 4
              print("a hero is dead")
            end
          else
            print(nPlayerID.." is alive")
            return
          end
        else
          print(nPlayerID.." hero is nil")
          return
        end
      else
        return
      end
    else
      return
    end  
  end
end

function ability_revive:OnChannelFinish( bInterrupted )
  print("OnChannelFinish")
  local caster = self:GetCaster()
  local player = PlayerResource:GetPlayer(nPlayerID)
  local hero = player:GetAssignedHero()
  print("revive time: "..reviveTime)
  print("revive player!")
  hero:SetRespawnPosition(caster:GetAbsOrigin())
  if not hero:IsAlive() then
    hero:RespawnUnit()
    FindClearSpaceForUnit(hero, caster:GetAbsOrigin(), true)
    --caster:EmitSound("Hero_SkeletonKing.Reincarnation") --Gotta precache, not sure how to, in KV or here?
  end
end

function ability_revive:GetChannelTime()
  print("GetChannelTime")
  if IsServer() then
    self.modifier:SetStackCount(reviveTime)
    return reviveTime
  else
    return self.modifier:GetStackCount()
  end
end

function ability_revive:GetIntrinsicModifierName()
  return "modifier_ability_revive"
end
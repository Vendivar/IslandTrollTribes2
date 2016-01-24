--Not finished, need to find and ping spirit wards and bosses
function PotionTwinUse(keys)
  local caster = keys.caster
  local range = keys.Range
  local casterPosition = caster:GetAbsOrigin()
  local teamnumber = caster:GetTeamNumber()

  local units = FindUnitsInRadius(teamnumber,
    casterPosition,
    nil,
    range,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false)
    
  local redVal = 0
  local greenVal = 0
  local blueVal = 0

  for _, unit in pairs(units) do
    if unit:IsHero() then
      redVal = 255
    end

    local thisParticle = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, caster:GetOwner())
    ParticleManager:SetParticleControl(thisParticle, 0, unit:GetAbsOrigin())
    ParticleManager:SetParticleControl(thisParticle, 1, Vector(redVal, greenVal, blueVal))
    PingMap(caster:GetPlayerID(),unit:GetAbsOrigin(),redVal,greenVal,blueVal)
    ParticleManager:ReleaseParticleIndex(thisParticle)
    unit:EmitSound("General.Ping")   --may be deafening
  end
  
  --So for the spirit ward, I was thinking of changing building itself to be a tower, and then use isTower(), but I had some errors and never got around to it
    
--  local spiritWards = FindUnitsInRadius(teamnumber,
--    casterPosition,
--    nil,
--    range,
--    DOTA_UNIT_TARGET_TEAM_ENEMY,
--    DOTA_UNIT_TARGET_ALL,
--    DOTA_UNIT_TARGET_FLAG_NONE,
--    FIND_ANY_ORDER,
--    false)
--  
--  for _, spiritWard in pairs(spiritWards) do
--    if spiritWard:isTower() then
--      blueVal = 255
--    
--      local thisParticle = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, caster:GetOwner())
--      ParticleManager:SetParticleControl(thisParticle, 0, spiritWard:GetAbsOrigin())
--      ParticleManager:SetParticleControl(thisParticle, 1, Vector(redVal, greenVal, blueVal))
--      PingMap(caster:GetPlayerID(),spiritWard:GetAbsOrigin(),redVal,greenVal,blueVal)
--      ParticleManager:ReleaseParticleIndex(thisParticle)
--      spiritWard:EmitSound("General.Ping")   --may be deafening
--    end
--  end
end
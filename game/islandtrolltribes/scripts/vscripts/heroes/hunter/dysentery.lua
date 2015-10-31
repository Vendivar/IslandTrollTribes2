-- Creates a trail particle with trailFadeTime duration, only visible to the caster's team
function DysenteryTrackThink(event)
    local caster = event.caster
    local target = event.target
    local fadeTime = event.Fade
    local particleName = "particles/econ/courier/courier_trail_fungal/courier_trail_fungal_f.vpcf"

    local particle = ParticleManager:CreateParticleForTeam(particleName, PATTACH_CUSTOMORIGIN, caster, caster:GetTeamNumber())
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 15, Vector(139,69,19))

    Timers:CreateTimer(fadeTime, function() ParticleManager:DestroyParticle(particle, false) end)
end
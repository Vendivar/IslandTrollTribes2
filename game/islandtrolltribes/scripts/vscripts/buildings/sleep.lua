function ability_sleep:CastFilterResultTarget( target )
    local ability = self
    local caster = ability:GetCaster()

    local casterTeam = caster:GetTeamNumber()
    local targetTeam = target:GetTeamNumber()
    local allied = casterTeam == targetTeam

    if not ability_beastmaster_tamepet:IsValidPetName( target ) or allied then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end
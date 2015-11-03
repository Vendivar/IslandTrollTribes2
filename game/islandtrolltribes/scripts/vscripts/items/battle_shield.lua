function CheckSpellBlock( event )
    local caster = event.caster
    local ability = event.ability
    local target = event.target
    local event_ability = event.event_ability
    local spellblock_cd = ability:GetSpecialValueFor("spellblock_cd")
    local abilityBehavior = event_ability:GetBehavior()
    local abilityName = event_ability:GetAbilityName()

    if bit.band( abilityBehavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET ) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET and target then
        caster:RemoveModifierByName("modifier_shield_battle_spell_block")
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_spell_immunity_block", {duration=2})
        ParticleManager:CreateParticle("particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN, target)
        ability.next_block = GameRules:GetGameTime() + spellblock_cd
    end
end

function SpellBlockThink( event )
    local ability = event.ability
    local caster = event.caster

    if not caster:HasModifier("modifier_shield_battle_spell_block") then
        if ability.next_block and ability.next_block < GameRules:GetGameTime() then
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_shield_battle_spell_block", {})
        end
    end
end
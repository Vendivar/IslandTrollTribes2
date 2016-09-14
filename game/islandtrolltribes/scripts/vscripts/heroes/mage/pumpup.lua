function Bloodlust(event)   
    local caster = event.caster
    local target = event.target
    local ability = event.ability

    local scaling_factor = 20
    local duration = ability:GetSpecialValueFor("duration")
    target:AddNewModifier(caster,ability,"modifier_model_scale",{duration=duration,scale=scaling_factor})
    ability:ApplyDataDrivenModifier(caster, target, 'modifier_pumpup', {})

    caster:EmitSound('Hero_OgreMagi.Bloodlust.Cast')
    target:EmitSound('Hero_OgreMagi.Bloodlust.Target')
end

function ToggleOnAutocast( event )
    event.ability:ToggleAutoCast()
end

-- Handles the autocast logic
function BloodlustAutocast_Attack( event )
    local caster = event.caster
    local attacker = event.attacker
    local ability = event.ability
    if not ability then return end

    -- Name of the modifier to avoid casting the spell on targets that were already buffed
    local modifier = "modifier_pumpup"

    -- Get if the ability is on autocast mode and cast the ability on the attacked target if it doesn't have the modifier
    if not attacker:IsMagicImmune() and ability:GetAutoCastState() and ability:IsFullyCastable() then
        if not attacker:HasModifier(modifier) then
            caster:CastAbilityOnTarget(attacker, ability, caster:GetPlayerOwnerID())
        end 
    end 
end

function BloodlustAutocast_Attacked( event )
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    if not ability then return end

    -- Name of the modifier to avoid casting the spell on targets that were already buffed
    local modifier = "modifier_pumpup"

    -- Get if the ability is on autocast mode and cast the ability on the attacked target if it doesn't have the modifier
    if not target:IsMagicImmune() and ability:GetAutoCastState() and ability:IsFullyCastable() then
        if not target:HasModifier(modifier) then
            caster:CastAbilityOnTarget(target, ability, caster:GetPlayerOwnerID())
        end 
    end 
end
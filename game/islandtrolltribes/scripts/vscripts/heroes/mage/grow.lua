function Grow(keys)
    local target = keys.target
    if target == nil then
    target = keys.caster
    end
    target:SetModelScale(keys.GrowAmmt)
end

function Shrink(keys)
    local target = keys.target
    if target == nil then
        target = keys.caster
    end
 --target:SetModelScale(target:GetModelScale() - keys.GrowAmmt)
    target:SetModelScale(1)
end

function Bloodlust(event)   
    local caster = event.caster
    local target = event.target
    local ability = event.ability

    if target.bloodlust_timer then
        Timers:RemoveTimer(target.bloodlust_timer)
    end

    local scaling_factor = ability:GetSpecialValueFor('scaling_factor')
    local model_scale = GetOriginalModelScale(target) or 1
    local final_model_scale = model_scale * (1+scaling_factor)
    local model_size_interval = scaling_factor/25
    local interval = 0.03
    target.bloodlust_timer = Timers:CreateTimer(interval, function() 
            local current_scale = target:GetModelScale()
            if current_scale <= final_model_scale then
                local modelScale = current_scale + model_size_interval
                target:SetModelScale( modelScale )
                return 0.03
            else
                return
            end
        end)

    ability:ApplyDataDrivenModifier(caster, target, 'modifier_bloodlust', nil) 

    caster:EmitSound('Hero_OgreMagi.Bloodlust.Cast')
    target:EmitSound('Hero_OgreMagi.Bloodlust.Target')
end

function BloodlustDelete(event) 
    local target = event.target
    local ability = event.ability
    if not ability then return end
    local scaling_factor = ability:GetSpecialValueFor('scaling_factor')
    local final_model_scale = GetOriginalModelScale(target) or 1
    local model_size_interval = scaling_factor/50
    
    if target.bloodlust_timer then
        Timers:RemoveTimer(target.bloodlust_timer)
    end
    local interval = 0.03
    target.bloodlust_timer = Timers:CreateTimer(interval, function() 
            local current_scale = target:GetModelScale()
            if current_scale >= final_model_scale then
                local modelScale = current_scale - model_size_interval
                target:SetModelScale( modelScale )
                return 0.03
            else
                return
            end
        end)

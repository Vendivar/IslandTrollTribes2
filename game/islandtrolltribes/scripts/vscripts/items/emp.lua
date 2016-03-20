
function EmpDetonate ( event )

    local caster = event.caster
    local item = event.ability
    local point = event.target_points[1]
    local disarm_duration = item:GetSpecialValueFor("disarm_duration")
    local radius = item:GetSpecialValueFor("disarm_radius")
    local particleName = "particles/econ/items/templar_assassin/templar_assassin_butterfly/templar_assassin_trap_explode_arcs_butterfly.vpcf"
	
	
	local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, 0, 0, false)
	for _,enemy in pairs(units) do
	 enemy:EmitSound("Hero_Invoker.EMP.Discharge")
        if IsCustomBuilding(unit) then
		item:ApplyDataDrivenModifier(caster, enemy, "ability_building_disable", {duration=duration_hero})
		end
	end
end


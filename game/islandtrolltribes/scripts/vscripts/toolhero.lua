moving = 
{
	x = 0,
	y = 0,
	z = 0
}

angles = false
dir = 1

MOVE_PER_TICK = 1

local pass = {}

function pass:ToolsThink(dt)
	for _,item in pairs(Entities:FindAllByClassname("dota_item_drop")) do
		local currentVec = item:GetOrigin()
		local newVec = Vector(currentVec.x + (moving.x * MOVE_PER_TICK * dir), 
			currentVec.y + (moving.y * MOVE_PER_TICK * dir), 
			currentVec.z + (moving.z * MOVE_PER_TICK * dir)
		)
		local currentAng = item:GetAngles()
		local newAng = Vector(currentAng.x + (moving.x * MOVE_PER_TICK * dir), 
			currentAng.y + (moving.y * MOVE_PER_TICK * dir), 
			currentAng.z + (moving.z * MOVE_PER_TICK * dir)
		)
		if angles then item:SetAngles(newAng.x, newAng.y, newAng.z) else item:SetOrigin(newVec) end
	end
	return 0.001
end

GameRules:GetGameModeEntity():SetThink("ToolsThink", pass, "ToolsThink", 0.001)


print("hi")

function rotate(keys)
	print("HEY")
	if moving[keys.Element] == 0 then moving[keys.Element] = 1 else moving[keys.Element] = 0 end
	print(moving[keys.Element])
end

function set_type(keys)
	angles = not angles
end

function reverse(keys)
	dir = -dir
end


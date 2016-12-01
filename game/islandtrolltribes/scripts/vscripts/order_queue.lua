if not OrderQueue then
	OrderQueue = class({})
end

function OrderQueue:Init()
    OrderQueue.queue = {}
end

function OrderQueue:Put(unit, order)
    print("Putting Order")
    local queue = OrderQueue.queue
    local unitIndex = unit:GetEntityIndex()
    local unitOrders = queue[unitIndex]
    -- TODO what if the item is already ordered to pick up?
    if unitOrders == nil then
    	unitOrders = {}
    	queue[unitIndex] = unitOrders
    end
	table.insert(unitOrders, order)
	DeepPrintTable(queue)
end

function OrderQueue:Clear(unit)
	-- TODO iterate and clear 
end

function OrderQueue:Next(unit)
	print("Next Order")
	local queue = OrderQueue.queue
	local unitOrders = queue[unit:GetEntityIndex()]
	if unitOrders == nil then
		return nil
	end

	local index,unitOrder = next(unitOrders)
	if index ~= nil then
        unitOrders[index] = nil
    end
    DeepPrintTable(queue)
	return unitOrder
end

if not OrderQueue.queue then OrderQueue:Init() end
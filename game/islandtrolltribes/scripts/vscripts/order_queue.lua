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
    --TODO what if the item is already ordered to pick up?
    if unitOrders == nil then
    	unitOrders = {}
    	queue[unitIndex] = unitOrders
    end
	table.insert(unitOrders, order)
	DeepPrintTable(queue)
end

if not OrderQueue.queue then OrderQueue:Init() end
local Orders = {}
local Constants = require("constants")
local Utils = require("utility/utils")

--[[
    global.orderSlots = {
        {
            index = 1 -- Int ID of the array in the entry
            state = [Orders.SlotStates]
            item = "" -- the item name this order wants or nil
            itemCountNeeded = 3 -- the number of this item type needed or nil
            itemCountDone = 1 -- the number of this item type supplied or nil
            startTime = GAMETICK -- when the order was first decrypted or nil
            nextDeadlineTime = GAMETICK -- when the order's bonus rate next changes or nil
        }
    }

]]
Orders.SlotStates = {waitingCapacityTech = "waitingCapacityTech", waitingDrydock = "waitingDrydock", waitingOrderDecryption = "waitingOrderDecryption", waitingItem = "waitingItem", waitingCustomerDepart = "waitingCustomerDepart"}
Orders.TimeBonus = {}
Orders.TimeBonus[(60 * 60 * 30)] = {bonusModifier = 1.1, guiColor = {r = 0, g = 1, b = 0, a = 1}}
Orders.TimeBonus[(60 * 60 * 60 * 2)] = {bonusModifier = 1, guiColor = {r = 255, g = 252, b = 0, a = 1}}
Orders.TimeBonus[(60 * 60 * 60 * 4)] = {bonusModifier = 0.9, guiColor = {r = 255, g = 211, b = 0, a = 1}}
Orders.TimeBonus[(60 * 60 * 60 * 5)] = {bonusModifier = 0.8, guiColor = {r = 1, g = 0, b = 0, a = 1}}
Orders.TimeBonus[(60 * 60 * 60 * 6)] = {bonusModifier = 0.8, guiColor = {r = 1, g = 0, b = 0, a = 1}}

function Orders.OnStartup()
    global.orderSlots = global.orderSlots or {}

    Orders.OnLoad()
end

function Orders.OnLoad()
end

function Orders.GetOrderGuiState(orderIndex)
    local order = global.orderSlots[orderIndex]
    local statusTexts = {"", ""}
    if order.state == Orders.SlotStates.waitingCapacityTech or order.state == Orders.SlotStates.waitingDrydock or order.state == Orders.SlotStates.waitingOrderDecryption or order.state == Orders.SlotStates.waitingCustomerDepart then
        statusTexts[1] = {"gui-text." .. Constants.ModName .. "-slotState-" .. order.state}
    elseif order.state == Orders.SlotStates.waitingItem then
        statusTexts[1] = {"item-name." .. order.item}
        if order.itemCountNeeded > 1 then
            statusTexts[2] = " " .. order.itemCountDone .. " / " .. order.itemCountNeeded
        end
    end
    return statusTexts
end

function Orders.GetOrderGuiTime(orderIndex)
    local order = global.orderSlots[orderIndex]
    local timeTexts = {"", nil}
    if order.state == Orders.SlotStates.waitingItem then
        timeTexts[1] = Utils.DisplayTimeOfTicks((order.nextDeadlineTime - game.tick), "hour", "second")
        timeTexts[2] = Orders.GetOrderTimeBonus(order).guiColor
    elseif order.state == Orders.SlotStates.waitingCustomerDepart then
        timeTexts[1] = Utils.DisplayTimeOfTicks((order.nextDeadlineTime - game.tick), "minute", "second")
    end
    return timeTexts
end

function Orders.GetOrderTimeBonus(order)
    local waitingTicks = order.nextDeadlineTime - order.startTime
    for delayTick, timeBonus in pairs(Orders.TimeBonus) do
        if waitingTicks <= delayTick then
            return timeBonus
        end
    end
end

return Orders

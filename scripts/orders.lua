local Orders = {}
local Constants = require("constants")
local Utils = require("utility/utils")
local Events = require("utility/events")

--[[
    global.Orders.orderSlots = {
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
Orders.slotStates = {waitingCapacityTech = "waitingCapacityTech", waitingDrydock = "waitingDrydock", waitingOrderDecryptionStart = "waitingOrderDecryptionStart", waitingOrderDecryptionEnd = "waitingOrderDecryptionEnd", waitingItem = "waitingItem", waitingCustomerDepart = "waitingCustomerDepart"}
Orders.TimeBonus = {}
Orders.TimeBonus[(60 * 60 * 30)] = {bonusModifier = 1.1, guiColor = {r = 0, g = 255, b = 0, a = 255}}
Orders.TimeBonus[(60 * 60 * 60 * 2)] = {bonusModifier = 1, guiColor = {r = 255, g = 252, b = 0, a = 255}}
Orders.TimeBonus[(60 * 60 * 60 * 4)] = {bonusModifier = 0.9, guiColor = {r = 255, g = 211, b = 0, a = 255}}
Orders.TimeBonus[(60 * 60 * 60 * 6)] = {bonusModifier = 0.8, guiColor = {r = 255, g = 0, b = 0, a = 255}}
Orders.shipParts = {
    ["wills_spaceship_repair-hull_component"] = {
        name = "wills_spaceship_repair-hull_component",
        value = 325000,
        chance = 0.17
    }
} -- TODO

function Orders.OnStartup()
    global.Orders = global.Orders or {}
    global.Orders.orderSlots = global.Orders.orderSlots or {}
    global.Orders.orderDecryptionsAllowed = global.Orders.orderDecryptionsAllowed or 0
    Events.ScheduleEvent(60, "Orders.UpdateOrderSlotDeadlineTimes")

    Orders.OnLoad()
end

function Orders.OnLoad()
    Events.RegisterHandler(defines.events.on_research_finished, "Orders", Orders.OnResearchFinished)
    Events.RegisterHandler(defines.events.on_rocket_launched, "Orders", Orders.OnRocketLaunched)
    Events.RegisterHandler(defines.events.on_research_started, "Orders", Orders.OnResearchStarted)
    Events.RegisterScheduledEventType("Orders.UpdateOrderSlotDeadlineTimes", Orders.UpdateOrderSlotDeadlineTimes)
end

function Orders.OnResearchFinished(event)
    local tech = event.research
    if string.find(tech.name, "wills_spaceship_repair-dry_dock-", 0, true) ~= nil then
        Orders.DryDockResearchCompleted()
    elseif string.find(tech.name, "wills_spaceship_repair-order_decryption-", 0, true) ~= nil then
        Orders.OrderDecryptionResearchCompleted()
    end
end

function Orders.OnResearchStarted(event)
    local tech = event.research
    if string.find(tech.name, "wills_spaceship_repair-order_decryption-", 0, true) ~= nil then
        for _, orderSlot in pairs(global.Orders.orderSlots) do
            if orderSlot.state == Orders.slotStates.waitingOrderDecryptionStart then
                orderSlot.state = Orders.slotStates.waitingOrderDecryptionEnd
                return
            end
        end
    else
        for _, orderSlot in pairs(global.Orders.orderSlots) do
            if orderSlot.state == Orders.slotStates.waitingOrderDecryptionEnd then
                orderSlot.state = Orders.slotStates.waitingOrderDecryptionStart
            end
        end
    end
end

function Orders.GetOrderGuiState(orderIndex)
    local order = global.Orders.orderSlots[orderIndex]
    local statusText, statusCountText = "", ""
    if order.state == Orders.slotStates.waitingCapacityTech or order.state == Orders.slotStates.waitingDrydock or order.state == Orders.slotStates.waitingOrderDecryptionStart or order.state == Orders.slotStates.waitingOrderDecryptionEnd or order.state == Orders.slotStates.waitingCustomerDepart then
        statusText = {"gui-text." .. Constants.ModName .. "-slotState-" .. order.state}
    elseif order.state == Orders.slotStates.waitingItem then
        statusText = {"item-name." .. order.item}
        if order.itemCountNeeded > 1 then
            statusCountText = " " .. order.itemCountDone .. " / " .. order.itemCountNeeded
        end
    end
    return statusText, statusCountText
end

function Orders.GetOrderGuiTime(orderIndex)
    local order = global.Orders.orderSlots[orderIndex]
    local timeText, timeColor = "", nil
    if order.state == Orders.slotStates.waitingItem then
        timeText = Utils.DisplayTimeOfTicks((order.nextDeadlineTime - game.tick), "hour", "second")
        timeColor = Orders.GetOrderTimeBonus(order).guiColor
    elseif order.state == Orders.slotStates.waitingCustomerDepart then
        timeText = Utils.DisplayTimeOfTicks((order.nextDeadlineTime - game.tick), "minute", "second")
    end
    return timeText, timeColor
end

function Orders.GetOrderTimeBonus(order)
    local waitingTicks = order.nextDeadlineTime - order.startTime
    for delayTick, timeBonus in pairs(Orders.TimeBonus) do
        if waitingTicks <= delayTick then
            return timeBonus
        end
    end
end

function Orders.DryDockResearchCompleted()
    game.print({"message.wills_spaceship_repair-drydock_research_completed"}, {r = 0, g = 1, b = 0, a = 1})
    for _, slot in pairs(global.Orders.orderSlots) do
        if slot.state == Orders.slotStates.waitingCapacityTech then
            slot.state = Orders.slotStates.waitingOrderDecryptionStart
            Orders.AddOrderDecryptionResearch()
            return
        end
    end
    Orders.AddOrderSlot(Orders.slotStates.waitingDrydock)
end

function Orders.OrderDecryptionResearchCompleted()
    game.print({"message.wills_spaceship_repair-order_decryption_completed"}, {r = 0, g = 1, b = 0, a = 1})
    global.Orders.orderDecryptionsAllowed = global.Orders.orderDecryptionsAllowed - 1
    local decryptionAllowed = 0
    local orderAdded = false
    for _, orderSlot in pairs(global.Orders.orderSlots) do
        if orderSlot.state == Orders.slotStates.waitingOrderDecryptionEnd then
            if not orderAdded then
                Orders.AddOrderToOrderSlot(orderSlot)
            else
                decryptionAllowed = decryptionAllowed + 1
            end
        end
    end
    local researchQueue = global.playerForce.research_queue
    for i, research in pairs(researchQueue) do
        if research.name == "wills_spaceship_repair-order_decryption-1" then
            if decryptionAllowed > 1 then
                decryptionAllowed = decryptionAllowed - 1
            else
                researchQueue[i] = nil
            end
        end
    end
    if decryptionAllowed > 0 then
        global.playerForce.technologies["wills_spaceship_repair-order_decryption-1"].enabled = true
    else
        global.playerForce.technologies["wills_spaceship_repair-order_decryption-1"].enabled = false
    end
    global.playerForce.research_queue = researchQueue
end

function Orders.AddOrderSlot(state)
    local slotIndex = #global.Orders.orderSlots + 1
    global.Orders.orderSlots[slotIndex] = {
        index = slotIndex,
        state = state,
        item = nil,
        itemCountNeeded = nil,
        itemCountDone = nil,
        startTime = nil,
        nextDeadlineTime = nil
    }
    return global.Orders.orderSlots[slotIndex]
end

function Orders.AddOrderDecryptionResearch()
    global.playerForce.add_research("wills_spaceship_repair-order_decryption-1")
    global.Orders.orderDecryptionsAllowed = global.Orders.orderDecryptionsAllowed + 1
    global.playerForce.technologies["wills_spaceship_repair-order_decryption-1"].enabled = true
end

function Orders.OnRocketLaunched(event)
    local rocket = event.rocket
    for name in pairs(rocket.get_inventory(defines.inventory.rocket).get_contents()) do
        if name == "wills_spaceship_repair-dry_dock" then
            Orders.DrydockLaunched()
        elseif Orders.shipParts[name] ~= nil then
            Orders.ShipPartLaunched(name)
        end
    end
end

function Orders.DrydockLaunched()
    game.print({"message.wills_spaceship_repair-drydock_launched"}, {r = 0, g = 1, b = 0, a = 1})
    for _, slot in pairs(global.Orders.orderSlots) do
        if slot.state == Orders.slotStates.waitingDrydock then
            slot.state = Orders.slotStates.waitingOrderDecryptionStart
            Orders.AddOrderDecryptionResearch()
            return
        end
    end
    Orders.AddOrderSlot(Orders.slotStates.waitingCapacityTech)
end

function Orders.ShipPartLaunched(shipPartName)
    --TODO
end

function Orders.AddOrderToOrderSlot(orderSlot)
    orderSlot.state = Orders.slotStates.waitingItem
    --TODO - testing data
    orderSlot.item = "wills_spaceship_repair-hull_component"
    orderSlot.itemCountNeeded = 2
    orderSlot.itemCountDone = 1
    orderSlot.startTime = game.tick
    orderSlot.nextDeadlineTime = game.tick + (60 * 60 * 30)
end

function Orders.UpdateOrderSlotDeadlineTimes(event)
    local tick = event.tick
    Events.ScheduleEvent(tick + 60, "Orders.UpdateOrderSlotDeadlineTimes")
    for _, order in pairs(global.Orders.orderSlots) do
        if order.nextDeadlineTime ~= nil and order.nextDeadlineTime <= tick then
            local waitingTicks = tick - order.startTime
            for delayTick in pairs(Orders.TimeBonus) do
                if waitingTicks <= delayTick then
                    order.nextDeadlineTime = order.startTime + delayTick
                    break
                end
            end
        end
    end
end

return Orders

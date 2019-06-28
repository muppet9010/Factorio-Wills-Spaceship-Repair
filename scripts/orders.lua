local Orders = {}
local Constants = require("constants")
local Utils = require("utility/utils")
local Events = require("utility/events")
local Logging = require("utility/logging")
local OrderAudit = require("scripts/orderAudit")

--[[
    global.Orders.orderSlots = {
        {
            index = 1 -- Int ID of the array in the entry
            stateName = [Orders.slotStates.name]
            item = "" -- the item name this order wants or nil
            itemCountNeeded = 3 -- the number of this item type needed or nil
            itemCountDone = 1 -- the number of this item type supplied or nil
            startTime = GAMETICK -- when the order was first decrypted or nil
            nextDeadlineTime = GAMETICK -- when the order's bonus rate next changes or nil
        }
    }

]]
Orders.slotStates = {
    waitingCapacityTech = {
        name = "waitingCapacityTech",
        timer = nil,
        color = {r = 255, g = 255, b = 255, a = 255},
        sortValue = 1
    },
    waitingDrydock = {
        name = "waitingDrydock",
        timer = nil,
        color = {r = 255, g = 255, b = 255, a = 255},
        sortValue = 2
    },
    waitingOrderDecryptionStart = {
        name = "waitingOrderDecryptionStart",
        timer = nil,
        color = {r = 255, g = 255, b = 255, a = 255},
        sortValue = 3
    },
    waitingOrderDecryptionEnd = {
        name = "waitingOrderDecryptionEnd",
        timer = nil,
        color = {r = 255, g = 255, b = 255, a = 255},
        sortValue = 4
    },
    waitingItem = {
        name = "waitingItem",
        timer = nil,
        color = {r = 255, g = 255, b = 255, a = 255},
        sortValue = 5
    },
    waitingCustomerDepart = {
        name = "waitingCustomerDepart",
        timer = (60 * 60 * 1),
        color = {r = 0, g = 255, b = 0, a = 255},
        sortValue = 0
    },
    orderFailed = {
        name = "orderFailed",
        timer = (60 * 60 * 5),
        color = {r = 255, g = 0, b = 0, a = 255},
        sortValue = -1
    }
}
Orders.timeBonus = {}
Orders.timeBonus[(60 * 60 * 30)] = {modifierPercent = 10, guiColor = {r = 0, g = 255, b = 0, a = 255}}
Orders.timeBonus[(60 * 60 * 60 * 2)] = {modifierPercent = 0, guiColor = {r = 255, g = 252, b = 0, a = 255}}
Orders.timeBonus[(60 * 60 * 60 * 4)] = {modifierPercent = -10, guiColor = {r = 255, g = 130, b = 0, a = 255}}
Orders.timeBonus[(60 * 60 * 60 * 6)] = {modifierPercent = -20, guiColor = {r = 255, g = 0, b = 0, a = 255}}

Orders.shipParts = {
    ["wills_spaceship_repair-hull_component"] = {
        name = "wills_spaceship_repair-hull_component",
        value = 325000,
        chance = 0.1687,
        multiplePerOrder = {
            {items = 1, chance = 0.6},
            {items = 2, chance = 0.3},
            {items = 3, chance = 0.1}
        }
    },
    ["wills_spaceship_repair-spaceship_thruster"] = {
        name = "wills_spaceship_repair-spaceship_thruster",
        value = 80000,
        chance = 0.1054,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-fuel_cell"] = {
        name = "wills_spaceship_repair-fuel_cell",
        value = 450000,
        chance = 0.1246,
        multiplePerOrder = {
            {items = 1, chance = 0.6},
            {items = 2, chance = 0.3},
            {items = 3, chance = 0.1}
        }
    },
    ["wills_spaceship_repair-protection_field"] = {
        name = "wills_spaceship_repair-protection_field",
        value = 575000,
        chance = 0.0962,
        multiplePerOrder = {
            {items = 1, chance = 0.6},
            {items = 2, chance = 0.3},
            {items = 3, chance = 0.1}
        }
    },
    ["wills_spaceship_repair-fusion_reactor"] = {
        name = "wills_spaceship_repair-fusion_reactor",
        value = 1254000,
        chance = 0.0668,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-habitation"] = {
        name = "wills_spaceship_repair-habitation",
        value = 450000,
        chance = 0.1218,
        multiplePerOrder = {
            {items = 1, chance = 0.6},
            {items = 2, chance = 0.3},
            {items = 3, chance = 0.1}
        }
    },
    ["wills_spaceship_repair-life_support"] = {
        name = "wills_spaceship_repair-life_support",
        value = 780000,
        chance = 0.1068,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-command_center"] = {
        name = "wills_spaceship_repair-command_center",
        value = 1130000,
        chance = 0.0734,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-astrometrics"] = {
        name = "wills_spaceship_repair-astrometrics",
        value = 840000,
        chance = 0.0991,
        multiplePerOrder = false
    },
    ["wills_spaceship_repair-ftl_propulsion_system"] = {
        name = "wills_spaceship_repair-ftl_propulsion_system",
        value = 2236000,
        chance = 0.0367,
        multiplePerOrder = false
    }
}
Utils.NormalisedChanceList(Orders.shipParts, "chance")

function Orders.OnStartup()
    global.Orders = global.Orders or {}
    global.Orders.orderSlots = global.Orders.orderSlots or {}
    Events.ScheduleEvent(60, "Orders.UpdateAllOrdersSlotDeadlineTimes")

    OrderAudit.OnStartup()
    Orders.OnLoad()
end

function Orders.OnLoad()
    Events.RegisterHandler(defines.events.on_research_finished, "Orders", Orders.OnResearchFinished)
    Events.RegisterHandler(defines.events.on_rocket_launched, "Orders", Orders.OnRocketLaunched)
    Events.RegisterHandler(defines.events.on_research_started, "Orders", Orders.OnResearchStarted)
    Events.RegisterScheduledEventType("Orders.UpdateAllOrdersSlotDeadlineTimes", Orders.UpdateAllOrdersSlotDeadlineTimes)
    Events.RegisterEvent("Orders.OrderSlotAdded")
    Events.RegisterEvent("Orders.OrderSlotUpdated")

    OrderAudit.OnLoad(Orders.slotStates)
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
            if orderSlot.stateName == Orders.slotStates.waitingOrderDecryptionStart.name then
                Orders.SetOrderSlotState(orderSlot, Orders.slotStates.waitingOrderDecryptionEnd.name)
                return
            end
        end
    else
        for _, orderSlot in pairs(global.Orders.orderSlots) do
            if orderSlot.stateName == Orders.slotStates.waitingOrderDecryptionEnd.name then
                Orders.SetOrderSlotState(orderSlot, Orders.slotStates.waitingOrderDecryptionStart.name)
            end
        end
    end
end

function Orders.GetOrderGuiState(orderIndex)
    local order = global.Orders.orderSlots[orderIndex]
    local statusText, statusCountText = "", ""
    local statusColor = Orders.slotStates[order.stateName].color
    if
        order.stateName == Orders.slotStates.waitingCapacityTech.name or order.stateName == Orders.slotStates.waitingDrydock.name or order.stateName == Orders.slotStates.waitingOrderDecryptionStart.name or order.stateName == Orders.slotStates.waitingOrderDecryptionEnd.name or order.stateName == Orders.slotStates.waitingCustomerDepart.name or
            order.stateName == Orders.slotStates.orderFailed.name
     then
        statusText = {"gui-text." .. Constants.ModName .. "-slotState-" .. order.stateName}
    elseif order.stateName == Orders.slotStates.waitingItem.name then
        statusText = {"item-name-short." .. order.item}
        if order.itemCountNeeded > 1 then
            statusCountText = " (" .. order.itemCountDone .. " / " .. order.itemCountNeeded .. ")"
        end
    end
    return statusText, statusCountText, statusColor
end

function Orders.GetOrderGuiTime(orderIndex)
    local order = global.Orders.orderSlots[orderIndex]
    local timeTicks, timeColor, timeBonusText = nil, nil, ""
    if order.stateName == Orders.slotStates.waitingItem.name then
        local timeBonus = Orders.GetOrderTimeBonus(order)
        timeTicks = order.nextDeadlineTime - game.tick
        timeColor = timeBonus.guiColor
        if timeBonus.modifierPercent >= 0 then
            timeBonusText = "+" .. tostring(timeBonus.modifierPercent) .. "% [img=item/coin]"
        else
            timeBonusText = "-" .. tostring(timeBonus.modifierPercent) .. "% [img=item/coin]"
        end
    elseif order.stateName == Orders.slotStates.waitingCustomerDepart.name then
        timeTicks = order.nextDeadlineTime - game.tick
        timeColor = Orders.slotStates.waitingCustomerDepart.color
    elseif order.stateName == Orders.slotStates.orderFailed.name then
        timeTicks = order.nextDeadlineTime - game.tick
        timeColor = Orders.slotStates.orderFailed.color
    end
    return timeTicks, timeColor, timeBonusText
end

function Orders.GetOrderTimeBonus(order)
    local waitingTicks = order.nextDeadlineTime - order.startTime
    for delayTick, timeBonus in pairs(Orders.timeBonus) do
        if waitingTicks <= delayTick then
            return timeBonus
        end
    end
end

function Orders.DryDockResearchCompleted()
    game.print({"message.wills_spaceship_repair-drydock_research_completed"}, {r = 0, g = 1, b = 0, a = 1})
    for _, slot in pairs(global.Orders.orderSlots) do
        if slot.stateName == Orders.slotStates.waitingCapacityTech.name then
            Orders.SetOrderSlotState(slot, Orders.slotStates.waitingOrderDecryptionStart.name)
            return
        end
    end
    Orders.AddOrderSlot(Orders.slotStates.waitingDrydock.name)
end

function Orders.OrderDecryptionResearchCompleted()
    game.print({"message.wills_spaceship_repair-order_decryption_completed"}, {r = 0, g = 1, b = 0, a = 1})
    local decryptionAllowed = 0
    for _, orderSlot in pairs(global.Orders.orderSlots) do
        if orderSlot.stateName == Orders.slotStates.waitingOrderDecryptionEnd.name then
            Orders.SetOrderSlotState(orderSlot, Orders.slotStates.waitingItem.name)
        elseif orderSlot.stateName == Orders.slotStates.waitingOrderDecryptionStart.name then
            decryptionAllowed = decryptionAllowed + 1
        end
    end
    local researchQueue = global.playerForce.research_queue
    local queueStartPoint = 1
    if decryptionAllowed == 0 then
        queueStartPoint = 0
    end
    for i, research in pairs(researchQueue) do
        if i > queueStartPoint and research.name == "wills_spaceship_repair-order_decryption-1" then
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

function Orders.AddOrderSlot(stateName)
    local slotIndex = #global.Orders.orderSlots + 1
    local order = {index = slotIndex}
    Orders.SetOrderSlotState(order, stateName)
    global.Orders.orderSlots[slotIndex] = order
    Events.RaiseEvent({name = "Orders.OrderSlotAdded", orderSlotIndex = slotIndex})
    return order
end

function Orders.SetOrderSlotState(order, stateName)
    local tick = game.tick
    order.stateName = stateName
    order.item = nil
    order.itemCountNeeded = nil
    order.itemCountDone = nil
    order.startTime = tick
    if Orders.slotStates[stateName].timer ~= nil then
        order.nextDeadlineTime = tick + Orders.slotStates[stateName].timer
    else
        order.nextDeadlineTime = nil
    end
    if stateName == Orders.slotStates.waitingOrderDecryptionStart.name then
        global.playerForce.add_research("wills_spaceship_repair-order_decryption-1")
        global.playerForce.technologies["wills_spaceship_repair-order_decryption-1"].enabled = true
    elseif stateName == Orders.slotStates.waitingItem.name then
        Orders.GenerateOrderInSlot(order)
    end
    Events.RaiseEvent({name = "Orders.OrderSlotUpdated", orderSlotIndex = order.index})
    OrderAudit.LogUpdateOrder(order)
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
        if slot.stateName == Orders.slotStates.waitingDrydock.name then
            Orders.SetOrderSlotState(slot, Orders.slotStates.waitingOrderDecryptionStart.name)
            return
        end
    end
    Orders.AddOrderSlot(Orders.slotStates.waitingCapacityTech.name)
end

function Orders.ShipPartLaunched(shipPartName)
    local longestWaitingTime, longestWaitingOrder = 0, nil
    local tick = game.tick
    for i, order in pairs(global.Orders.orderSlots) do
        if order.item == shipPartName and order.itemCountDone < order.itemCountNeeded then
            local timeWaiting = tick - order.startTime
            if timeWaiting >= longestWaitingTime then
                longestWaitingTime = timeWaiting
                longestWaitingOrder = order
            end
        end
    end
    if longestWaitingOrder == nil then
        local localisedShipPartName = game.item_prototypes[shipPartName].localised_name
        game.print({"message.wills_spaceship_repair-wrong_ship_part_launched", localisedShipPartName}, {r = 1, g = 0, b = 0, a = 1})
        return
    end

    longestWaitingOrder.itemCountDone = longestWaitingOrder.itemCountDone + 1
    if longestWaitingOrder.itemCountDone < longestWaitingOrder.itemCountNeeded then
        return
    end
    --TODO - call the financials here
    Orders.SetOrderSlotState(longestWaitingOrder, Orders.slotStates.waitingCustomerDepart.name)
end

function Orders.GenerateOrderInSlot(orderSlot)
    local shipPart = Utils.GetRandomEntryFromNormalisedDataSet(Orders.shipParts, "chance")
    orderSlot.item = shipPart.name
    if shipPart.multiplePerOrder == false then
        orderSlot.itemCountNeeded = 1
    else
        orderSlot.itemCountNeeded = Utils.GetRandomEntryFromNormalisedDataSet(shipPart.multiplePerOrder, "chance").items
    end
    orderSlot.itemCountDone = 0
    orderSlot.startTime = game.tick
    Orders.UpdateOrderSlotDeadlineTimes(orderSlot, game.tick)
    OrderAudit.LogNewOrder(orderSlot)
end

function Orders.UpdateAllOrdersSlotDeadlineTimes(event)
    local tick = event.tick
    Events.ScheduleEvent(tick + 60, "Orders.UpdateAllOrdersSlotDeadlineTimes")
    for _, order in pairs(global.Orders.orderSlots) do
        if order.nextDeadlineTime ~= nil and tick >= order.nextDeadlineTime then
            Orders.UpdateOrderSlotDeadlineTimes(order, tick)
        end
    end
end

function Orders.UpdateOrderSlotDeadlineTimes(order, tick)
    if order.stateName == Orders.slotStates.waitingItem.name then
        local waitingTicks = tick - order.startTime
        for delayTick in pairs(Orders.timeBonus) do
            if waitingTicks <= delayTick then
                order.nextDeadlineTime = order.startTime + delayTick
                return
            end
        end
        Orders.SetOrderSlotState(order, Orders.slotStates.orderFailed.name)
    elseif order.stateName == Orders.slotStates.orderFailed.name or order.stateName == Orders.slotStates.waitingCustomerDepart.name then
        if tick >= order.nextDeadlineTime then
            Orders.SetOrderSlotState(order, Orders.slotStates.waitingOrderDecryptionStart.name)
        end
    end
end

function Orders.OrdersIndexSortedByDueTime(orderA, orderB)
    if Orders.slotStates[orderA.stateName].sortValue > Orders.slotStates[orderB.stateName].sortValue then
        return true
    elseif Orders.slotStates[orderA.stateName].sortValue < Orders.slotStates[orderB.stateName].sortValue then
        return false
    end
    if orderA.startTime < orderB.startTime then
        return true
    else
        return false
    end
end

return Orders

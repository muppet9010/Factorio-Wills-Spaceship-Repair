local Orders, SlotStates, TimeBonus, ShipParts = {}
local Constants = require("constants")
local Utils = require("utility/utils")
local Events = require("utility/events")
--local Logging = require("utility/logging")
local EventScheduler = require("utility/event-scheduler")
local Interfaces = require("utility/interfaces")

--[[
    global.Orders.orderSlots = {
        {
            index = 1 -- Int ID of the array in the entry
            stateName = [SlotStates.name]
            item = "" -- the item name this order wants or nil
            itemCountNeeded = 3 -- the number of this item type needed or nil
            itemCountDone = 1 -- the number of this item type supplied or nil
            startTime = GAMETICK -- when the order was first decrypted or nil
            deadlineTime = GAMETICK -- when the order's bonus rate next changes or nil
        }
    }

]]
function Orders.CreateGlobals()
    global.Orders = global.Orders or {}
    global.Orders.orderSlots = global.Orders.orderSlots or {}
end

function Orders.OnStartup()
    if not EventScheduler.IsEventScheduled("Orders.CheckAllOrdersSlotDeadlineTimes") then
        EventScheduler.ScheduleEvent(60, "Orders.CheckAllOrdersSlotDeadlineTimes")
    end
end

function Orders.OnLoad()
    SlotStates = global.StaticData.Orders.slotStates
    TimeBonus = global.StaticData.Orders.timeBonus
    ShipParts = global.StaticData.Orders.shipParts
    Events.RegisterHandler(defines.events.on_research_finished, "Orders", Orders.OnResearchFinished)
    Events.RegisterHandler(defines.events.on_rocket_launched, "Orders", Orders.OnRocketLaunched)
    Events.RegisterHandler(defines.events.on_research_started, "Orders", Orders.OnResearchStarted)
    EventScheduler.RegisterScheduledEventType("Orders.CheckAllOrdersSlotDeadlineTimes", Orders.CheckAllOrdersSlotDeadlineTimes)
    Events.RegisterEvent("Orders.OrderSlotAdded")
    Events.RegisterEvent("Orders.OrderSlotUpdated")
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
            if orderSlot.stateName == SlotStates.waitingOrderDecryptionStart.name then
                Orders.SetOrderSlotState(orderSlot, SlotStates.waitingOrderDecryptionEnd.name)
                return
            end
        end
    else
        for _, orderSlot in pairs(global.Orders.orderSlots) do
            if orderSlot.stateName == SlotStates.waitingOrderDecryptionEnd.name then
                Orders.SetOrderSlotState(orderSlot, SlotStates.waitingOrderDecryptionStart.name)
            end
        end
    end
end

function Orders.GetOrderGuiState(orderIndex)
    local order = global.Orders.orderSlots[orderIndex]
    local statusText, statusCountText = "", ""
    local statusColor = SlotStates[order.stateName].color
    if order.stateName == SlotStates.waitingCapacityTech.name or order.stateName == SlotStates.waitingDrydock.name or order.stateName == SlotStates.waitingOrderDecryptionStart.name or order.stateName == SlotStates.waitingOrderDecryptionEnd.name or order.stateName == SlotStates.waitingCustomerDepart.name or order.stateName == SlotStates.orderFailed.name then
        statusText = {"gui-text." .. Constants.ModName .. "-slotState-" .. order.stateName}
    elseif order.stateName == SlotStates.waitingItem.name then
        statusText = {"item-name." .. order.item}
        if order.itemCountNeeded > 1 then
            statusCountText = " (" .. order.itemCountDone .. " / " .. order.itemCountNeeded .. ")"
        end
    end
    return statusText, statusCountText, statusColor
end

function Orders.GetOrderGuiTime(orderIndex)
    local order = global.Orders.orderSlots[orderIndex]
    local timeTicks, timeColor, timeBonusText = nil, nil, ""
    if order.stateName == SlotStates.waitingItem.name then
        local timeBonus = Orders.GetOrderTimeBonus(order)
        timeTicks = order.deadlineTime - game.tick
        timeColor = timeBonus.guiColor
        if timeBonus.modifierPercent >= 0 then
            timeBonusText = "+" .. tostring(timeBonus.modifierPercent) .. "% [img=item/coin]"
        else
            timeBonusText = tostring(timeBonus.modifierPercent) .. "% [img=item/coin]"
        end
    elseif order.stateName == SlotStates.waitingCustomerDepart.name then
        timeTicks = order.deadlineTime - game.tick
        timeColor = SlotStates.waitingCustomerDepart.color
    elseif order.stateName == SlotStates.orderFailed.name then
        timeTicks = order.deadlineTime - game.tick
        timeColor = SlotStates.orderFailed.color
    end
    return timeTicks, timeColor, timeBonusText
end

function Orders.GetOrderTimeBonus(order)
    local waitingTicks = game.tick - order.startTime
    for delayTick, timeBonus in pairs(TimeBonus) do
        if waitingTicks <= delayTick then
            return timeBonus
        end
    end
end

function Orders.DryDockResearchCompleted()
    for _, slot in pairs(global.Orders.orderSlots) do
        if slot.stateName == SlotStates.waitingCapacityTech.name then
            Orders.SetOrderSlotState(slot, SlotStates.waitingOrderDecryptionStart.name)
            return
        end
    end
    Orders.AddOrderSlot(SlotStates.waitingDrydock.name)
end

function Orders.OrderDecryptionResearchCompleted()
    local decryptionAllowed = 0
    local orderDecrypted = false
    for _, orderSlot in pairs(global.Orders.orderSlots) do
        if orderSlot.stateName == SlotStates.waitingOrderDecryptionEnd.name then
            Orders.SetOrderSlotState(orderSlot, SlotStates.waitingItem.name)
            orderDecrypted = true
        elseif orderSlot.stateName == SlotStates.waitingOrderDecryptionStart.name then
            decryptionAllowed = decryptionAllowed + 1
        end
    end
    if not orderDecrypted then
        --Editor allows you to complete a research without ever starting it. So fake that the research started before being completed.
        Orders.OnResearchStarted({research = {name = "wills_spaceship_repair-order_decryption-1"}})
        Orders.OrderDecryptionResearchCompleted()
        return
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
    Events.RaiseEvent({name = "Orders.OrderSlotAdded", order = order})
    return order
end

function Orders.SetOrderSlotState(order, stateName)
    local tick = game.tick
    order.stateName = stateName
    order.startTime = tick
    if SlotStates[stateName].timer ~= nil then
        order.deadlineTime = tick + SlotStates[stateName].timer
    else
        order.deadlineTime = nil
    end

    if stateName == SlotStates.waitingOrderDecryptionStart.name then
        global.playerForce.technologies["wills_spaceship_repair-order_decryption-1"].enabled = true
        global.playerForce.add_research("wills_spaceship_repair-order_decryption-1")
    elseif stateName == SlotStates.waitingItem.name then
        Orders.GenerateOrderInSlot(order)
    elseif stateName == SlotStates.orderFailed.name then
        local itemValue = ShipParts[order.item].value
        local itemCountNeededString = ""
        if order.itemCountNeeded > 1 then
            itemCountNeededString = order.itemCountNeeded .. " "
        end
        local localisedItemDisplayName = {"misc.wills_spaceship_repair-double", itemCountNeededString, {"item-name." .. order.item}}
        Interfaces.Call("Investments.AddInvestment", "Missed Order Penalty", itemValue / global.Investments.dividendsmultiplier, 1)
        game.print({"message.wills_spaceship_repair-order_failed_penalty", localisedItemDisplayName, itemValue})
    end

    Events.RaiseEvent({name = "Orders.OrderSlotUpdated", order = order})
end

function Orders.OnRocketLaunched(event)
    local rocket = event.rocket
    local silo = event.rocket_silo
    for name in pairs(rocket.get_inventory(defines.inventory.rocket).get_contents()) do
        if name == "wills_spaceship_repair-dry_dock" then
            Orders.DrydockLaunched()
        elseif ShipParts[name] ~= nil then
            Orders.ShipPartLaunched(name, silo)
        end
    end
end

function Orders.DrydockLaunched()
    for _, slot in pairs(global.Orders.orderSlots) do
        if slot.stateName == SlotStates.waitingDrydock.name then
            Orders.SetOrderSlotState(slot, SlotStates.waitingOrderDecryptionStart.name)
            return
        end
    end
    Orders.AddOrderSlot(SlotStates.waitingCapacityTech.name)
end

function Orders.ShipPartLaunched(shipPartName, siloEntity)
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
        game.print({"message.wills_spaceship_repair-wrong_ship_part_launched", localisedShipPartName}, Constants.Colors.red)
        return
    end

    longestWaitingOrder.itemCountDone = longestWaitingOrder.itemCountDone + 1
    if longestWaitingOrder.itemCountDone < longestWaitingOrder.itemCountNeeded then
        Events.RaiseEvent({name = "Orders.OrderSlotUpdated", order = longestWaitingOrder})
        return
    end

    local orderBonus = Orders.GetOrderTimeBonus(longestWaitingOrder)
    local coinCount = math.floor((ShipParts[shipPartName].value * longestWaitingOrder.itemCountNeeded) * (1 + (orderBonus.modifierPercent / 100)))
    global.playerForce.item_production_statistics.on_flow("coin", coinCount)

    local coinsToPlace = coinCount - siloEntity.get_inventory(defines.inventory.rocket_silo_result).insert({name = "coin", count = coinCount})
    if coinsToPlace > 0 then
        siloEntity.surface.spill_item_stack(siloEntity.position, {name = "coin", count = coinsToPlace}, true, nil, true)
    end

    Orders.SetOrderSlotState(longestWaitingOrder, SlotStates.waitingCustomerDepart.name)
end

function Orders.GenerateOrderInSlot(orderSlot)
    local shipPart = Utils.GetRandomEntryFromNormalisedDataSet(ShipParts, "chance")
    orderSlot.item = shipPart.name
    if shipPart.multiplePerOrder == false then
        orderSlot.itemCountNeeded = 1
    else
        orderSlot.itemCountNeeded = Utils.GetRandomEntryFromNormalisedDataSet(shipPart.multiplePerOrder, "chance").items
    end
    orderSlot.itemCountDone = 0
    orderSlot.startTime = game.tick
end

function Orders.CheckAllOrdersSlotDeadlineTimes(event)
    local tick = event.tick
    EventScheduler.ScheduleEvent(tick + 60, "Orders.CheckAllOrdersSlotDeadlineTimes")
    for _, order in pairs(global.Orders.orderSlots) do
        if order.deadlineTime ~= nil then
            Orders.CheckOrderSlotDeadlineTime(order, tick)
        end
    end
end

function Orders.CheckOrderSlotDeadlineTime(order, tick)
    if order.stateName == SlotStates.waitingItem.name then
        if tick >= order.deadlineTime then
            Orders.SetOrderSlotState(order, SlotStates.orderFailed.name)
        end
    elseif order.stateName == SlotStates.orderFailed.name or order.stateName == SlotStates.waitingCustomerDepart.name then
        if tick >= order.deadlineTime then
            Orders.SetOrderSlotState(order, SlotStates.waitingOrderDecryptionStart.name)
        end
    end
end

function Orders.OrdersIndexSortedByDueTime(orderA, orderB)
    if SlotStates[orderA.stateName].sortValue > SlotStates[orderB.stateName].sortValue then
        return true
    elseif SlotStates[orderA.stateName].sortValue < SlotStates[orderB.stateName].sortValue then
        return false
    end
    if orderA.startTime < orderB.startTime then
        return true
    else
        return false
    end
end

return Orders

local GuiOrders = {}
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
local Utils = require("utility/utils")
local Orders = require("scripts/orders")
--local Logging = require("utility/logging")

function GuiOrders.OnStartup()
    global.GuiOrders = global.GuiOrders or {}
    global.GuiOrders.orderGuiIndexMapping = global.GuiOrders.orderGuiIndexMapping or {}
end

function GuiOrders.OnLoad()
    Events.RegisterHandler(defines.events.on_player_joined_game, "GuiOrders", GuiOrders.OnPlayerJoinedGame)
    Events.RegisterScheduledEventType("GuiOrders.OnSecondUpdate", GuiOrders.OnSecondUpdate)
    Events.RegisterHandler("Orders.OrderSlotAdded", "GuiOrders.OnOrderSlotAdded", GuiOrders.OnOrderSlotAdded)
    Events.RegisterHandler("Orders.OrderSlotUpdated", "GuiOrders.OnOrderSlotUpdated", GuiOrders.RefreshOrdersAll)
    Events.RegisterScheduledEventType("GuiOrders.UpdateOrderSlotRow", GuiOrders.UpdateOrderSlotRow)
end

function GuiOrders.RefreshOrdersPlayer(player)
    local orderSlotValues = GuiOrders.CalculateAllOrderSlotTableValues()
    GuiOrders.UpdateAllOrderSlotElements(player, orderSlotValues)
end

function GuiOrders.RefreshOrdersAll()
    local orderSlotValues = GuiOrders.CalculateAllOrderSlotTableValues()
    for _, player in ipairs(game.connected_players) do
        GuiOrders.UpdateAllOrderSlotElements(player, orderSlotValues)
    end
end

function GuiOrders.UpdateAllOrderSlotElements(player, orderSlotsValues)
    if #orderSlotsValues > 0 then
        for i, orderSlotValues in pairs(orderSlotsValues) do
            GuiOrders.UpdateOrderSlotElements(player, orderSlotValues, i)
        end
    end
    Events.RemoveScheduledEvents("GuiOrders.UpdateOrderSlotRow")
    local tick = game.tick
    for _, order in pairs(global.Orders.orderSlots) do
        local timeWaiting = tick - order.startTime
        local lastUpdateWaitingTick = math.floor(timeWaiting / 3600) * 3600
        local nextUpdateTick = order.startTime + lastUpdateWaitingTick + 3600
        Events.ScheduleEvent(nextUpdateTick, "GuiOrders.UpdateOrderSlotRow", order.index)
    end
end

function GuiOrders.UpdateOrderSlotElements(player, orderSlotValues, guiIndex)
    local orderStatusElm = GuiUtil.GetElementFromPlayersReferenceStorage(player.index, "order_status_" .. guiIndex, "label")
    orderStatusElm.caption = {"gui-caption.wills_spaceship_repair-order_status-label", orderSlotValues.status1, orderSlotValues.status2}
    orderStatusElm.style.font_color = orderSlotValues.statusColor
    local bonusElm = GuiUtil.GetElementFromPlayersReferenceStorage(player.index, "order_time_bonus" .. guiIndex, "label")
    bonusElm.caption = orderSlotValues.timeBonusText
    bonusElm.style.font_color = orderSlotValues.timeColor
    local timerElm = GuiUtil.GetElementFromPlayersReferenceStorage(player.index, "order_time" .. guiIndex, "label")
    timerElm.caption = orderSlotValues.timeValue
    timerElm.style.font_color = orderSlotValues.timeColor
    global.GuiOrders.orderGuiIndexMapping[orderSlotValues.index] = guiIndex
end

function GuiOrders.CalculateAllOrderSlotTableValues()
    local sortedOrders = {}
    for _, order in pairs(global.Orders.orderSlots) do
        table.insert(sortedOrders, order)
    end
    table.sort(sortedOrders, Orders.OrdersIndexSortedByDueTime)
    local tableValues = {}
    for i, order in pairs(sortedOrders) do
        tableValues[i] = GuiOrders.CalculateOrderSlotTableValues(order.index)
    end
    return tableValues
end

function GuiOrders.CalculateOrderSlotTableValues(orderIndex)
    local orderStatusText, orderStatusCountText, orderStatusColor = Orders.GetOrderGuiState(orderIndex)
    local orderTimeTicks, orderTimeColor, orderTimeBonus = Orders.GetOrderGuiTime(orderIndex)
    local slotValues = {index = orderIndex, status1 = orderStatusText, status2 = orderStatusCountText, statusColor = orderStatusColor, timeValue = Utils.DisplayTimeOfTicks(orderTimeTicks, "hour", "minute"), timeColor = orderTimeColor, timeBonusText = orderTimeBonus}
    return slotValues
end

function GuiOrders.OnOrderSlotAdded(event)
    local orderSlotIndex = event.orderSlotIndex
    local order = global.Orders.orderSlots[orderSlotIndex]
    for _, player in pairs(game.connected_players) do
        local table = GuiOrders.GetAddOrderSlotTable(player)
        GuiOrders.AddOrderSlotRow(order, table)
    end
    GuiOrders.RefreshOrdersAll()
end

function GuiOrders.CreateOrderSlots(player)
    if #global.Orders.orderSlots == 0 then
        return
    end
    local table = GuiOrders.GetAddOrderSlotTable(player)
    for _, order in pairs(global.Orders.orderSlots) do
        GuiOrders.AddOrderSlotRow(order, table)
    end
    GuiOrders.RefreshOrdersPlayer(player)
end

function GuiOrders.GetAddOrderSlotTable(player)
    local table = GuiUtil.GetElementFromPlayersReferenceStorage(player.index, "orderSlots", "table")
    if table == nil then
        local guiFlow = GuiUtil.GetElementFromPlayersReferenceStorage(player.index, "gui", "flow")
        local ordersFrame = GuiUtil.AddElement({parent = guiFlow, name = "orderSlots", type = "frame", direction = "vertical", style = "muppet_padded_frame"}, false)
        local ordersScroll = GuiUtil.AddElement({parent = ordersFrame, name = "orderSlots", type = "scroll-pane", horizontal_scroll_policy = "never", vertical_scroll_policy = "auto"}, false)
        ordersScroll.style.maximal_height = 300
        table = GuiUtil.AddElement({parent = ordersScroll, name = "orderSlots", type = "table", column_count = 3, draw_horizontal_lines = true, draw_vertical_lines = false, style = "muppet_padded_table_cells"}, true)
    end
    return table
end

function GuiOrders.AddOrderSlotRow(order, table)
    GuiUtil.AddElement({parent = table, name = "order_status_" .. order.index, type = "label", caption = "", style = "muppet_bold_text"}, true)
    GuiUtil.AddElement({parent = table, name = "order_time_bonus" .. order.index, type = "label", caption = "", style = "muppet_bold_text"}, true)
    GuiUtil.AddElement({parent = table, name = "order_time" .. order.index, type = "label", caption = "", style = "muppet_bold_text"}, true)
end

function GuiOrders.UpdateOrderSlotRow(scheduledEvent)
    local orderIndex = scheduledEvent.instanceId
    Events.ScheduleEvent(scheduledEvent.tick + 3600, "GuiOrders.UpdateOrderSlotRow", orderIndex)
    local orderSlotValues = GuiOrders.CalculateOrderSlotTableValues(orderIndex)
    local guiIndex = global.GuiOrders.orderGuiIndexMapping[orderSlotValues.index]
    for _, player in ipairs(game.connected_players) do
        GuiOrders.UpdateOrderSlotElements(player, orderSlotValues, guiIndex)
    end
end

return GuiOrders

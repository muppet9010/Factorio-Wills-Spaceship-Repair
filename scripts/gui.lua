local Gui = {}
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
local Utils = require("utility/utils")
local Orders = require("scripts/orders")
local Logging = require("utility/logging")

function Gui.OnStartup()
    GuiUtil.CreateAllPlayersElementReferenceStorage()
    Gui.GuiRecreateAll()
    Events.ScheduleEvent(60, "Gui.OnSecondUpdate")
    Events.ScheduleEvent(3600, "Gui.OnMinuteUpdate")

    Gui.OnLoad()
end

function Gui.OnLoad()
    Events.RegisterHandler(defines.events.on_player_joined_game, "Gui", Gui.OnPlayerJoinedGame)
    Events.RegisterScheduledEventType("Gui.OnSecondUpdate", Gui.OnSecondUpdate)
    Events.RegisterScheduledEventType("Gui.OnMinuteUpdate", Gui.OnMinuteUpdate)
    Events.RegisterHandler(defines.events.on_lua_shortcut, "Gui", Gui.OnLuaShortcut)
    Events.RegisterHandler("Orders.OrderSlotAdded", "Gui.OnOrderSlotAdded", Gui.OnOrderSlotAdded)
    Events.RegisterHandler("Orders.OrderSlotUpdated", "Gui.OnOrderSlotUpdated", Gui.RefreshOrdersAll)
end

function Gui.OnSecondUpdate(event)
    Events.ScheduleEvent(event.tick + 60, "Gui.OnSecondUpdate")
    Gui.RefreshStatusAll()
end

function Gui.OnMinuteUpdate(event)
    Events.ScheduleEvent(event.tick + 3600, "Gui.OnMinuteUpdate")
    Gui.RefreshOrdersAll()
end

function Gui.OnPlayerJoinedGame(event)
    local player = game.get_player(event.player_index)
    Gui.GuiRecreate(player)
end

function Gui.GuiRecreateAll()
    for _, player in ipairs(game.connected_players) do
        Gui.GuiRecreate(player)
    end
end

function Gui.GuiRecreate(player)
    Gui.DestroyAllGuis(player)
    GuiUtil.CreatePlayersElementReferenceStorage(player.index)
    GuiUtil.AddElement({parent = player.gui.left, name = "gui", type = "flow", style = "muppet_padded_vertical_flow", direction = "vertical"}, true)
    Gui.CreateStatusGui(player)
    Gui.CreateOrderSlots(player)
end

function Gui.DestroyAllGuis(player)
    GuiUtil.DestroyPlayersReferenceStorage(player.index)
end

function Gui.CreateStatusGui(player)
    local guiFlow = GuiUtil.GetElementFromPlayersReferenceStorage(player.index, "gui", "flow")
    local statusFrame = GuiUtil.AddElement({parent = guiFlow, name = "status", type = "frame", direction = "vertical", style = "muppet_padded_frame"}, false)
    local statusTable = GuiUtil.AddElement({parent = statusFrame, name = "status", type = "table", column_count = 2, draw_horizontal_lines = false, draw_vertical_lines = false}, false)
    GuiUtil.AddElement({parent = statusTable, name = "total_debt", type = "label", caption = "self", style = "muppet_large_bold_text"}, false)
    GuiUtil.AddElement({parent = statusTable, name = "total_debt_value", type = "label", caption = "", style = "muppet_large_bold_text"}, true)
    GuiUtil.AddElement({parent = statusTable, name = "wages", type = "label", caption = "self", tooltip = "self", style = "muppet_bold_text"}, false)
    GuiUtil.AddElement({parent = statusTable, name = "wages_value", type = "label", caption = "", tooltip = "self", style = "muppet_bold_text"}, true)
    GuiUtil.AddElement({parent = statusTable, name = "dividends", type = "label", caption = "self", tooltip = "self", style = "muppet_bold_text"}, false)
    GuiUtil.AddElement({parent = statusTable, name = "dividends_value", type = "label", caption = "", tooltip = "self", style = "muppet_bold_text"}, true)
    GuiUtil.AddElement({parent = statusTable, name = "bankruptcy_limit", type = "label", caption = "self", style = "muppet_large_bold_text"}, false)
    GuiUtil.AddElement({parent = statusTable, name = "bankruptcy_limit_value", type = "label", caption = "", style = "muppet_large_bold_text"}, true)
    GuiUtil.AddElement({parent = statusTable, name = "profit", type = "label", caption = "self", tooltip = "self", style = "muppet_large_bold_text"}, false)
    GuiUtil.AddElement({parent = statusTable, name = "profit_value", type = "label", caption = "", tooltip = "self", style = "muppet_large_bold_text"}, true)
    GuiUtil.AddElement({parent = statusTable, name = "workforce_recruited", type = "label", caption = "self", tooltip = "self", style = "muppet_large_bold_text"}, false)
    GuiUtil.AddElement({parent = statusTable, name = "workforce_recruited_value", type = "label", caption = "", tooltip = "self", style = "muppet_large_bold_text"}, true)
    GuiUtil.AddElement({parent = statusTable, name = "game_time", type = "label", caption = "self", style = "muppet_large_bold_text"}, false)
    GuiUtil.AddElement({parent = statusTable, name = "game_time_value", type = "label", caption = "", style = "muppet_large_bold_text"}, true)

    Gui.RefreshStatusPlayer(player)
end

function Gui.RefreshStatusPlayer(player)
    local guiValues = Gui.CalculateStatusElementValues()
    Gui.UpdateStatusElements(player, guiValues)
end

function Gui.RefreshStatusAll()
    local guiValues = Gui.CalculateStatusElementValues()
    for _, player in ipairs(game.connected_players) do
        Gui.UpdateStatusElements(player, guiValues)
    end
end

function Gui.CalculateStatusElementValues()
    local guiValues = {}
    guiValues.totalDebt = Utils.DisplayNumberPretty((global.Financials.wagesTotal - global.Financials.wagesPaid) + (global.Investments.dividendsTotal - global.Investments.dividendsPaid))
    guiValues.bankruptcyLimit = Utils.DisplayNumberPretty(global.Financials.bankruptcyLimit)
    guiValues.dividendsPaid = Utils.DisplayNumberPretty(global.Investments.dividendsPaid)
    guiValues.dividendsTotal = Utils.DisplayNumberPretty(global.Investments.dividendsTotal)
    guiValues.wagesPaid = Utils.DisplayNumberPretty(global.Financials.wagesPaid)
    guiValues.wagesTotal = Utils.DisplayNumberPretty(global.Financials.wagesTotal)
    guiValues.currentWorkforce = #game.connected_players - 1
    guiValues.maxWorkforce = global.recruitedWorkforceCount
    guiValues.gameTime = Utils.DisplayTimeOfTicks(game.tick, "hour", "second")
    guiValues.profitMade = Utils.DisplayNumberPretty(global.Financials.profitMade)
    guiValues.profitTarget = Utils.DisplayNumberPretty(global.Financials.profitTarget)
    return guiValues
end

function Gui.UpdateStatusElements(player, guiValues)
    local playerIndex = player.index
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "total_debt_value", "label", {caption = guiValues.totalDebt})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "bankruptcy_limit_value", "label", {caption = guiValues.bankruptcyLimit})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "dividends_value", "label", {caption = {"self", guiValues.dividendsPaid, guiValues.dividendsTotal}})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "wages_value", "label", {caption = {"self", guiValues.wagesPaid, guiValues.wagesTotal}})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "workforce_recruited_value", "label", {caption = {"self", guiValues.currentWorkforce, guiValues.maxWorkforce}})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "game_time_value", "label", {caption = guiValues.gameTime})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "profit_value", "label", {caption = {"self", guiValues.profitMade, guiValues.profitTarget}})
end

function Gui.RefreshOrdersPlayer(player)
    local orderSlotValues = Gui.CalculateOrderSlotTableValues()
    Gui.UpdateOrderSlotElements(player, orderSlotValues)
end

function Gui.RefreshOrdersAll()
    local orderSlotValues = Gui.CalculateOrderSlotTableValues()
    for _, player in ipairs(game.connected_players) do
        Gui.UpdateOrderSlotElements(player, orderSlotValues)
    end
end

function Gui.UpdateOrderSlotElements(player, orderSlotValues)
    if #orderSlotValues > 0 then
        for i, order in pairs(orderSlotValues) do
            local orderStatusElm = GuiUtil.GetElementFromPlayersReferenceStorage(player.index, "order_status_" .. i, "label")
            orderStatusElm.caption = {"gui-caption.wills_spaceship_repair-order_status-label", order.status1, order.status2}
            orderStatusElm.style.font_color = order.statusColor
            local bonusElm = GuiUtil.GetElementFromPlayersReferenceStorage(player.index, "order_time_bonus" .. i, "label")
            bonusElm.caption = order.timeBonusText
            bonusElm.style.font_color = order.timeColor
            local timerElm = GuiUtil.GetElementFromPlayersReferenceStorage(player.index, "order_time" .. i, "label")
            timerElm.caption = order.timeValue
            timerElm.style.font_color = order.timeColor
        end
    end
end

function Gui.CalculateOrderSlotTableValues()
    local tableValues = {}
    local sortedOrders = {}
    for _, order in pairs(global.Orders.orderSlots) do
        table.insert(sortedOrders, order)
    end
    table.sort(sortedOrders, Orders.OrdersIndexSortedByDueTime)
    for i, order in pairs(sortedOrders) do
        local orderStatusText, orderStatusCountText, orderStatusColor = Orders.GetOrderGuiState(order.index)
        local orderTimeTicks, orderTimeColor, orderTimeBonus = Orders.GetOrderGuiTime(order.index)
        tableValues[i] = {index = order.index, status1 = orderStatusText, status2 = orderStatusCountText, statusColor = orderStatusColor, timeValue = Utils.DisplayTimeOfTicks(orderTimeTicks, "hour", "minute"), timeColor = orderTimeColor, timeBonusText = orderTimeBonus}
    end
    return tableValues
end

function Gui.OnOrderSlotAdded(event)
    local orderSlotIndex = event.orderSlotIndex
    local order = global.Orders.orderSlots[orderSlotIndex]
    for _, player in pairs(game.connected_players) do
        local table = Gui.GetAddOrderSlotTable(player)
        Gui.AddOrderSlotRow(order, table)
    end
    Gui.RefreshOrdersAll()
end

function Gui.CreateOrderSlots(player)
    if #global.Orders.orderSlots == 0 then
        return
    end
    local table = Gui.GetAddOrderSlotTable(player)
    for _, order in pairs(global.Orders.orderSlots) do
        Gui.AddOrderSlotRow(order, table)
    end
    Gui.RefreshOrdersPlayer(player)
end

function Gui.GetAddOrderSlotTable(player)
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

function Gui.AddOrderSlotRow(order, table)
    GuiUtil.AddElement({parent = table, name = "order_status_" .. order.index, type = "label", caption = "", style = "muppet_bold_text"}, true)
    GuiUtil.AddElement({parent = table, name = "order_time_bonus" .. order.index, type = "label", caption = "", style = "muppet_bold_text"}, true)
    GuiUtil.AddElement({parent = table, name = "order_time" .. order.index, type = "label", caption = "", style = "muppet_bold_text"}, true)
end

function Gui.OnLuaShortcut(event)
    local shortcutName = event.prototype_name
    if shortcutName ~= "wills_spaceship_repair-investments_gui_button" then
        return
    end
    local player = game.get_player(event.player_index)
    Gui.ToggleInvestmentsGui(player)
end

function Gui.ToggleInvestmentsGui(player)
    if GuiUtil.GetElementFromPlayersReferenceStorage(player.index, "investment", "frame") ~= nil then
        Gui.DestroyInvestmentsGui(player)
    else
        Gui.CreateInvestmentsGui(player)
    end
end

function Gui.DestroyInvestmentsGui(player)
    GuiUtil.DestroyElementInPlayersReferenceStorage(player.index, "investment", "frame")
end

function Gui.CreateInvestmentsGui(player)
    local investmentFrame = GuiUtil.AddElement({parent = player.gui.center, name = "investment", type = "frame", direction = "vertical", style = "muppet_padded_frame"}, true)
    investmentFrame.style.maximal_width = 1400
    investmentFrame.style.maximal_height = 800
    GuiUtil.AddElement({parent = investmentFrame, name = "investment_title", type = "label", style = "muppet_large_bold_text", caption = "self"}, false)
end

return Gui

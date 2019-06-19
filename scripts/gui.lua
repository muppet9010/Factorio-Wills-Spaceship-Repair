local Gui = {}
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
local Utils = require("utility/utils")
local Orders = require("scripts/orders")

function Gui.OnStartup()
    GuiUtil.CreateAllPlayersElementReferenceStorage()
    Gui.GuiRecreateAll()

    Gui.OnLoad()
end

function Gui.OnLoad()
    Events.RegisterHandler("on60ticks", "Gui", Gui.OnSecondUpdate)
    Events.RegisterHandler(defines.events.on_player_joined_game, "Gui", Gui.OnPlayerJoinedGame)
end

function Gui.OnSecondUpdate()
    Gui.RefreshAll()
end

function Gui.OnPlayerJoinedGame(event)
    local player = game.get_player(event.player_index)
    Gui.GuiRecreate(player)
end

function Gui.GuiRecreateAll()
    for _, player in pairs(game.connected_players) do
        Gui.GuiRecreate(player)
    end
end

function Gui.GuiRecreate(player)
    Gui.DestroyGui(player)
    Gui.CreateGui(player)
end

function Gui.DestroyGui(player)
    GuiUtil.DestroyPlayersReferenceStorage(player.index)
end

function Gui.CreateGui(player)
    GuiUtil.CreatePlayersElementReferenceStorage(player.index)

    local guiFlow = GuiUtil.AddElement({parent = player.gui.left, name = "gui", type = "flow", style = "muppet_padded_vertical_flow", direction = "vertical"}, true)

    local statusFrame = GuiUtil.AddElement({parent = guiFlow, name = "status", type = "frame", direction = "vertical", style = "muppet_padded_frame"}, false)
    GuiUtil.AddElement({parent = statusFrame, name = "bank_balance", type = "label", caption = "", tooltip = "self", style = "muppet_large_bold_text"}, true)
    GuiUtil.AddElement({parent = statusFrame, name = "bankruptcy_limit", type = "label", caption = "", style = "muppet_large_bold_text"}, true)
    GuiUtil.AddElement({parent = statusFrame, name = "dividends", type = "label", caption = "", tooltip = "self", style = "muppet_large_bold_text"}, true)
    GuiUtil.AddElement({parent = statusFrame, name = "wages", type = "label", caption = "", tooltip = "self", style = "muppet_large_bold_text"}, true)
    GuiUtil.AddElement({parent = statusFrame, name = "workforce_recruited", type = "label", caption = "", tooltip = "self", style = "muppet_large_bold_text"}, true)
    GuiUtil.AddElement({parent = statusFrame, name = "game_time", type = "label", caption = "", style = "muppet_large_bold_text"}, true)
    GuiUtil.AddElement({parent = statusFrame, name = "profit", type = "label", caption = "", tooltip = "self", style = "muppet_large_bold_text"}, true)
    GuiUtil.AddElement({parent = statusFrame, name = "view_investors", type = "button", caption = "self", style = "muppet_large_button"}, false)

    local ordersFrame = GuiUtil.AddElement({parent = guiFlow, name = "orderSlots", type = "frame", direction = "vertical", style = "muppet_padded_frame"}, false)
    GuiUtil.AddElement({parent = ordersFrame, name = "orderSlots", type = "table", column_count = 3, draw_horizontal_lines = true, draw_vertical_lines = true}, true)
end

function Gui.RefreshPlayer(player)
    local guiValues = Gui.CalculateStatusElementValues()
    local orderSlotValues = Gui.CalculateOrderSlotTableValues()
    Gui.UpdateStatusElements(player, guiValues)
    Gui.UpdateOrderSlotElements(player, orderSlotValues)
end

function Gui.RefreshAll()
    local guiValues = Gui.CalculateStatusElementValues()
    local orderSlotValues = Gui.CalculateOrderSlotTableValues()
    for _, player in pairs(game.connected_players) do
        Gui.UpdateStatusElements(player, guiValues)
        Gui.UpdateOrderSlotElements(player, orderSlotValues)
    end
end

function Gui.CalculateStatusElementValues()
    local guiValues = {}
    guiValues.bankBalance = global.bankBalance
    guiValues.bankruptcyLimit = global.bankruptcyLimit
    guiValues.dividendsPaid = global.dividendsPaid
    guiValues.dividendsTotal = global.dividendsTotal
    guiValues.wagesPaid = global.wagesPaid
    guiValues.wagesTotal = global.wagesTotal
    guiValues.currentWorkforce = #game.connected_players - 1
    guiValues.maxWorkforce = global.recruitedWorkforceCount
    guiValues.gameTime = Utils.LocalisedStringOfTime(game.tick, "hour", "second")
    guiValues.profitTarget = global.profitTarget
    return guiValues
end

function Gui.UpdateStatusElements(player, guiValues)
    local playerIndex = player.index
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "bank_balance", "label", {caption = {"self", guiValues.bankBalance, guiValues.profitTarget}})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "bankruptcy_limit", "label", {caption = {"self", guiValues.bankruptcyLimit}})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "dividends", "label", {caption = {"self", guiValues.dividendsPaid, guiValues.dividendsTotal}})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "wages", "label", {caption = {"self", guiValues.wagesPaid, guiValues.wagesTotal}})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "workforce_recruited", "label", {caption = {"self", guiValues.currentWorkforce, guiValues.maxWorkforce}})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "game_time", "label", {caption = {"self", guiValues.gameTime}})
end

function Gui.UpdateOrderSlotElements(player, orderSlotValues)
    local table = GuiUtil.GetElementFromPlayersReferenceStorage(player.index, "orderSlots", "table")
    for _, child in pairs(table.children) do
        if child.valid then
            child.destroy()
        end
    end
    for _, order in pairs(orderSlotValues) do
        GuiUtil.AddElement({parent = table, name = "order_slot_name_" .. order.index, type = "label", caption = {"gui-caption.wills_spaceship_repair-order_slot_name-label", order.index}, style = "muppet_padded_table_cell"}, false)
        GuiUtil.AddElement({parent = table, name = "order_status_" .. order.index, type = "label", caption = {"gui-caption.wills_spaceship_repair-order_status-label", order.status1, order.status2}, style = "muppet_padded_table_cell"}, false)
        local orderTime = GuiUtil.AddElement({parent = table, name = "order_time" .. order.index, type = "label", caption = {"gui-caption.wills_spaceship_repair-order_time-label", order.timeValue}, style = "muppet_padded_table_cell"}, false)
        orderTime.style.font_color = order.timeColor
    end
end

function Gui.CalculateOrderSlotTableValues()
    local tableValues = {}
    for _, order in pairs(global.orderSlots) do
        local orderStatusTexts = Orders.GetOrderGuiState(order.index)
        local orderTimeTexts = Orders.GetOrderGuiTime(order.index)
        tableValues[order.index] = {index = order.index, status1 = orderStatusTexts[1], status2 = orderStatusTexts[2], timeValue = orderTimeTexts[1], timeColor = orderTimeTexts[2]}
    end
    return tableValues
end

return Gui

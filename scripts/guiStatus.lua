local GuiStatus = {}
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
local Utils = require("utility/utils")
--local Logging = require("utility/logging")

function GuiStatus.OnStartup()
    Events.ScheduleEvent(60, "GuiStatus.OnSecondUpdate")
end

function GuiStatus.OnLoad()
    Events.RegisterScheduledEventType("GuiStatus.OnSecondUpdate", GuiStatus.OnSecondUpdate)
    Events.RegisterScheduledEventType("GuiStatus.OnSecondUpdate", GuiStatus.OnSecondUpdate)
end

function GuiStatus.OnSecondUpdate(event)
    Events.ScheduleEvent(event.tick + 60, "GuiStatus.OnSecondUpdate")
    GuiStatus.RefreshStatusAll()
end

function GuiStatus.CreateStatusGui(player)
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

    GuiStatus.RefreshStatusPlayer(player)
end

function GuiStatus.RefreshStatusPlayer(player)
    local guiValues = GuiStatus.CalculateStatusElementValues()
    GuiStatus.UpdateStatusElements(player, guiValues)
end

function GuiStatus.RefreshStatusAll()
    local guiValues = GuiStatus.CalculateStatusElementValues()
    for _, player in ipairs(game.connected_players) do
        GuiStatus.UpdateStatusElements(player, guiValues)
    end
end

function GuiStatus.CalculateStatusElementValues()
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

function GuiStatus.UpdateStatusElements(player, guiValues)
    local playerIndex = player.index
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "total_debt_value", "label", {caption = guiValues.totalDebt})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "bankruptcy_limit_value", "label", {caption = guiValues.bankruptcyLimit})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "dividends_value", "label", {caption = {"self", guiValues.dividendsPaid, guiValues.dividendsTotal}})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "wages_value", "label", {caption = {"self", guiValues.wagesPaid, guiValues.wagesTotal}})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "workforce_recruited_value", "label", {caption = {"self", guiValues.currentWorkforce, guiValues.maxWorkforce}})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "game_time_value", "label", {caption = guiValues.gameTime})
    GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, "profit_value", "label", {caption = {"self", guiValues.profitMade, guiValues.profitTarget}})
end

return GuiStatus

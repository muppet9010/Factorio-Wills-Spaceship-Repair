local GuiInvestments = {}
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
--local Logging = require("utility/logging")
local Utils = require("utility/utils")

function GuiInvestments.OnLoad()
    Events.RegisterHandler(defines.events.on_lua_shortcut, "GuiInvestments", GuiInvestments.OnLuaShortcut)
    Events.RegisterHandler(defines.events.on_gui_click, "GuiInvestments", GuiInvestments.OnGuiClick)
end

function GuiInvestments.OnLuaShortcut(event)
    local shortcutName = event.prototype_name
    if shortcutName ~= "wills_spaceship_repair-investments_gui_button" then
        return
    end
    local player = game.get_player(event.player_index)
    GuiInvestments.ToggleInvestmentsGui(player)
end

function GuiInvestments.ToggleInvestmentsGui(player)
    if GuiUtil.GetElementFromPlayersReferenceStorage(player.index, "GuiInvestments", "investment", "frame") ~= nil then
        GuiInvestments.DestroyInvestmentsGui(player)
    else
        GuiInvestments.CreateInvestmentsGui(player)
    end
end

function GuiInvestments.DestroyInvestmentsGui(player)
    GuiUtil.DestroyPlayersReferenceStorage(player.index, "GuiInvestments")
end

function GuiInvestments.CreateInvestmentsGui(player)
    local investmentFrame = GuiUtil.AddElement({parent = player.gui.center, name = "investment", type = "frame", direction = "vertical", style = "muppet_padded_frame"}, "GuiInvestments")
    investmentFrame.style.minimal_width = 600
    investmentFrame.style.maximal_width = 1400
    investmentFrame.style.minimal_height = 400
    investmentFrame.style.maximal_height = 800

    local titleBar = GuiUtil.AddElement({parent = investmentFrame, name = "investment_title_bar", type = "flow", direction = "horizontal"})
    GuiUtil.AddElement({parent = titleBar, name = "investment_title", type = "label", style = "muppet_large_bold_heading", caption = "self"})
    local titleBarRightSide = GuiUtil.AddElement({parent = titleBar, name = "investment_title_bar_right", type = "flow"})
    titleBarRightSide.style.horizontally_stretchable = true
    titleBarRightSide.style.horizontal_align = "right"
    local closeButton = GuiUtil.AddElement({parent = titleBarRightSide, name = "investment_close_button", type = "sprite-button", sprite = "utility/close_white"})
    closeButton.style.height = 20
    closeButton.style.width = 20

    local investmentStatusTable = GuiUtil.AddElement({parent = investmentFrame, name = "investment_status", type = "table", column_count = 2, style = "muppet_padded_table"})
    GuiUtil.AddElement({parent = investmentStatusTable, name = "investment_game_time", type = "label", style = "muppet_bold_text", caption = {"self"}})
    GuiUtil.AddElement({parent = investmentStatusTable, name = "investment_game_time_value", type = "label", style = "muppet_bold_text", caption = Utils.DisplayTimeOfTicks(game.tick, "hour", "minute")})
    GuiUtil.AddElement({parent = investmentStatusTable, name = "investment_repayment_rate", type = "label", style = "muppet_bold_text", caption = {"self"}})
    local repaymentRate = Utils.RoundNumberToDecimalPlaces(global.Investments.dividendsmultiplier / global.Investments.cashmultiplier, 2)
    GuiUtil.AddElement({parent = investmentStatusTable, name = "investment_repayment_rate_value", type = "label", style = "muppet_bold_text", caption = Utils.DisplayNumberPretty(repaymentRate * 100) .. "%"})

    GuiUtil.AddElement({parent = investmentStatusTable, name = "investment_mature_time", type = "label", style = "muppet_bold_text", caption = {"self"}})
    GuiUtil.AddElement({parent = investmentStatusTable, name = "investment_mature_time_value", type = "label", style = "muppet_bold_text", caption = Utils.DisplayTimeOfTicks(global.Investments.maturityTicks, "hour", "minute")})

    GuiUtil.AddElement({parent = investmentStatusTable, name = "investment_matured_interest_rate", type = "label", style = "muppet_bold_text", caption = {"self"}})
    GuiUtil.AddElement({parent = investmentStatusTable, name = "investment_matured_interest_rate_value", type = "label", style = "muppet_bold_text", caption = Utils.DisplayNumberPretty(global.Investments.hourlyInterestRate * 100) .. "%"})

    local investmentScroll = GuiUtil.AddElement({parent = investmentFrame, name = "investment", type = "scroll-pane", horizontal_scroll_policy = "never", vertical_scroll_policy = "auto"})
    local investmentTable = GuiUtil.AddElement({parent = investmentScroll, name = "investment", type = "table", column_count = 6, draw_horizontal_lines = false, draw_vertical_lines = false, draw_horizontal_line_after_headers = true, style = "muppet_padded_table_and_cell"})
    investmentTable.style.left_cell_padding = 20
    investmentTable.style.right_cell_padding = 20
    GuiUtil.AddElement({parent = investmentTable, name = "investments_investor_column_title", type = "label", caption = "self", style = "muppet_medium_bold_heading"})
    GuiUtil.AddElement({parent = investmentTable, name = "investments_invested_column_title", type = "label", caption = "self", style = "muppet_medium_bold_heading"})
    GuiUtil.AddElement({parent = investmentTable, name = "investments_invested_time_column_title", type = "label", caption = "self", style = "muppet_medium_bold_heading"})
    GuiUtil.AddElement({parent = investmentTable, name = "investments_interest_acquired_column_title", type = "label", caption = "self", style = "muppet_medium_bold_heading"})
    GuiUtil.AddElement({parent = investmentTable, name = "investments_payment_made_column_title", type = "label", caption = "self", style = "muppet_medium_bold_heading"})
    GuiUtil.AddElement({parent = investmentTable, name = "investments_outstanding_debt_column_title", type = "label", caption = "self", style = "muppet_medium_bold_heading"})
    for _, investment in pairs(global.Investments.investmentsTable) do
        local color
        if investment.owed == 0 then
            color = {r = 0, g = 255, b = 0, a = 255}
        elseif investment.interestAcquired == 0 then
            color = {r = 255, g = 255, b = 0, a = 255}
        else
            color = {r = 255, g = 0, b = 0, a = 255}
        end
        local investorName = GuiUtil.AddElement({parent = investmentTable, name = "investments_investor_" .. investment.index, type = "label", caption = investment.investorName, style = "muppet_semibold_text"})
        investorName.style.font_color = color
        local investmentAmount = GuiUtil.AddElement({parent = investmentTable, name = "investments_invested_" .. investment.index, type = "label", caption = Utils.DisplayNumberPretty(investment.investmentAmount) .. " [img=item/coin]", style = "muppet_semibold_text"})
        investmentAmount.style.font_color = color
        local investmentTime = GuiUtil.AddElement({parent = investmentTable, name = "investments_invested_time_" .. investment.index, type = "label", caption = Utils.DisplayTimeOfTicks(investment.investmentTick, "hour", "minute"), style = "muppet_semibold_text"})
        investmentTime.style.font_color = color
        local interestAcquired = GuiUtil.AddElement({parent = investmentTable, name = "investments_interest_acquired_" .. investment.index, type = "label", caption = Utils.DisplayNumberPretty(math.floor(investment.interestAcquired)) .. " [img=item/coin]", style = "muppet_semibold_text"})
        interestAcquired.style.font_color = color
        local paid = GuiUtil.AddElement({parent = investmentTable, name = "investments_payment_made_" .. investment.index, type = "label", caption = Utils.DisplayNumberPretty(math.floor(investment.paid)) .. " [img=item/coin]", style = "muppet_semibold_text"})
        paid.style.font_color = color
        local debt = GuiUtil.AddElement({parent = investmentTable, name = "investments_outstanding_debt" .. investment.index, type = "label", caption = Utils.DisplayNumberPretty(math.floor(investment.owed)) .. " [img=item/coin]", style = "muppet_semibold_text"})
        debt.style.font_color = color
    end
end

function GuiInvestments.OnGuiClick(event)
    local elmName = event.element.name
    if elmName == GuiUtil.GenerateName("investment_close_button", "sprite-button") then
        GuiInvestments.DestroyInvestmentsGui(game.get_player(event.player_index))
    end
end

return GuiInvestments

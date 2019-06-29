local GuiInvestments = {}
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
--local Logging = require("utility/logging")

function GuiInvestments.OnLoad()
    Events.RegisterHandler(defines.events.on_lua_shortcut, "GuiInvestments", GuiInvestments.OnLuaShortcut)
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
    investmentFrame.style.maximal_width = 1400
    investmentFrame.style.maximal_height = 800
    GuiUtil.AddElement({parent = investmentFrame, name = "investment_title", type = "label", style = "muppet_large_bold_text", caption = "self"})
end

return GuiInvestments

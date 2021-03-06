local Gui = {}
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
--local Logging = require("utility/logging")
local GuiStatus = require("scripts/gui-status")
local GuiOrders = require("scripts/gui-orders")
local GuiInvestments = require("scripts/gui-investments")

function Gui.CreateGlobals()
    GuiOrders.CreateGlobals()
    GuiStatus.CreateGlobals()
end

function Gui.OnStartup()
    GuiStatus.OnStartup()
    Gui.GuiRecreateAll()
end

function Gui.OnLoad()
    Events.RegisterHandler(defines.events.on_player_joined_game, "Gui", Gui.OnPlayerJoinedGame)
    GuiStatus.OnLoad()
    GuiOrders.OnLoad()
    GuiInvestments.OnLoad()
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
    GuiUtil.AddElement({parent = player.gui.left, name = "gui", type = "flow", style = "muppet_padded_vertical_flow", direction = "vertical"}, "Gui")
    GuiStatus.CreateStatusGui(player)
    GuiOrders.CreateOrderGui(player)
end

function Gui.DestroyAllGuis(player)
    GuiUtil.DestroyPlayersReferenceStorage(player.index)
end

return Gui

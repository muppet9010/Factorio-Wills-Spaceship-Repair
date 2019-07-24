local OrderAudit, SlotStates = {}
local Commands = require("utility/commands")
local Constants = require("constants")
local Utils = require("utility/utils")
local Events = require("utility/events")

function OrderAudit.CreateGlobals()
    global.Orders.orderAuditTable = global.Orders.orderAuditTable or {}
end

function OrderAudit.OnLoad()
    SlotStates = global.StaticData.Orders.slotStates
    Commands.Register("wills_spaceship_repair-write_order_data", {"api-description.wills_spaceship_repair-write_order_data"}, OrderAudit.WriteOutTableCommand, false)
    Events.RegisterHandler("Orders.OrderSlotUpdated", "OrderAudit.LogOrder", OrderAudit.LogOrder)
end

function OrderAudit.LogOrder(event)
    local order = event.order
    if order.orderId == nil then
        return
    end
    if global.Orders.orderAuditTable[order.orderId] == nil then
        global.Orders.orderAuditTable[order.orderId] = {
            orderId = order.orderId,
            orderSlot = order.index,
            item = order.item,
            itemCountNeeded = order.itemCountNeeded,
            itemCountDone = 0,
            startTime = order.startTime,
            endedTime = "",
            stateName = order.stateName
        }
    elseif order.stateName == SlotStates.waitingItem.name then
        local auditOrder = global.Orders.orderAuditTable[order.orderId]
        auditOrder.itemCountDone = order.itemCountDone
    elseif order.stateName == SlotStates.orderFailed.name or order.stateName == SlotStates.waitingCustomerDepart.name then
        local auditOrder = global.Orders.orderAuditTable[order.orderId]
        auditOrder.itemCountDone = order.itemCountDone
        auditOrder.endedTime = order.startTime
        auditOrder.stateName = order.stateName
    end
end

function OrderAudit.WriteOutTableCommand(commandData)
    local player = game.get_player(commandData.player_index)
    game.write_file(Constants.ModName .. "-all_orders_table.json", Utils.TableContentsToJSON(global.Orders.orderAuditTable), false, player.index)
    player.print({"message.wills_spaceship_repair-order_audit_table_written"})
end

return OrderAudit

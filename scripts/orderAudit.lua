local OrderAudit = {}
local Orders = {}
local Commands = require("utility/commands")
local Constants = require("constants")
local Utils = require("utility/utils")

function OrderAudit.OnStartup()
    global.Orders.orderAuditTable = global.Orders.orderAuditTable or {}
    global.Orders.orderAuditMap = global.Orders.orderAuditMap or {}
end

function OrderAudit.OnLoad(slotStates)
    Orders.slotStates = slotStates
    Commands.Register("wills_spaceship_repair-write_order_data", {"api-description.wills_spaceship_repair-write_order_data"}, OrderAudit.WriteOutTableCommand, false)
end

function OrderAudit.LogNewOrder(order)
    local auditIndex = #global.Orders.orderAuditTable + 1
    global.Orders.orderAuditTable[auditIndex] = {
        orderSlot = order.index,
        auditIndex = auditIndex,
        item = order.item,
        itemCountNeeded = order.itemCountNeeded,
        startTime = order.startTime,
        stateName = order.stateName
    }
    global.Orders.orderAuditMap[order.index] = auditIndex
end

function OrderAudit.LogUpdateOrder(order)
    if order.stateName == Orders.slotStates.orderFailed.name or order.stateName == Orders.slotStates.waitingCustomerDepart.name then
        local auditIndex = global.Orders.orderAuditMap[order.index]
        local auditOrder = global.Orders.orderAuditTable[auditIndex]
        auditOrder.endedTime = order.startTime
        auditOrder.stateName = order.stateName
        global.Orders.orderAuditMap[order.index] = nil
    end
end

function OrderAudit.WriteOutTableCommand(commandData)
    game.write_file(Constants.ModName .. "-order_audit_table.json", Utils.TableContentsToJSON(global.Orders.orderAuditTable), false, commandData.player_index)
    game.print({"message.wills_spaceship_repair-order_audit_table_written", game.get_player(commandData.player_index).name})
end

return OrderAudit

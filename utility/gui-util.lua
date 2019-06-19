local GUI = {}
local Constants = require("constants")

GUI.GenerateName = function(name, type)
    return Constants.ModName .. "-" .. name .. "-" .. type
end

GUI._ReplaceSelfWithGeneratedName = function(arguments, argName)
    local arg = arguments[argName]
    if arg == nil then
        arg = nil
    elseif arg == "self" then
        arg = {"gui-" .. argName .. "." .. arguments.name}
    elseif type(arg) == "table" and arg[1] ~= nil and arg[1] == "self" then
        arg[1] = "gui-" .. argName .. "." .. arguments.name
    end
    return arg
end

GUI.AddElement = function(arguments, store)
    --pass self as the caption/tooltip value or localised string name and it will be set to its GenerateName() under gui-caption/gui-tooltip
    arguments.name = GUI.GenerateName(arguments.name, arguments.type)
    arguments.caption = GUI._ReplaceSelfWithGeneratedName(arguments, "caption")
    arguments.tooltip = GUI._ReplaceSelfWithGeneratedName(arguments, "tooltip")
    local element = arguments.parent.add(arguments)
    if store ~= nil and store == true then
        GUI.AddElementToPlayersReferenceStorage(element.player_index, arguments.name, element)
    end
    return element
end

GUI.CreateAllPlayersElementReferenceStorage = function()
    global.GUIUtilPlayerElementReferenceStorage = global.GUIUtilPlayerElementReferenceStorage or {}
end

GUI.CreatePlayersElementReferenceStorage = function(playerIndex)
    global.GUIUtilPlayerElementReferenceStorage[playerIndex] = global.GUIUtilPlayerElementReferenceStorage[playerIndex] or {}
end

GUI.AddElementToPlayersReferenceStorage = function(playernIndex, fullName, element)
    global.GUIUtilPlayerElementReferenceStorage[playernIndex][fullName] = element
end

GUI.GetElementFromPlayersReferenceStorage = function(playernIndex, name, type)
    return global.GUIUtilPlayerElementReferenceStorage[playernIndex][GUI.GenerateName(name, type)]
end

GUI.UpdateElementFromPlayersReferenceStorage = function(playernIndex, name, type, arguments)
    local element = GUI.GetElementFromPlayersReferenceStorage(playernIndex, name, type)
    local generatedName = GUI.GenerateName(name, type)
    for argName, argValue in pairs(arguments) do
        if argName == "caption" or argName == "tooltip" then
            argValue = GUI._ReplaceSelfWithGeneratedName({name = generatedName, [argName] = argValue}, argName)
        end
        element[argName] = argValue
    end
end

GUI.DestroyElementInPlayersReferenceStorage = function(playerIndex, name, type)
    local elementName = GUI.GenerateName(name, type)
    if global.GUIUtilPlayerElementReferenceStorage[playerIndex] ~= nil and global.GUIUtilPlayerElementReferenceStorage[playerIndex][elementName] ~= nil then
        if global.GUIUtilPlayerElementReferenceStorage[playerIndex][elementName].valid then
            global.GUIUtilPlayerElementReferenceStorage[playerIndex][elementName].destroy()
        end
        global.GUIUtilPlayerElementReferenceStorage[playerIndex][elementName] = nil
    end
end

GUI.DestroyPlayersReferenceStorage = function(playernIndex)
    if global.GUIUtilPlayerElementReferenceStorage[playernIndex] == nil then
        return
    end
    for _, element in pairs(global.GUIUtilPlayerElementReferenceStorage[playernIndex]) do
        if element.valid then
            element.destroy()
        end
    end
    global.GUIUtilPlayerElementReferenceStorage[playernIndex] = nil
end

return GUI

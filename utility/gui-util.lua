local GuiUtil = {}
local Constants = require("constants")

GuiUtil.GenerateName = function(name, type)
    return Constants.ModName .. "-" .. name .. "-" .. type
end

GuiUtil._ReplaceSelfWithGeneratedName = function(arguments, argName)
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

GuiUtil.AddElement = function(arguments, store)
    --pass self as the caption/tooltip value or localised string name and it will be set to its GenerateName() under gui-caption/gui-tooltip
    arguments.name = GuiUtil.GenerateName(arguments.name, arguments.type)
    arguments.caption = GuiUtil._ReplaceSelfWithGeneratedName(arguments, "caption")
    arguments.tooltip = GuiUtil._ReplaceSelfWithGeneratedName(arguments, "tooltip")
    local element = arguments.parent.add(arguments)
    if store ~= nil and store == true then
        GuiUtil.AddElementToPlayersReferenceStorage(element.player_index, arguments.name, element)
    end
    return element
end

GuiUtil.CreateAllPlayersElementReferenceStorage = function()
    global.GUIUtilPlayerElementReferenceStorage = global.GUIUtilPlayerElementReferenceStorage or {}
end

GuiUtil.CreatePlayersElementReferenceStorage = function(playerIndex)
    global.GUIUtilPlayerElementReferenceStorage[playerIndex] = global.GUIUtilPlayerElementReferenceStorage[playerIndex] or {}
end

GuiUtil.AddElementToPlayersReferenceStorage = function(playernIndex, fullName, element)
    global.GUIUtilPlayerElementReferenceStorage[playernIndex][fullName] = element
end

GuiUtil.GetElementFromPlayersReferenceStorage = function(playernIndex, name, type)
    return global.GUIUtilPlayerElementReferenceStorage[playernIndex][GuiUtil.GenerateName(name, type)]
end

GuiUtil.UpdateElementFromPlayersReferenceStorage = function(playernIndex, name, type, arguments)
    local element = GuiUtil.GetElementFromPlayersReferenceStorage(playernIndex, name, type)
    local generatedName = GuiUtil.GenerateName(name, type)
    for argName, argValue in pairs(arguments) do
        if argName == "caption" or argName == "tooltip" then
            argValue = GuiUtil._ReplaceSelfWithGeneratedName({name = generatedName, [argName] = argValue}, argName)
        end
        element[argName] = argValue
    end
end

GuiUtil.DestroyElementInPlayersReferenceStorage = function(playerIndex, name, type)
    local elementName = GuiUtil.GenerateName(name, type)
    if global.GUIUtilPlayerElementReferenceStorage[playerIndex] ~= nil and global.GUIUtilPlayerElementReferenceStorage[playerIndex][elementName] ~= nil then
        if global.GUIUtilPlayerElementReferenceStorage[playerIndex][elementName].valid then
            global.GUIUtilPlayerElementReferenceStorage[playerIndex][elementName].destroy()
        end
        global.GUIUtilPlayerElementReferenceStorage[playerIndex][elementName] = nil
    end
end

GuiUtil.DestroyPlayersReferenceStorage = function(playernIndex)
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

return GuiUtil

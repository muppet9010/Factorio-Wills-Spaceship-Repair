local Constants = {}

Constants.ModName = "wills_spaceship_repair"
Constants.AssetModName = "__" .. Constants.ModName .. "__"
Constants.LogFileName = Constants.ModName .. "_logOutput.txt"

Constants.Colors = {
    white = {r = 255, g = 255, b = 255, a = 255},
    red = {r = 255, g = 50, b = 50, a = 255},
    yellow = {r = 255, g = 255, b = 0, a = 255},
    orange = {r = 255, g = 130, b = 0, a = 255},
    green = {r = 0, g = 255, b = 0, a = 255}
}

return Constants

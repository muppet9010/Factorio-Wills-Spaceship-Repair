# Factorio-Wills-Spaceship-Repair
Will runs a spaceship repair business


A spaceship repair business where you need to launch expensive spaceship parts to space for customer orders. Aim is to make some profit before you go bankrupt with debt. Investors (viewers) make investments giving you some cash to spend in a market to make life easier, but require a large return on their investment after many hours. Their investment accures interest after the payback period.
Delivering spaceship parts in to space requires an available dry dock to be in space and for an order to be decrypted (researched). If the order is fulfilled witihn the time limit a time bonus/penalty payment will be made in coins to the silo. These coins can be spent in the market or processed in to coin shipment capsules and sent off via rocket to the bank.
Rocket silos and coin handling machines are infrequently randomly placed across the map and can not be manually made. Rocket silos are stage 1 of the Rocket Silo Construction mod and can not be mined. If destroyed they return to stage 1 and must be rebuilt. The coin machines will be randomly selected with a ratio of 3 wooden coin chest to 1 iron coin chest. A rocket silos and coin chest will be somewhere within a 2,500 tile sqaure region with the corners of the 4 starting regions at spawn (0,0).
Supporting workforce (above first player) has to be researched and then paid an hourly wage when they are on shift.
All high tech personal equipment must be brought through the market which is at spawn area.
Instant cash will either appear in the passive provider chest near spawn or via delivery pod if the Item Delivery Pod mod is enabled.

Designed for play in multiplayer as a streamer with viewers acting as investors.


Commands
------

- wills_spaceship_repair-add_investment = Add a new Investment using the command arguments: "Player Name" InvestmentAmount
- wills_spaceship_repair-write_order_data = Writes out details of all orders to the that players script-output folder.
- wills_spaceship_repair-write_investment_data = Writes out details of investments to the that players script-output folder.


Settings (Advanced)
-------

- Item delivery pod size cash values = When the optional mod Item Delivery Pod is being used the size of the delivery pod for instant cash is defined by this setting. It is a JSON table of the coinCost, shipSize, radius. The coin cost is the minimum value for the ship size. The shipSizes are, tiny, small, medium, large, modular. The radius is how close to the Primary Player the item delivery pod will randomly fall within. An extra entry for shipSize 'modular-part' is also required which controls how quickly the modular item delivery pod size grows. Default value showing data structure:
'[ {"coinCost":0, "shipSize":"tiny", "radius":150}, {"coinCost":500, "shipSize":"small", "radius":100}, {"coinCost":1000, "shipSize":"medium", "radius":75}, {"coinCost":2500, "shipSize":"large", "radius":50}, {"coinCost":3000, "shipSize":"modular", "radius":50}, {"coinCost":500, "shipSize":"modular-part"} ]'


Credits
-----
Many graphics and recipes copied/inspired from Space Extension Mod (SpaceX) under its MIT licence.
Colored assembling machine graphics from Bobs Assembling Machines with permission.


Usage & Testing Notes
------
The mod may not test correctly with Creative Mode and this mod isn't supported.
Don't use with an island map.
Must be used with a new game, won't add to an existing save.
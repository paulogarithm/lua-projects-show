--!strict

-- local Players = game:GetService("Players")
local Mplayer = require("./player")
local Items = require("./items")
local Crafting = require("./crafting")

local craftingTable = Crafting.new(3)
local player = Mplayer.new({})

craftingTable:Connect(player)

player:Give(Items("oak_planks"), 7)
print(player.Inventory)

craftingTable:Push(Items("oak_planks"), 1, 1).Repeat(2)
craftingTable:Push(Items("oak_planks"), 1, 2).Repeat(2)
print(craftingTable)
craftingTable:CraftMax()
print(player.Inventory)
print(craftingTable)

craftingTable:Push(Items("oak_planks"), 1, 1)
craftingTable:Push(Items("oak_planks"), 2, 1)
craftingTable:Push(Items("oak_planks"), 3, 1)
craftingTable:Push(Items("stick"), 2, 2)
craftingTable:Push(Items("stick"), 2, 3)
print(craftingTable)
craftingTable:Craft()
print(craftingTable)
print(player.Inventory)

craftingTable:Disconnect()

Inventory = {}

function Inventory:constructor()
    self.cache = {}
    self.db = false
    return self:setup()
end

function Inventory:setup()
    self.config = getConfig()

    self.db = dbConnect("sqlite", "assets/database/database.db")
    if not self.db then 
        return outputDebugString(resourceName.." - failed to connect database.", 4, 255, 0, 0)
    end

    self:loadAll()
    return outputDebugString(resourceName.." - resource loaded successfully.", 4, 134, 239, 172)
end

--// Global functions

function loadPlayer(player)
    return Inventory:load(player)
end

function getPlayerItem(player, itemID)
    return Inventory:giveItem(player, itemID)
end

function givePlayerItem(player, itemID, amount)
    return Inventory:giveItem(player, itemID, amount)
end

function takePlayerItem(player, itemID, amount, slot)
    return Inventory:takeItem(player, itemID, amount, slot)
end

function getAccountInventory(account)
    return Inventory:get(account)
end

--// Custom events

addEvent("inventory:buySlot", true)
addEventHandler("inventory:buySlot", resourceRoot, function()
    return Inventory:buySlot(client)
end)

addEvent("inventory:changeSlot", true)
addEventHandler("inventory:changeSlot", resourceRoot, function(old, new)
    return Inventory:changeSlot(client, old, new)
end)

addEvent("inventory:setAction", true)
addEventHandler("inventory:setAction", resourceRoot, function(itemSlot, slot)
    return Inventory:setAction(client, itemSlot, slot)
end)

--// Mta events

addEventHandler("onResourceStart", resourceRoot, function()
    return Inventory:constructor()
end)

addEventHandler("onPlayerLogin", root, function()
    return Inventory:load(source)
end)
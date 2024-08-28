function Inventory:getFreeSlot(cache)
    for i = 1, cache.slot do
        if not cache.items[i] then 
            return i
        end 
    end
    return false
end

function Inventory:getSlotFromID(cache, id)
    for i = 1, cache.slot do
        local item = cache.items[i]
        if item and item.id == id then 
            return i 
        end
    end
    return false
end

function Inventory:giveItem(player, itemID, amount)
    itemID = tonumber(itemID)
    if not itemID or itemID <= 0 then
        return false 
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false 
    end

    local itemConfig = self.config.items[itemID]
    if not itemConfig then 
        return false 
    end

    local playerAccountName = self.config.server.getPlayerAccountName(player)
    if not playerAccountName then
        return false 
    end

    local playerCache = self:get(playerAccountName)
    if not playerCache then 
        return false 
    end

    local itemSlot = self:getSlotFromID(playerCache, itemID)
    if itemSlot and itemConfig.stack then 
        playerCache.items[itemSlot].amount = playerCache.items[itemSlot].amount + amount
        return self:update(player, playerAccountName, playerCache)
    end

    if playerCache.length >= playerCache.slot then
        return false 
    end

    local slot = self:getFreeSlot(playerCache)
    playerCache.length = playerCache.length + 1
    playerCache.items[slot] = { id = itemID, amount = amount }
    return self:update(player, playerAccountName, playerCache)
end

function Inventory:takeItem(player, itemID, amount, slot)
    itemID = tonumber(itemID)
    if not itemID or itemID <= 0 then
        return false 
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false 
    end

    local itemConfig = self.config.items[itemID]
    if not itemConfig then 
        return false 
    end

    local playerAccountName = self.config.server.getPlayerAccountName(player)
    if not playerAccountName then
        return false 
    end

    local playerCache = self:get(playerAccountName)
    if not playerCache then 
        return false 
    end

    local itemSlot = slot and slot or self:getSlotFromID(playerCache, itemID)
    if not itemSlot then 
        return false 
    end

    local item = playerCache.items[itemSlot]
    if not item then 
        return false 
    end
    
    if item.amount - amount <= 0 then 
        if item.action and playerCache.action[item.action] then 
            playerCache.action[item.action] = nil
        end

        playerCache.items[itemSlot] = nil
        playerCache.length = playerCache.length - 1
        return self:update(player, playerAccountName, playerCache)
    end

    item.amount = item.amount - amount
    return self:update(player, playerAccountName, playerCache)
end

function Inventory:setAction(player, itemSlot, actionSlot)
    itemSlot = tonumber(itemSlot)
    if not itemSlot or itemSlot < 0 then 
        return false 
    end

    actionSlot = tonumber(actionSlot)
    if not actionSlot or actionSlot < 0 then
        return false 
    end

    local playerAccountName = self.config.server.getPlayerAccountName(player)
    if not playerAccountName then
        return false 
    end

    local playerCache = self:get(playerAccountName)
    if not playerCache then 
        return false 
    end

    local action = playerCache.action[actionSlot]
    if action then 
        local item = playerCache.items[action.slot]
        if not item then
            return false
        end

        item.action = nil
        playerCache.action[actionSlot] = nil
        return self:update(player, playerAccountName, playerCache)
    end

    local item = playerCache.items[itemSlot]
    if not item then
        return false 
    end

    item.action = actionSlot
    playerCache.action[actionSlot] = { id = item.id, slot = itemSlot }
    return self:update(player, playerAccountName, playerCache)
end

function Inventory:changeSlot(player, old, new)
    old = tonumber(old)
    if not old or old <= 0 then 
        return false 
    end

    new = tonumber(new)
    if not new or new <= 0 then
        return false 
    end

    local playerAccountName = self.config.server.getPlayerAccountName(player)
    if not playerAccountName then
        return false 
    end

    local playerCache = self:get(playerAccountName)
    if not playerCache then 
        return false 
    end

    local item = playerCache.items[old]
    if not item then 
        return false 
    end

    if item.action and playerCache.action[item.action] then 
        playerCache.action[item.action].slot = new
    end

    playerCache.items[old] = nil

    local itemInNewSlot = playerCache.items[new]
    if itemInNewSlot then 
        if itemInNewSlot.action and playerCache.action[itemInNewSlot.action] then 
            playerCache.action[itemInNewSlot.action].slot = old
        end

        playerCache.items[old] = itemInNewSlot
    end

    playerCache.items[new] = item
    return self:update(player, playerAccountName, playerCache)
end

function Inventory:buySlot(player)
    local playerAccountName = self.config.server.getPlayerAccountName(player)
    if not playerAccountName then
        return false 
    end

    local playerCache = self:get(playerAccountName)
    if not playerCache then 
        return false 
    end

    local playerBalance = self.config.server.getPlayerBalance(player)
    if playerBalance < self.config.default.price then
        return self.config.server.notify(player, "Você não possui dinheiro suficiente para adquirir esse slot", "error")
    end

    if not self.config.server.takePlayerBalance(player, self.config.default.price) then 
        return self.config.server.notify(player, "Não foi possível adquirir esse slot, tente novamente ou contate um administrador.", "error")
    end

    playerCache.slot = playerCache.slot + self.config.default.buy
    return self:update(player, playerAccountName, playerCache)
end
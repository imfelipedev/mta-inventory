function Inventory:get(account)
    if not self.cache[account] then 
        self.cache[account] = { 
            length = 0, 
            weight = 0, 
            items = {},
            action = {},
            slot = self.config.default.slot
        }
        dbExec(self.db, "INSERT INTO `inventory`(`account`, `slot`, `items`) VALUES(?, ?, ?)", account, self.config.default.slot, "[[]]")
    end
    return self.cache[account]
end

function Inventory:load(player)
    local playerAccountName = self.config.server.getPlayerAccountName(player)
    if not playerAccountName then
        return false 
    end

    local playerCache = self:get(playerAccountName)
    if not playerCache then 
        return false 
    end

    triggerClientEvent(player, "inventory:update", resourceRoot, { type = "cache", cache = playerCache })
end

function Inventory:update(player, account, cache)
    if not account then 
        return false 
    end

    if not cache then 
        return false 
    end

    local items = toJSON(cache.items)
    triggerClientEvent(player, "inventory:update", resourceRoot, { type = "cache", cache = cache })
    dbExec(self.db, "UPDATE `inventory` SET `items` = ?, `slot` = ? WHERE `account` = ?", items, cache.slot, account)
end

function Inventory:loadAll()
    dbExec(self.db, [[
        CREATE TABLE IF NOT EXISTS `inventory` (
            `id` INTEGER PRIMARY KEY AUTOINCREMENT, 
            `account` VARCHAR(255),
            `slot` INTEGER, 
            `items` JSON
        )
    ]])

    dbQuery(function(qh)
        local result = dbPoll(qh, 0)
        if #result <= 0 then
            return false 
        end

        for _, value in pairs(result) do 
            self.cache[value.account] = {
                length = 0, 
                weight = 0, 
                items = {},
                action = {},
                slot = value.slot
            }

            local items = fromJSON(value.items)
            for index, item in pairs(items) do 
                local slot = tonumber(index)
                if item.action then 
                    self.cache[value.account].action[item.action] = { 
                        id = value.id, 
                        slot = slot 
                    }
                end

                self.cache[value.account].items[slot] = item
            end
        end
    end, self.db, "SELECT * FROM `inventory`")
end
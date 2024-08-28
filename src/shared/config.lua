function getConfig()
    return {

        key = "b",

        default = {
            slot = 20,
            buy = 5,
            price = 1000,
        },

        client = {

            notify = function(message, type)
                return triggerEvent("notify", localPlayer, message, type)
            end,

        },

        server = {

            notify = function(player, message, type)
                return triggerClientEvent(player, "notify", player, message, type)
            end,

            getPlayerAccountName = function(player)
                local playerAccount = getPlayerAccount(player)
                return getAccountName(playerAccount)
            end,

            getPlayerBalance = function(player)
                return getPlayerMoney(player)
            end,

            takePlayerBalance = function(player, amount)
                return takePlayerMoney(player, amount)
            end

        },

        items = {
            
            [1] = {
                name = "Hambuguer",
                lose = true,
                stack = true,
                trade = true,
                weight = 1
            },

            [2] = {
                name = "Coca Cola",
                lose = true,
                stack = true,
                trade = true,
                weight = 1
            },

            [3] = {
                name = "Ak-47",
                lose = true,
                stack = false,
                trade = true,
                weight = 1
            },
            
        }

    }
end
Inventory = {}

function Inventory:constructor()
    self.keys = {}
    self.cache = {}
    self.default = {}
    self.scale = 0
    self.screenW = 0
    self.screenH = 0
    return self:setup()
end

function Inventory:setup()
    self.config = getConfig()

    self.screenW, self.screenH = guiGetScreenSize()

    self.scale = math.max(0.85, self.screenH / 1080)

    self.__render__ = function()
        return self:render()
    end

    self.__toggle__ = function()
        return self:toggle()
    end

    self.__restore__ = function()
        return self:renderTarget()
    end

    self.__key__ = function(key, state)
        return self:key(key, state)
    end

    self.__click__ = function(click, state)
        return self:click(click, state)
    end

    self.cache = {
        weight = 0,
        items = {},
        action = {},
        slot = self.config.default.slot
    }

    self.default = {
        positions = {
            inventory = {
                x = ( self.screenW - ( 410 * self.scale ) ) / 2,
                y = ( self.screenH - ( 490 * self.scale ) ) - 160 * self.scale,
            },
            action = {
                x = ( self.screenW - ( 410 * self.scale ) ) / 2,
                y = ( self.screenH - ( 102 * self.scale ) ) - 30 * self.scale,
            }
        },
        fonts = {
            semibold_16 = dxCreateFont("assets/fonts/poppins-semibold.ttf", 16 * self.scale, true)
        }
    }

    self.keys = {
        ["1"] = {
            slot = 1,
            state = false
        },
        ["2"] = {
            slot = 2,
            state = false
        },
        ["3"] = {
            slot = 3,
            state = false
        },
        ["4"] = {
            slot = 4,
            state = false
        },
        ["5"] = {
            slot = 5,
            state = false
        }
    }

    bindKey(self.config.key, "down", self.__toggle__)
    addEventHandler("onClientKey", root, self.__key__)
    addEventHandler("onClientRender", root, self.__render__)
    return true
end

--// Custom events

addEvent("inventory:update", true)
addEventHandler("inventory:update", resourceRoot, function(data)
    return Inventory:update(data)
end)

--// Mta events

addEventHandler("onClientResourceStart", resourceRoot, function()
    return Inventory:constructor()
end)
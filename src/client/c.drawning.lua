function Inventory:render()
    if not self.interface then 
        return self:renderAction() 
    end

    self.interface.alpha.value = self:lerp(self.interface.alpha.value, self.interface.alpha.target, 0.08)
    if (self.interface.alpha.value < 0.1 and self.interface.alpha.target == 0) then 
        return self:close()
    end

    local isCursorShow = isCursorShowing()
    if isCursorShow then 
        local x, y = getCursorPosition()
        self.interface.cursor = { x = x * self.screenW, y = y * self.screenH }
    end

    self.interface.hover = false

    self:renderAction()

    self:drawImage({ x = self.default.positions.action.x, y = self.default.positions.action.y }, { x = 0, y = 0, w = 410, h = 102 }, "assets/images/inventory/action-bar.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.interface.alpha.value), false)
    
    self:drawImage({ x = self.default.positions.inventory.x, y = self.default.positions.inventory.y }, { x = 0, y = 0, w = 410, h = 490 }, "assets/images/inventory/background.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.interface.alpha.value), false)
    
    self:drawText({ x = self.default.positions.inventory.x, y = self.default.positions.inventory.y }, { x = 45, y = 26, w = 85, h = 12 }, "Inventário", tocolor(255, 255, 255, 255 * self.interface.alpha.value), 1.0, self.interface.fonts.medium_16, "left", "center")
    
    self:drawText({ x = self.default.positions.inventory.x, y = self.default.positions.inventory.y }, { x = 308, y = 26, w = 70, h = 9 }, "01/#D1D1D110kg", tocolor(255, 255, 255, 255 * self.interface.alpha.value), 1.0, self.interface.fonts.medium_12, "right", "center", false, false, false, true)
    
    self:drawImage({ x = self.default.positions.inventory.x, y = self.default.positions.inventory.y }, { x = 15, y = 66, w = 365, h = 404 }, self.interface.target.element, 0, 0, 0, tocolor(255, 255, 255, 255 * self.interface.alpha.value), false)   

    self:drawImage({ x = self.default.positions.inventory.x, y = self.default.positions.inventory.y }, { x = 385, y = 66, w = 15, h = 409 }, "assets/images/inventory/scroll.png", 0, 0, 0, tocolor(39, 39, 39, 255 * self.interface.alpha.value), false)

    local totalSlots = self.cache.slot + 10
    local contentHeight = (75 * self.scale) * math.ceil(totalSlots / 5) - 15 * self.scale
    if contentHeight > 404 * self.scale then 
        local relativeHeight = (404 * self.scale) / contentHeight
        local scrollHeight = relativeHeight * (404 * self.scale)
        local scrollPosition = relativeHeight * self.interface.target.scroll        
        self:drawImage({ x = self.default.positions.inventory.x, y = self.default.positions.inventory.y }, { x = 385, y = 66 + scrollPosition, w = 15, h = scrollHeight }, "assets/images/inventory/scroll.png", 0, 0, 0, tocolor(209, 209, 209, 255 * self.interface.alpha.value), false)
    end

    local hover = self:checkHover()
    if hover ~= self.interface.target.hover then
        self.interface.target.hover = hover
        self:renderTarget()
    end

    if self.interface.move then 
        local x, y = self.interface.cursor.x - 20, self.interface.cursor.y - 20
        self:drawImage({ x = 0, y = 0 }, { x = x, y = y, w = 40, h = 40 }, "assets/images/items/"..self.interface.move.item.id..".png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.interface.alpha.value), true)
    end
    return true
end

function Inventory:renderTarget()
    dxSetRenderTarget(self.interface.target.element, true)
        dxSetBlendMode("add")
            local posX = 0
            local posY = 0
            for i = 1, self.cache.slot + 10 do
                if posY - self.interface.target.scroll < 404 then 
                    local path = "assets/images/inventory/slot.png"
                    if (i > self.cache.slot) then 
                        path = "assets/images/inventory/slot-buy.png"
                    end

                    if self.interface.target.hover and self.interface.target.hover == i then
                        path = "assets/images/inventory/slot-hover.png"
                    end

                    self:drawImage({ x = 0, y = 0 }, { x = posX, y = posY - self.interface.target.scroll, w = 70, h = 70 }, path, 0, 0, 0, tocolor(255, 255, 255, 255), false)
                    
                    local item = self.cache.items[i]
                    if item and (not self.interface.move or self.interface.move.slot ~= i) then
                        self:drawImage({ x = 0, y = 0 }, { x = 15 + posX, y = 15 + posY - self.interface.target.scroll, w = 40, h = 40 }, "assets/images/items/"..item.id..".png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
                    end
                end

                posX = posX + 70 + 5
                if (i % 5 == 0) then 
                    posX = 0
                    posY = posY + 70 + 5
                end
            end

            local buttonColor = tocolor(209, 209, 209, 255)
            if self.interface.target.hover and self.interface.target.hover == "button" then 
                buttonColor = tocolor(209, 209, 209, 200)
            end

            self:drawImage({ x = 0, y = 0 }, { x = 170, y = (posY - 130) - self.interface.target.scroll, w = 30, h = 30 }, "assets/images/inventory/lock.png", 0, 0, 0, tocolor(209, 209, 209, 255), false)
            
            self:drawText({ x = 0, y = 0 }, { x = 0, y = (posY - 90) - self.interface.target.scroll, w = 365, h = 11 }, "Slots bloqueados", tocolor(209, 209, 209, 255), 1.0, self.default.fonts.semibold_16, "center", "center")
            
            self:drawText({ x = 0, y = 0 }, { x = 0, y = (posY - 68) - self.interface.target.scroll, w = 365, h = 9 }, "Serão desbloqueados #ffffff"..self.config.default.buy.." novos slots.", tocolor(209, 209, 209, 255), 1.0, self.interface.fonts.medium_12, "center", "center", false, false, false, true)
        
            self:drawImage({ x = 0, y = 0 }, { x = 110, y = (posY - 52) - self.interface.target.scroll, w = 140, h = 40 }, "assets/images/inventory/button-slot-buy.png", 0, 0, 0, buttonColor, false)
        
            self:drawText({ x = 0, y = 0 }, { x = 0, y = (posY - 52) - self.interface.target.scroll, w = 365, h = 40 }, "Adquirir.", tocolor(0, 0, 0, 255), 1.0, self.interface.fonts.semibold_12, "center", "center")
        dxSetBlendMode("blend")
    dxSetRenderTarget()
end

function Inventory:renderAction()
    local posX = 15
    for i = 1, 5 do
        local path = "assets/images/inventory/slot-action.png"
        if self.keys[""..i].state then 
            path = "assets/images/inventory/slot-action-hover.png"
        end

        if self.interface and self:isMouseInPosition({ x = self.default.positions.action.x, y = self.default.positions.action.y }, { x = posX, y = 15, w = 72, h = 72 }) then 
            path = "assets/images/inventory/slot-action-hover.png"
            self.interface.hover = function(button, state)
                if state ~= "up" then
                    return false 
                end
                
                if button ~= "right" then
                    return false 
                end

                if self.interface.move then
                    triggerServerEvent("inventory:setAction", resourceRoot, self.interface.move.slot, i)
                    self.interface.move = nil
                    return self:renderTarget()
                end

                if not self.cache.action[i] then 
                    return false 
                end

                triggerServerEvent("inventory:setAction", resourceRoot, 0, i)
                return true
            end
        end

        self:drawImage({ x = self.default.positions.action.x, y = self.default.positions.action.y }, { x = posX, y = 15, w = 72, h = 72 }, path, 0, 0, 0, tocolor(255, 255, 255, 255), true)
        
        self:drawText({ x = self.default.positions.action.x, y = self.default.positions.action.y }, { x = posX, y = 15, w = 72, h = 72 }, i, tocolor(255, 255, 255, 255), 1.0, self.default.fonts.semibold_16, "center", "center", false, false, true)

        local action = self.cache.action[i]
        if action then 
            self:drawImage({ x = self.default.positions.action.x, y = self.default.positions.action.y }, { x = posX + 16, y = 30, w = 40, h = 40 }, "assets/images/items/"..action.id..".png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
        end

        posX = posX + 72 + 5
    end
end

function Inventory:checkHover()
    local posX = 20
    local posY = 71
    local hover = false
    for i = 1, self.cache.slot + 10 do
        if i <= self.cache.slot and self:isMouseInPosition({ x = self.default.positions.inventory.x, y = self.default.positions.inventory.y }, { x = posX, y = posY - self.interface.target.scroll, w = 60, h = 60 }) and self:isMouseInPosition({ x = self.default.positions.inventory.x, y = self.default.positions.inventory.y }, { x = 15, y = 66, w = 365, h = 404 }) then
            hover = i
            self.interface.hover = function(button, state)
                if state ~= "down" then 
                    if self.interface.move then
                        triggerServerEvent("inventory:changeSlot", resourceRoot, self.interface.move.slot, i)
                        self.interface.move = nil
                    end
                    return false 
                end

                local item = self.cache.items[i]
                if button == "right" and item then 
                    self.interface.move = { slot = i, item = item }
                    return self:renderTarget()
                end

                if button == "left" and item then
                    return triggerServerEvent("inventory:use", resourceRoot, i) 
                end
                return false
            end
        end

        posX = posX + 70 + 5
        if (i % 5 == 0) then 
            posX = 0
            posY = posY + 70 + 5
        end
    end

    if self:isMouseInPosition({ x = self.default.positions.inventory.x, y = self.default.positions.inventory.y }, { x = 110, y = (posY - 52) - self.interface.target.scroll, w = 140, h = 40 }) then 
        hover = "button"
        self.interface.hover = function(button, state)
            if state ~= "down" then 
                return false 
            end

            if button ~= "left" then 
                return false 
            end

            triggerServerEvent("inventory:buySlot", resourceRoot)
            return true
        end
    end
    return hover
end

function Inventory:click(button, state)
    if self.interface.alpha.target == 0 then
        return false 
    end

    if self.interface.hover then 
        return self.interface.hover(button, state)
    end

    if self.interface.move then
        self.interface.move = nil
        return self:renderTarget()
    end
    return false
end

function Inventory:key(key, state)
    if self.keys[key] then 
        self.keys[key].state = state and true or false
        return true 
    end

    if not self.interface then 
        return false 
    end

    if key == "mouse_wheel_up" and state then 
        self.interface.target.scroll = math.max(0, self.interface.target.scroll - 25)
        return self:renderTarget()
    end

    if key == "mouse_wheel_down" and state then 
        local totalSlots = self.cache.slot + 10
        local contentHeight = (75 * self.scale) * math.ceil(totalSlots / 5) - 10 * self.scale
        self.interface.target.scroll = math.min(contentHeight - (404 * self.scale), self.interface.target.scroll + 25)
        return self:renderTarget()
    end
    return true
end

function Inventory:toggle()
    if self.interface then
        self.interface.alpha.target = 0
        return showCursor(false)
    end
    return self:open()
end

function Inventory:open()
    self.interface = {
        alpha = {
            value = 0,
            target = 1,
        },
        cursor = {
            x = 0,
            y = 0
        },
        target = {
            scroll = 0,
            hover = false,
            element = dxCreateRenderTarget(365 * self.scale, 404 * self.scale, true)
        },
    }

    self:createFonts()
    self:renderTarget()
    showCursor(true)
    addEventHandler("onClientClick", root, self.__click__)
    addEventHandler("onClientRestore", root, self.__restore__)
    return true
end

function Inventory:close()
    if isElement(self.interface.target.element) then 
        destroyElement(self.interface.target.element)
    end

    self:destroyFonts()
    removeEventHandler("onClientClick", root, self.__click__)
    removeEventHandler("onClientRestore", root, self.__restore__)
    self.interface = nil
    return true
end

function Inventory:update(data)
    if data.type == "cache" then 
        self.cache = data.cache
        if self.interface then 
            self:renderTarget()
        end
        return true
    end
    return false
end
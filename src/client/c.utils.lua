function Inventory:lerp(a, b, t)
    return a + (b - a) * t
end

function Inventory:isMouseInPosition(base, position)
    local x, y, w, h = base.x + position.x * self.scale, base.y + position.y * self.scale, position.w * self.scale, position.h * self.scale
    if self.interface.cursor.x >= x and self.interface.cursor.x <= x + w and self.interface.cursor.y >= y and self.interface.cursor.y <= y + h then
        return true
    end
    return false
end

function Inventory:drawImage(base, position, ...)
    dxDrawImage(
        base.x + position.x * self.scale, 
        base.y + position.y * self.scale, 
        position.w * self.scale, 
        position.h * self.scale, 
        ...
    )
    return true
end

function Inventory:drawText(base, position, text, ...)
    dxDrawText(
        text, 
        base.x + position.x * self.scale, 
        base.y + position.y * self.scale, 
        (base.x + position.x * self.scale) + position.w * self.scale, 
        (base.y + position.y * self.scale) + position.h * self.scale, 
        ...
    )
    return true
end

function Inventory:createFonts()
    if not self.interface then 
        return false 
    end

    if not self.interface.fonts then 
        self.interface.fonts = {}
    end

    self.interface.fonts["medium_16"] = dxCreateFont("assets/fonts/poppins-medium.ttf", 16 * self.scale, false)
    self.interface.fonts["medium_12"] = dxCreateFont("assets/fonts/poppins-medium.ttf", 12 * self.scale, false)
    self.interface.fonts["semibold_12"] = dxCreateFont("assets/fonts/poppins-semibold.ttf", 12 * self.scale, true)
    return true
end

function Inventory:destroyFonts()
    if not self.interface then 
        return false 
    end

    if not self.interface.fonts then 
        return false
    end

    for index, value in pairs(self.interface.fonts) do 
        if isElement(value) then 
            destroyElement(value)
        end
    end
    return true
end
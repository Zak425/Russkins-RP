RP = RP or {}
RP.CallMarkers = RP.CallMarkers or {}

net.Receive("RP_SendCallMarker", function()
    local pos = net.ReadVector()
    local msg = net.ReadString()
    local name = net.ReadString()
    
    table.insert(RP.CallMarkers, {
        pos = pos,
        msg = msg,
        name = name,
        expires = CurTime() + 300 -- 5 минут (300 секунд)
    })
end)

local policeIcon = Material("icon16/shield.png")
local medicIcon = Material("icon16/heart.png")

hook.Add("HUDPaint", "RP_DrawCallMarkers", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local isPolice = (ply:Team() == TEAM_POLICE)
    local isMedic = (ply:Team() == TEAM_MEDIC)
    
    if not isPolice and not isMedic then return end

    local ct = CurTime()
    
    for i = #RP.CallMarkers, 1, -1 do
        local marker = RP.CallMarkers[i]
        if ct > marker.expires then
            table.remove(RP.CallMarkers, i)
            continue
        end

        -- Если игрок подошел к метке (ближе чем на 150 юнитов / ~3 метра)
        if ply:GetPos():Distance(marker.pos) < 150 then
            table.remove(RP.CallMarkers, i)
            continue
        end
        
        local screenPos = (marker.pos + Vector(0, 0, 50)):ToScreen()
        if not screenPos.visible then continue end
        
        local dist = math.Round(ply:GetPos():Distance(marker.pos) * 0.01905) -- перевод в метры (примерный)
        
        local icon = isPolice and policeIcon or medicIcon
        local color = isPolice and Color(50, 150, 255) or Color(255, 50, 50)
        
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(icon)
        surface.DrawTexturedRect(screenPos.x - 8, screenPos.y - 20, 16, 16)
        
        draw.SimpleTextOutlined(marker.msg .. " (" .. dist .. "м)", "ChatFont", screenPos.x, screenPos.y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
        draw.SimpleTextOutlined("От: " .. marker.name, "ChatFont", screenPos.x, screenPos.y + 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    end
end)

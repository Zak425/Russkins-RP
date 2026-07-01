include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 250000 then return end

    local pos = self:GetPos() + Vector(0, 0, 40)
    local ang = self:GetAngles()
    
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    cam.Start3D2D(pos, ang, 0.1)
        draw.SimpleTextOutlined("АРСЕНАЛ МИЛИЦИИ", "Trebuchet24", 0, 0, Color(50, 150, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))
        draw.SimpleTextOutlined("Нажмите [E]", "DermaDefault", 0, 30, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))
    cam.End3D2D()
end

net.Receive("RP_OpenArsenalMenu", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) or not ent.Items then return end

    local frame = vgui.Create("DFrame")
    frame:SetSize(420, 500)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 35, 240))
        draw.RoundedBoxEx(8, 0, 0, w, 30, Color(50, 100, 200, 255), true, true, false, false)
        draw.SimpleText("Арсенал Милиции", "Trebuchet18", w/2, 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(5, 5, 5, 5)

    for idx, item in ipairs(ent.Items) do
        local itemPanel = scroll:Add("DPanel")
        itemPanel:Dock(TOP)
        itemPanel:SetHeight(60)
        itemPanel:DockMargin(0, 0, 0, 5)
        itemPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(45, 45, 50, 255))
        end

        local icon = vgui.Create("DImage", itemPanel)
        icon:SetPos(10, 22)
        icon:SetSize(16, 16)
        icon:SetImage(item.icon)

        local nameLabel = vgui.Create("DLabel", itemPanel)
        nameLabel:SetText(item.name)
        nameLabel:SetFont("Trebuchet18")
        nameLabel:SetTextColor(Color(255, 255, 255))
        nameLabel:SizeToContents()
        nameLabel:SetPos(35, 10)

        local descLabel = vgui.Create("DLabel", itemPanel)
        descLabel:SetText(item.desc .. " (Перезарядка: " .. item.cooldown .. " сек)")
        descLabel:SetFont("DermaDefault")
        descLabel:SetTextColor(Color(180, 180, 180))
        descLabel:SizeToContents()
        descLabel:SetPos(35, 30)

        local takeBtn = vgui.Create("DButton", itemPanel)
        takeBtn:SetText("Взять")
        takeBtn:SetSize(70, 30)
        takeBtn:SetPos(320, 15)
        takeBtn.DoClick = function()
            net.Start("RP_ArsenalTakeItem")
                net.WriteEntity(ent)
                net.WriteInt(idx, 8)
            net.SendToServer()
        end
    end
end)

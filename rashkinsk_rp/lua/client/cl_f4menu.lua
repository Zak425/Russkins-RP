local function OpenF4Menu()
    if IsValid(RP_MenuFrame) then RP_MenuFrame:Close() end

    local frame = vgui.Create("DFrame")
    RP_MenuFrame = frame
    frame:SetSize(600, 500)
    frame:SetTitle("Управление персонажем — Рашкинск RP")
    frame:Center()
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 35, 240))
        draw.RoundedBox(4, 0, 0, w, 24, Color(45, 45, 50, 255))
    end

    local econPanel = vgui.Create("DPanel", frame)
    econPanel:Dock(TOP)
    econPanel:SetHeight(50)
    econPanel:DockMargin(5, 5, 5, 0)
    econPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 45, 255))
    end

    local moneyLabel = vgui.Create("DLabel", econPanel)
    moneyLabel:SetFont("Trebuchet24")
    moneyLabel:SetTextColor(Color(100, 220, 100))
    moneyLabel:SetPos(15, 12)
    moneyLabel.Think = function(self)
        local currentMoney = LocalPlayer():GetNWInt("RP_Money", 0)
        local newText = "Баланс: " .. currentMoney .. " руб."
        if self:GetText() ~= newText then
            self:SetText(newText)
            self:SizeToContents()
        end
    end

    local payBtn = vgui.Create("DButton", econPanel)
    payBtn:SetText("Передать человеку")
    payBtn:SetSize(130, 30)
    payBtn:SetPos(310, 10)
    payBtn.DoClick = function()
        Derma_StringRequest(
            "Передача денег",
            "Введите сумму для передачи игроку напротив:",
            "",
            function(text)
                local amount = tonumber(text)
                if amount and amount > 0 then
                    LocalPlayer():ConCommand("say /pay " .. amount)
                    frame:Close()
                else
                    Derma_Message("Неверная сумма!", "Ошибка", "ОК")
                end
            end
        )
    end

    local dropBtn = vgui.Create("DButton", econPanel)
    dropBtn:SetText("Выбросить")
    dropBtn:SetSize(130, 30)
    dropBtn:SetPos(455, 10)
    dropBtn.DoClick = function()
        Derma_StringRequest(
            "Выбросить деньги",
            "Какую сумму вы хотите сбросить на землю?",
            "",
            function(text)
                local amount = tonumber(text)
                if amount and amount > 0 then
                    LocalPlayer():ConCommand("say /dropmoney " .. amount)
                    frame:Close()
                else
                    Derma_Message("Неверная сумма!", "Ошибка", "ОК")
                end
            end
        )
    end

    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:Dock(FILL)
    sheet:DockMargin(5, 5, 5, 5)
    sheet.Paint = function(self, w, h) end

    local jobsScroll = vgui.Create("DScrollPanel", sheet)
    jobsScroll:Dock(FILL)

    for teamID, info in pairs(RP.Teams) do
        local panel = jobsScroll:Add("DPanel")
        panel:Dock(TOP)
        panel:SetHeight(60)
        panel:DockMargin(0, 0, 0, 5)
        panel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 45, 255))
            draw.RoundedBox(0, 0, 0, 5, h, info.color)
        end

        local nameLabel = vgui.Create("DLabel", panel)
        nameLabel:SetText(info.name)
        nameLabel:SetFont("Trebuchet18")
        nameLabel:SetTextColor(Color(255, 255, 255))
        nameLabel:SizeToContents()
        nameLabel:SetPos(15, 10)

        local descLabel = vgui.Create("DLabel", panel)
        descLabel:SetText(info.description or "")
        descLabel:SetFont("DermaDefault")
        descLabel:SetTextColor(Color(180, 180, 180))
        descLabel:SetSize(340, 20)
        descLabel:SetPos(15, 32)

        local chooseBtn = vgui.Create("DButton", panel)
        chooseBtn:SetText("Вступить")
        chooseBtn:SetSize(80, 30)
        chooseBtn:SetPos(470, 15)
        
        if LocalPlayer():Team() == teamID then
            chooseBtn:SetText("Текущая")
            chooseBtn:SetEnabled(false)
        end

        chooseBtn.DoClick = function()
            net.Start("RP_ChangeTeam")
                net.WriteInt(teamID, 4)
            net.SendToServer()
            frame:Close()
        end
    end

    sheet:AddSheet("Профессии", jobsScroll, "icon16/user.png")

    local currentJob = RP.Teams[LocalPlayer():Team()]
    if currentJob and currentJob.SupplierItems then
        local shopItems = {}
        local meleeItems = {}
        local ammoItems = {}
        
        for idx, item in ipairs(currentJob.SupplierItems) do
            if item.isAmmo then
                table.insert(ammoItems, {idx = idx, data = item})
            elseif item.isMelee then
                table.insert(meleeItems, {idx = idx, data = item})
            else
                table.insert(shopItems, {idx = idx, data = item})
            end
        end

        local function PopulateShopScroll(scrollPanel, itemsList, barColor)
            for _, itemInfo in ipairs(itemsList) do
                local idx = itemInfo.idx
                local item = itemInfo.data
                
                local itemPanel = scrollPanel:Add("DPanel")
                itemPanel:Dock(TOP)
                itemPanel:SetHeight(50)
                itemPanel:DockMargin(0, 0, 0, 5)
                itemPanel.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 45, 255))
                    draw.RoundedBox(0, 0, 0, 5, h, barColor)
                end

                local itemName = vgui.Create("DLabel", itemPanel)
                itemName:SetText(item.name)
                itemName:SetFont("Trebuchet18")
                itemName:SetTextColor(Color(255, 255, 255))
                itemName:SizeToContents()
                itemName:SetPos(15, 15)

                local itemPrice = vgui.Create("DLabel", itemPanel)
                itemPrice:SetText(item.price .. " руб.")
                itemPrice:SetFont("Trebuchet18")
                itemPrice:SetTextColor(Color(100, 220, 100))
                itemPrice:SizeToContents()
                itemPrice:SetPos(350, 15)

                local buyBtn = vgui.Create("DButton", itemPanel)
                buyBtn:SetText("Заказать")
                buyBtn:SetSize(80, 30)
                buyBtn:SetPos(470, 10)
                buyBtn.DoClick = function()
                    if LocalPlayer():GetNWInt("RP_Money", 0) < item.price then
                        Derma_Message("У вас недостаточно денег!", "Ошибка закупки", "ОК")
                        return
                    end
                    
                    net.Start("RP_BuyItem")
                        net.WriteInt(idx, 16)
                    net.SendToServer()
                end
            end
        end

        if #shopItems > 0 then
            local shopScroll = vgui.Create("DScrollPanel", sheet)
            shopScroll:Dock(FILL)
            PopulateShopScroll(shopScroll, shopItems, Color(200, 150, 50))
            sheet:AddSheet("Закупка товара", shopScroll, "icon16/box.png")
        end

        if #meleeItems > 0 then
            local meleeScroll = vgui.Create("DScrollPanel", sheet)
            meleeScroll:Dock(FILL)
            PopulateShopScroll(meleeScroll, meleeItems, Color(200, 50, 50))
            sheet:AddSheet("Холодное оружие", meleeScroll, "icon16/cut.png")
        end

        if #ammoItems > 0 then
            local ammoScroll = vgui.Create("DScrollPanel", sheet)
            ammoScroll:Dock(FILL)
            PopulateShopScroll(ammoScroll, ammoItems, Color(50, 150, 250))
            sheet:AddSheet("Патроны", ammoScroll, "icon16/bullet_blue.png")
        end
    end
end

net.Receive("RP_OpenF4Menu", function()
    OpenF4Menu()
end)

-- Высокопроизводительный кэш сущностей денег для оптимизации FPS
local moneyEntities = {}

hook.Add("OnEntityCreated", "RP_RegisterMoneyEntity", function(ent)
    timer.Simple(0.1, function()
        if IsValid(ent) and ent:GetModel() and string.lower(ent:GetModel()) == "models/props/cs_assault/money.mdl" then
            moneyEntities[ent] = true
        end
    end)
end)

hook.Add("EntityRemoved", "RP_UnregisterMoneyEntity", function(ent)
    moneyEntities[ent] = nil
end)

hook.Add("PostDrawTranslucentRenderables", "RP_DrawMoneyText", function()
    local eyeAngs = EyeAngles()
    for ent in pairs(moneyEntities) do
        if IsValid(ent) then
            local amount = ent:GetNWInt("DisplayMoney", 0)
            if amount > 0 then
                local pos = ent:GetPos() + Vector(0, 0, 15)
                local ang = Angle(0, eyeAngs.y, 0)
                
                ang:RotateAroundAxis(ang:Forward(), 90)
                ang:RotateAroundAxis(ang:Right(), 90)
                
                cam.Start3D2D(pos, Angle(0, eyeAngs.y, 90), 0.2)
                    draw.SimpleText(amount .. " руб.", "Trebuchet24", 0, 0, Color(100, 220, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                cam.End3D2D()
            end
        else
            moneyEntities[ent] = nil
        end
    end
end)
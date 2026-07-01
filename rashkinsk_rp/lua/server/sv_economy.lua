-- sv_economy.lua

RP = RP or {}

-- Удаляем старый хук PlayerSay из памяти сервера (предотвращает двойной вызов при перезагрузке)
hook.Remove("PlayerSay", "RP_EconomyChatCommands")

local START_MONEY = 1000
local DEATH_DROP_PERCENT = 0.30
local MIN_MONEY_TO_DROP = 50

function RP.GetMoney(ply)
    if not IsValid(ply) then return 0 end
    return ply:GetNWInt("RP_Money", START_MONEY)
end

function RP.SetMoney(ply, amount)
    if not IsValid(ply) then return end
    amount = math.max(0, math.floor(amount))
    
    ply:SetNWInt("RP_Money", amount)
    ply:SetPData("RP_Money_Balance", amount)
end

function RP.AddMoney(ply, amount)
    if not IsValid(ply) then return end
    RP.SetMoney(ply, RP.GetMoney(ply) + amount)
end

hook.Add("PlayerInitialSpawn", "RP_LoadEconomy", function(ply)
    timer.Simple(0.2, function()
        if not IsValid(ply) then return end
        local savedMoney = ply:GetPData("RP_Money_Balance")
        
        if savedMoney then
            RP.SetMoney(ply, tonumber(savedMoney))
        else
            RP.SetMoney(ply, START_MONEY)
            ply:ChatPrint("Приветствуем! Вам выдан начальный капитал: " .. START_MONEY .. " руб.")
        end
    end)
end)

hook.Add("PlayerDisconnected", "RP_SaveEconomy", function(ply)
    if IsValid(ply) then
        ply:SetPData("RP_Money_Balance", RP.GetMoney(ply))
    end
end)

-- Универсальная функция спавна пачки денег
local function SpawnMoneyDrop(ply, amount)
    local spawnPos = ply:GetPos() + ply:GetForward() * 40 + Vector(0, 0, 15)
    local moneyEnt = ents.Create("prop_physics")
    if not IsValid(moneyEnt) then return end
    
    moneyEnt:SetModel("models/props/cs_assault/money.mdl")
    moneyEnt:SetPos(spawnPos)
    moneyEnt:SetAngles(ply:GetAngles())
    moneyEnt:Spawn()
    
    moneyEnt.IsRPMoney = true
    moneyEnt.RP_MoneyAmount = amount
    moneyEnt:SetNWInt("DisplayMoney", amount)
    
    local phys = moneyEnt:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
end

-- ==========================================
-- УЛУЧШЕННЫЙ И ОБЪЕДИНЕННЫЙ ХУК ЧАТА (Совместимый с Z-City)
-- ==========================================
hook.Add("HG_PlayerSay", "RP_EconomyChatCommands", function(ply, txtTbl, text)
    if not IsValid(ply) then return end
    
    -- Очищаем текст от лишних пробелов по краям
    local cleanText = string.Trim(text)
    local args = string.Explode(" ", cleanText)
    local cmd = string.lower(args[1] or "")
    
    if cmd == "/setmoney" or cmd == "!setmoney" then
        txtTbl[1] = "" -- Скрываем команду из чата Z-City
        
        if not ply:IsAdmin() then
            ply:ChatPrint("У вас нет прав на использование этой команды!")
            return
        end
        
        local targetName = args[2]
        local amount = tonumber(args[3])
        
        if not targetName or not amount then
            ply:ChatPrint("Использование: /setmoney ник сумма")
            return
        end
        
        local targetPly = nil
        for _, p in ipairs(player.GetAll()) do
            if string.find(string.lower(p:Nick()), string.lower(targetName), 1, true) then
                targetPly = p
                break
            end
        end
        
        if IsValid(targetPly) then
            RP.SetMoney(targetPly, amount)
            ply:ChatPrint("Вы установили баланс игрока " .. targetPly:Nick() .. " на " .. amount .. " руб.")
            targetPly:ChatPrint("Администратор установил ваш баланс на: " .. amount .. " руб.")
        else
            ply:ChatPrint("Игрок с ником не найден!")
        end

    elseif cmd == "/pay" or cmd == "!pay" then
        txtTbl[1] = "" -- Скрываем команду из чата Z-City
        
        local amount = tonumber(args[2])
        if not amount or amount <= 0 then
            ply:ChatPrint("Использование: /pay сумма")
            return
        end
        
        local tr = ply:GetEyeTrace()
        local target = tr.Entity
        
        if not IsValid(target) or not target:IsPlayer() or ply:GetPos():DistToSqr(target:GetPos()) > 40000 then
            ply:ChatPrint("Вы должны стоять близко и смотреть на игрока!")
            return
        end
        
        local myMoney = RP.GetMoney(ply)
        if myMoney < amount then
            ply:ChatPrint("У вас нет такой суммы!")
            return
        end
        
        RP.AddMoney(ply, -amount)
        RP.AddMoney(target, amount)
        
        ply:ChatPrint("Вы передали " .. target:Name() .. " " .. amount .. " руб.")
        target:ChatPrint(ply:Name() .. " передал вам " .. amount .. " руб.")
        
    elseif cmd == "/money" or cmd == "!money" then
        txtTbl[1] = "" -- Скрываем команду из чата Z-City
        ply:ChatPrint("Ваш баланс: " .. RP.GetMoney(ply) .. " руб.")

    elseif cmd == "/dropmoney" or cmd == "!dropmoney" then
        txtTbl[1] = "" -- Скрываем команду из чата Z-City
        
        local amount = tonumber(args[2])
        if not amount or amount <= 0 then
            ply:ChatPrint("Использование: /dropmoney сумма")
            return
        end
        
        local currentMoney = RP.GetMoney(ply)
        if currentMoney < amount then
            ply:ChatPrint("У вас нет такой суммы!")
            return
        end
        
        RP.AddMoney(ply, -amount)
        SpawnMoneyDrop(ply, amount)
        
        ply:ChatPrint("Вы выбросили " .. amount .. " руб.")
    end
end)


hook.Add("PlayerUse", "RP_PickupMoneyEntity", function(ply, ent)
    if IsValid(ent) and ent.IsRPMoney and ent.RP_MoneyAmount then
        if not ent.PickedUp then
            ent.PickedUp = true
            
            local amount = ent.RP_MoneyAmount
            RP.AddMoney(ply, amount)
            ply:ChatPrint("Вы подобрали " .. amount .. " руб.")
            
            ent:Remove()
            return false
        end
    end
end)

hook.Add("PlayerDeath", "RP_EconomyDeathDrop", function(ply, inflictor, attacker)
    local currentMoney = RP.GetMoney(ply)
    
    if currentMoney < MIN_MONEY_TO_DROP then return end
    
    local dropAmount = math.floor(currentMoney * DEATH_DROP_PERCENT)
    if dropAmount <= 0 then return end
    
    RP.AddMoney(ply, -dropAmount)
    
    local spawnPos = ply:GetPos() + Vector(0, 0, 15)
    local moneyEnt = ents.Create("prop_physics")
    if not IsValid(moneyEnt) then return end
    
    moneyEnt:SetModel("models/props/cs_assault/money.mdl")
    moneyEnt:SetPos(spawnPos)
    moneyEnt:SetAngles(Angle(0, math.random(0, 360), 0))
    moneyEnt:Spawn()
    
    moneyEnt.IsRPMoney = true
    moneyEnt.RP_MoneyAmount = dropAmount
    moneyEnt:SetNWInt("DisplayMoney", dropAmount)
    
    local phys = moneyEnt:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        local randomForce = Vector(math.random(-40, 40), math.random(-40, 40), 120)
        phys:ApplyForceCenter(randomForce)
    end
    
    ply:ChatPrint("Вы погибли и потеряли " .. dropAmount .. " руб.")
end)

concommand.Add("rp_setmoney", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("У вас нет прав на использование этой команды!")
        return 
    end

    local targetName = args[1]
    local amount = tonumber(args[2])

    if not targetName or not amount then
        if IsValid(ply) then
            ply:ChatPrint("Использование: rp_setmoney ник сумма")
        else
            print("Использование: rp_setmoney ник сумма")
        end
        return
    end

    local targetPly = nil
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Nick()), string.lower(targetName), 1, true) then
            targetPly = p
            break
        end
    end

    if IsValid(targetPly) then
        RP.SetMoney(targetPly, amount)
        local msg = "Игроку " .. targetPly:Nick() .. " установлен баланс: " .. amount .. " руб."
        if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
        targetPly:ChatPrint("Администратор установил ваш баланс на: " .. amount .. " руб.")
    else
        local errorMsg = "Игрок не найден!"
        if IsValid(ply) then ply:ChatPrint(errorMsg) else print(errorMsg) end
    end
end)

-- ==========================================
-- СИСТЕМА ЗАРПЛАТЫ
-- ==========================================
timer.Create("RP_SalaryTimer", RP.SalaryInterval or 900, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Team() ~= 0 then
            local job = RP.Teams[ply:Team()]
            local salaryAmount = RP.DefaultSalary or 500
            
            if job and job.salary ~= nil then
                salaryAmount = job.salary
            end
            
            if salaryAmount > 0 then
                RP.AddMoney(ply, salaryAmount)
                ply:ChatPrint("Вы получили зарплату: " .. salaryAmount .. " руб.")
            end
        end
    end
end)
RP = RP or {}
RP.Teams = {}

-- НАСТРОЙКА: Кулдаун на смену профессии в секундах
RP.ChangeJobCooldown = 0

-- НАСТРОЙКА: Система зарплаты
RP.SalaryInterval = 600 -- Каждые 15 минут (900 секунд)
RP.DefaultSalary = 500  -- Зарплата по умолчанию, если не указана в файле профессии

if SERVER then
    AddCSLuaFile("client/cl_f4menu.lua")
    AddCSLuaFile("client/cl_appearance_block.lua")
end

-- Автоматический поиск и загрузка всех файлов профессий из папки jobs
local jobFiles = file.Find("autorun/jobs/*.lua", "LUA")
for _, filename in ipairs(jobFiles) do
    if SERVER then
        AddCSLuaFile("autorun/jobs/" .. filename)
    end
    include("autorun/jobs/" .. filename)
end

---------------------------------------------------------
-- СЕРВЕРНАЯ ЧАСТЬ
---------------------------------------------------------
---------------------------------------------------------
-- СЕРВЕРНАЯ ЧАСТЬ
---------------------------------------------------------
if SERVER then
    util.AddNetworkString("RP_OpenF4Menu")
    util.AddNetworkString("RP_ChangeTeam")
    util.AddNetworkString("RP_BuyItem") -- РЕГИСТРИРУЕМ СТРОКУ ДЛЯ МАГАЗИНА

    -- ПОДКЛЮЧАЕМ НАШ ФАЙЛ БЛОКИРОВКИ ВНЕШНОСТИ
    include("server/sv_appearance_block.lua")
    
    -- ПОДКЛЮЧАЕМ НАШУ НОВУЮ БАЗУ ДЕНЕГ
    include("server/sv_economy.lua")
    
    -- СИСТЕМА ВЫЗОВОВ
    include("server/sv_calls.lua")
    AddCSLuaFile("client/cl_calls.lua")

    -- ОБРАБОТКА ПОКУПКИ ИЗ F4-МЕНЮ
    net.Receive("RP_BuyItem", function(len, ply)
        if not IsValid(ply) or not ply:Alive() then return end

        local job = RP.Teams[ply:Team()]
        if not job or not job.SupplierItems then 
            ply:ChatPrint("Ваша профессия не может закупать товар!")
            return 
        end

        local itemIdx = net.ReadInt(16)
        local item = job.SupplierItems[itemIdx]

        if not item then 
            ply:ChatPrint("Товар не найден!")
            return 
        end

        -- Проверка денег через твою систему экономики
        local currentMoney = RP.GetMoney(ply)
        if currentMoney < item.price then
            ply:ChatPrint("У вас недостаточно денег!")
            return
        end

        -- Проверяем наличие класса у товара
        local entClass = item.class
        if not entClass or entClass == "" then
            ply:ChatPrint("Ошибка: У товара не указан класс энтити.")
            return
        end

        -- Логика спавна товара перед продавцом (строго по чистому классу из настроек)
        local spawnPos = ply:GetPos() + ply:GetForward() * 50 + Vector(0, 0, 15)
        local ent = ents.Create(entClass)

        if IsValid(ent) then
            ent:SetPos(spawnPos)
            ent:SetAngles(Angle(0, ply:GetAngles().y, 0))
            ent:Spawn()
            ent:Activate()
            
            -- Пробуждаем физику предмета
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then 
                phys:Wake() 
            end

            -- Списываем деньги через твой sv_economy.lua
            RP.AddMoney(ply, -item.price)
            ply:ChatPrint("Вы успешно заказали: " .. item.name .. " за " .. item.price .. " руб.")
        else
            ply:ChatPrint("Ошибка создания предмета. Проверьте класс в консоли!")
            print("[SHOP ERROR] Не удалось создать энтити с классом: " .. tostring(entClass))
        end
    end)

    -- Дальше идет твоя старая функция SetPlayerJob...
    local function SetPlayerJob(ply, teamID)
        if not IsValid(ply) then return end
        
        local job = RP.Teams[teamID]
        if not job then return end

        -- Шаг 1: Делаем полный СНАПШОТ внешности
        if not RP.Teams[ply:Team()] or not RP.Teams[ply:Team()].models then
            local currentModel = ply:GetModel()
            if currentModel and not string.find(currentModel, "kleiner") then
                ply.ZCity_SavedModel = currentModel
                ply.ZCity_SavedSkin = ply:GetSkin()

                ply.ZCity_SavedBGs = {}
                for i = 0, ply:GetNumBodyGroups() - 1 do
                    ply.ZCity_SavedBGs[i] = ply:GetBodygroup(i)
                end

                ply.ZCity_SavedSubMats = {}
                for i = 0, 31 do
                    local mat = ply:GetSubMaterial(i)
                    if mat and mat ~= "" then
                        ply.ZCity_SavedSubMats[i] = mat
                    end
                end
            end
        end

        ply:SetTeam(teamID)
        ply:StripWeapons()
        ply:StripAmmo()

        -- Шаг 2: Выставляем модель для новой роли
        if job.models and #job.models > 0 then
            -- МИЛИЦИЯ: Очищаем всё под ноль
            for i = 0, 31 do ply:SetSubMaterial(i, "") end
            ply:SetSkin(0)
            for i = 0, ply:GetNumBodyGroups() - 1 do ply:SetBodygroup(i, 0) end

            local randomModel = table.Random(job.models)
            ply:SetModel(randomModel)
            
            timer.Simple(0.1, function()
                if IsValid(ply) and ply:Team() == teamID then
                    for i = 0, 31 do ply:SetSubMaterial(i, "") end
                end
            end)
        else
            -- ГРАЖДАНСКИЕ/МЕДИКИ: Восстанавливаем наш СНАПШОТ
            local modelToSet = ply.ZCity_SavedModel
            if not modelToSet or modelToSet == "" then
                modelToSet = ply:GetNWString("zcity_model") or ply:GetNWString("CharacterModel")
            end

            if modelToSet and modelToSet ~= "" then
                ply:SetModel(modelToSet)
            end

            -- НАКАТЫВАЕМ ТЕКСТУРЫ МГНОВЕННО (Чтобы не было видно модели без текстур)
            if ply.ZCity_SavedSkin then ply:SetSkin(ply.ZCity_SavedSkin) end
            if ply.ZCity_SavedBGs then
                for k, v in pairs(ply.ZCity_SavedBGs) do ply:SetBodygroup(k, v) end
            end
            
            for i = 0, 31 do ply:SetSubMaterial(i, "") end
            if ply.ZCity_SavedSubMats then
                for k, v in pairs(ply.ZCity_SavedSubMats) do
                    ply:SetSubMaterial(k, v)
                    ply:SendLua([[local p = LocalPlayer() if IsValid(p) then p:SetSubMaterial(]]..k..[[, "]]..v..[[") end]])
                end
            end

            -- Микро-задержка (страховка от капризов движка)
            timer.Simple(0.15, function()
                if not IsValid(ply) or ply:Team() ~= teamID then return end
                
                if modelToSet and modelToSet ~= "" then ply:SetModel(modelToSet) end
                if ply.ZCity_SavedSkin then ply:SetSkin(ply.ZCity_SavedSkin) end
                
                if ply.ZCity_SavedBGs then
                    for k, v in pairs(ply.ZCity_SavedBGs) do ply:SetBodygroup(k, v) end
                end

                if ply.ZCity_SavedSubMats then
                    for k, v in pairs(ply.ZCity_SavedSubMats) do
                        ply:SetSubMaterial(k, v)
                        ply:SendLua([[local p = LocalPlayer() if IsValid(p) then p:SetSubMaterial(]]..k..[[, "]]..v..[[") end]])
                    end
                end
                
                hook.Run("PlayerLoadout", ply) 
            end)
        end

        -- Выдача оружия
        for _, wep in ipairs(job.weapons) do
            ply:Give(wep)
        end
        
        -- ВЫДАЧА ПАТРОНОВ (Новый блок)
        if job.ammo then
            for ammoType, amount in pairs(job.ammo) do
                ply:GiveAmmo(amount, ammoType, true) -- true убирает всплывающий попап о подборе патронов на экране
            end
        end
        
        ply:ChatPrint("Вы сменили профессию на: " .. job.name)
    end
    
    hook.Add("PlayerInitialSpawn", "RP_InitialJob", function(ply)
        timer.Simple(0.5, function()
            if IsValid(ply) then SetPlayerJob(ply, TEAM_CITIZEN) end
        end)
    end)

    hook.Add("PlayerSpawn", "RP_RespawnJob", function(ply)
        timer.Simple(0.1, function()
            if IsValid(ply) and ply:Team() ~= 0 then SetPlayerJob(ply, ply:Team()) end
        end)
    end)

    -- Обработка смены роли через net-сообщение (с кулдауном)
    net.Receive("RP_ChangeTeam", function(len, ply)
        local requestedTeam = net.ReadInt(4)
        
        if not RP.Teams[requestedTeam] then
            ply:ChatPrint("Ошибка: Такой профессии не существует.")
            return
        end

        -- Проверка на кулдаун смены профессии
        local curTime = CurTime()
        ply.NextJobChange = ply.NextJobChange or 0

        if curTime < ply.NextJobChange then
            local timeLeft = math.ceil(ply.NextJobChange - curTime)
            ply:ChatPrint("Вы не можете менять профессию так часто! Подождите " .. timeLeft .. " сек.")
            return
        end

        -- Заставляем сменить профессию и обновляем таймер КД
        SetPlayerJob(ply, requestedTeam)
        ply:KillSilent()
        ply:Spawn()
        ply.NextJobChange = curTime + RP.ChangeJobCooldown
    end)

    hook.Add("ShowSpare2", "RP_F4Hook", function(ply)
        net.Start("RP_OpenF4Menu")
        net.Send(ply)
        return true
    end)
    -- ЗАПРЕТЫ СПАВНА ДЛЯ ОБЫЧНЫХ ИГРОКОВ (Пропы разрешены)
    local function BlockSpawn(ply)
        if not ply:IsAdmin() then return false end
    end
    hook.Add("PlayerSpawnEffect", "RP_BlockEffectSpawn", BlockSpawn)
    hook.Add("PlayerSpawnNPC", "RP_BlockNPCSpawn", BlockSpawn)
    hook.Add("PlayerSpawnObject", "RP_BlockObjectSpawn", BlockSpawn)
    hook.Add("PlayerSpawnRagdoll", "RP_BlockRagdollSpawn", BlockSpawn)
    hook.Add("PlayerSpawnVehicle", "RP_BlockVehicleSpawn", BlockSpawn)
    hook.Add("PlayerSpawnSWEP", "RP_BlockSWEPSpawn", BlockSpawn)
    hook.Add("PlayerGiveSWEP", "RP_BlockGiveSWEP", BlockSpawn)
    hook.Add("PlayerSpawnSENT", "RP_BlockSENTSpawn", BlockSpawn)

end

---------------------------------------------------------
-- КЛИЕНТСКАЯ ЧАСТЬ
---------------------------------------------------------
if CLIENT then
    -- Заглушка на случай, если include падает, чтобы файл не ломал остальной код
    pcall(function()
        include("client/cl_f4menu.lua")
        include("client/cl_calls.lua")
        include("client/cl_appearance_block.lua")
    end)
    -- СКРЫТИЕ ВКЛАДОК Q-МЕНЮ ДЛЯ ОБЫЧНЫХ ИГРОКОВ (Оставляем только Пропы и Инструменты)
    hook.Add("SpawnMenuOpen", "RP_BlockQMenu", function()
        if not IsValid(g_SpawnMenu) then return end
        
        local isAdmin = LocalPlayer():IsAdmin()
        if not g_SpawnMenu.CreateMenu or not g_SpawnMenu.CreateMenu.Items then return end
        
        for k, pnl in pairs(g_SpawnMenu.CreateMenu.Items) do
            if pnl.Tab then
                local name = pnl.Tab:GetText()
                -- Языки могут отличаться, поэтому проверяем все известные имена для стандартных вкладок пропов и тулов
                local isAllowedTab = (name == "Spawnlists" or name == "Пропы" or name == "#spawnmenu.category.props") or
                                     (name == "Tools" or name == "Инструменты" or name == "#spawnmenu.category.tools")
                                     
                if not isAllowedTab then
                    pnl.Tab:SetVisible(isAdmin)
                end
            end
        end
    end)
end
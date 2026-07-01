AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("RP_ArsenalTakeItem")
util.AddNetworkString("RP_OpenArsenalMenu")

function ENT:Initialize()
    self:SetModel("models/props_c17/Lockers001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Проверка на профессию милиции (TEAM_POLICE)
    if activator:Team() ~= TEAM_POLICE then
        activator:ChatPrint("У вас нет доступа к этому арсеналу! Только Милиция.")
        return
    end

    -- Открываем меню
    net.Start("RP_OpenArsenalMenu")
    net.WriteEntity(self)
    net.Send(activator)
end

-- Обработка запросов на получение предметов
net.Receive("RP_ArsenalTakeItem", function(len, ply)
    if not IsValid(ply) or ply:Team() ~= TEAM_POLICE then return end

    local ent = net.ReadEntity()
    local itemIdx = net.ReadInt(8)

    -- Проверки на валидность и дистанцию
    if not IsValid(ent) or ent:GetClass() ~= "ent_rp_arsenal" then return end
    if ply:GetPos():DistToSqr(ent:GetPos()) > 60000 then -- ~244 units max distance
        ply:ChatPrint("Вы слишком далеко от арсенала!")
        return 
    end

    local item = ent.Items[itemIdx]
    if not item then return end

    ply.ArsenalCooldowns = ply.ArsenalCooldowns or {}
    
    local curTime = CurTime()
    local lastTime = ply.ArsenalCooldowns[itemIdx]
    
    if lastTime and curTime < lastTime + item.cooldown then
        local timeLeft = math.ceil((lastTime + item.cooldown) - curTime)
        ply:ChatPrint("Вы сможете взять это снова через " .. timeLeft .. " сек.")
        return
    end

    -- Выдача предмета
    if item.action == "entity" then
        local spawned_ent = ents.Create(item.class)
        if IsValid(spawned_ent) then
            -- Спавним прямо перед игроком
            local forward = ply:GetAimVector()
            forward.z = 0
            forward:Normalize()
            
            spawned_ent:SetPos(ply:GetPos() + forward * 40 + Vector(0, 0, 40))
            spawned_ent:Spawn()
            ply:ChatPrint("Вы взяли: " .. item.name .. ".")
        else
            ply:ChatPrint("Ошибка: не удалось выдать " .. item.name)
        end
    elseif item.action == "weapon" then
        if ply:HasWeapon(item.class) then
            ply:ChatPrint("У вас уже есть это оружие.")
            return
        end
        ply:Give(item.class)
        ply:ChatPrint("Вы взяли: " .. item.name .. ".")
    elseif item.action == "ammo" then
        ply:GiveAmmo(item.amount, item.class)
        ply:ChatPrint("Вы взяли: " .. item.name .. ".")
    end

    -- Устанавливаем кулдаун только при успешном взятии
    ply.ArsenalCooldowns[itemIdx] = curTime
end)

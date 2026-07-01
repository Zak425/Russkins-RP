-- cl_appearance_block.lua
-- Этот скрипт отвечает за клиентскую очистку аксессуаров Z-City при игре за спец-роли

RP = RP or {}

local function ClearClientsideAccessories(ply)
    if not IsValid(ply) then return end
    
    -- Очищаем локальные ClientsideModel-аксессуары игрока
    if ply.modelAccess then
        for k, v in pairs(ply.modelAccess) do
            if IsValid(v) then
                v:Remove()
            end
        end
        ply.modelAccess = nil
    end

    -- Очищаем аксессуары фейк-регдолла игрока
    local ent = ply.FakeRagdoll or ply
    if IsValid(ent) and ent.modelAccess then
        for k, v in pairs(ent.modelAccess) do
            if IsValid(v) then
                v:Remove()
            end
        end
        ent.modelAccess = nil
    end
end

-- Хук рисования внешности: если профессия блокирует внешность, принудительно стираем аксессуары
hook.Add("PostDrawAppearance", "RP_ClientBlockAppearanceDraw", function(ent, ply)
    if not IsValid(ply) then return end
    
    -- Если передан не игрок, а регдолл, пытаемся получить игрока-владельца через метод Z-City/Homigrad
    if not ply:IsPlayer() then
        if hg and hg.RagdollOwner and ply:IsRagdoll() then
            ply = hg.RagdollOwner(ply)
        end
    end
    
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    local job = RP.Teams[ply:Team()]
    if job and job.blockAppearance then
        ClearClientsideAccessories(ply)
        if IsValid(ent) and ent ~= ply then
            ClearClientsideAccessories(ent)
        end
    end
end)

-- Чистим аксессуары при спавне на клиенте
hook.Add("PlayerSpawn", "RP_ClientCleanAppearanceOnSpawn", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    timer.Simple(0.1, function()
        if not IsValid(ply) or not ply:IsPlayer() then return end
        local job = RP.Teams[ply:Team()]
        if job and job.blockAppearance then
            ClearClientsideAccessories(ply)
        end
    end)
end)

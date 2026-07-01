-- sv_appearance_block.lua
-- Этот скрипт полностью отвечает за блокировку кастомизации Z-City для спец-ролей

RP = RP or {}

-- Удаляем старый хук из памяти сервера
hook.Remove("ZCity_PlayerLoadAppearance", "RP_BlockAppearanceHook")

-- Функция очистки внешности на сервере
local function ClearPlayerZCityAppearance(ply)
    if not IsValid(ply) then return end
    
    -- Сбрасываем нетвар аксессуаров Z-City на сервере
    if ply.SetNetVar then
        ply:SetNetVar("Accessories", nil)
    end
    
    -- Сбрасываем скины, бодигруппы
    ply:SetSkin(0)
    for i = 0, ply:GetNumBodyGroups() - 1 do 
        ply:SetBodygroup(i, 0) 
    end

    -- Сбрасываем субматериалы
    for i = 0, 31 do 
        ply:SetSubMaterial(i, "") 
    end
    
    -- Удаляем физические пропсы одежды (на всякий случай)
    for _, child in ipairs(ply:GetChildren()) do
        if IsValid(child) and (child:GetClass() == "prop_dynamic" or string.find(string.lower(child:GetName() or ""), "appearance")) then
            child:Remove()
        end
    end
end

-- Ловим момент инициализации Z-City (после того, как загрузчик Z-City завершит работу)
hook.Add("HomigradRun", "RP_ZCityAppearanceOverride", function()
    if hg and hg.Appearance then
        -- Переопределяем ApplyAppearance
        local old_ApplyAppearance = hg.Appearance.ApplyAppearance
        if old_ApplyAppearance then
            hg.Appearance.ApplyAppearance = function(ply, tAppearance, bRandom, bResponeIsValid, bUseCached)
                if IsValid(ply) then
                    local job = RP.Teams[ply:Team()]
                    if job and job.blockAppearance then
                        ClearPlayerZCityAppearance(ply)
                        return -- Блокируем применение кастомизации
                    end
                end
                return old_ApplyAppearance(ply, tAppearance, bRandom, bResponeIsValid, bUseCached)
            end
        end

        -- Переопределяем ForceApplyAppearance
        local old_ForceApplyAppearance = hg.Appearance.ForceApplyAppearance
        if old_ForceApplyAppearance then
            hg.Appearance.ForceApplyAppearance = function(ply, tbl, noModelChange)
                if IsValid(ply) then
                    local job = RP.Teams[ply:Team()]
                    if job and job.blockAppearance then
                        ClearPlayerZCityAppearance(ply)
                        return -- Блокируем силовое применение
                    end
                end
                return old_ForceApplyAppearance(ply, tbl, noModelChange)
            end
        end
    end
end)

-- Резервный силовой сброс при спавне и смене профессии
local function CleanUpPlayerAppearance(ply)
    if not IsValid(ply) then return end

    local job = RP.Teams[ply:Team()]
    if job and job.blockAppearance then
        ClearPlayerZCityAppearance(ply)
        -- Даем Z-City 0.1 сек отработать, а затем жестко смываем его кастомизацию повторно
        timer.Simple(0.1, function()
            if not IsValid(ply) then return end
            ClearPlayerZCityAppearance(ply)
        end)
    end
end

hook.Add("PlayerSpawn", "RP_CleanAppearanceOnSpawn", CleanUpPlayerAppearance)
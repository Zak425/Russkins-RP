ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Арсенал"
ENT.Author = "Z-City"
ENT.Category = "ZCity Roleplay"
ENT.Spawnable = true

-- Конфигурация арсенала
ENT.Items = {
    {
        name = "Тяжелый бронежилет",
        desc = "Выдает бронежилет",
        icon = "icon16/shield.png",
        action = "entity",
        class = "ent_armor_vest2",
        cooldown = 120 -- в секундах
    },
    {
        name = "Пистолет Макарова",
        desc = "Табельное оружие",
        icon = "icon16/gun.png",
        action = "weapon",
        class = "weapon_makarov",
        cooldown = 120
    },
    {
        name = "Автомат АК-74У",
        desc = "Для особых ситуаций",
        icon = "icon16/bomb.png",
        action = "weapon",
        class = "weapon_ak74u",
        cooldown = 300
    },
    {
        name = "Патроны 9x18 мм (ПМ)",
        desc = "Запасной магазин к пистолету",
        icon = "icon16/bullet_blue.png",
        action = "ammo",
        class = "9x18 mm",
        amount = 24,
        cooldown = 60
    },
    {
        name = "Патроны 5.45x39 мм (АК)",
        desc = "Запасной магазин к автомату",
        icon = "icon16/bullet_red.png",
        action = "ammo",
        class = "5.45x39 mm",
        amount = 60,
        cooldown = 60
    }
}

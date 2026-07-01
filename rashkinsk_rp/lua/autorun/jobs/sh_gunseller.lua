TEAM_GUNSELLER = 2

RP.Teams[TEAM_GUNSELLER] = {
    name = "Продавец оружия",
    color = Color(200, 50, 50),
    weapons = { "weapon_hands_sh", "weapon_key", "weapon_phone" },
    description = "Легально (или не очень) продает стволы местным.",
    
    -- АССОРТИМЕНТ ДЛЯ ЗАКУПКИ В F4-МЕНЮ
    SupplierItems = {
        -- Оружие
        {
            name = "Пистолет Макарова",
            price = 1200,
            class = "weapon_makarov",
            isWeapon = true
        },
        {
            name = "Пистолет M1911",
            price = 1000,
            class = "weapon_m1911",
            isWeapon = true
        },
        {
            name = "Травмат",
            price = 500,
            class = "weapon_mp-80",
            isWeapon = true
        },
        {
            name = "Иж-43",
            price = 2500,
            class = "weapon_doublebarrel",
            isWeapon = true
        },
        {
            name = "Сайга-12",
            price = 4000,
            class = "weapon_saiga12",
            isWeapon = true
        },
        {
            name = "Мосинка",
            price = 1800,
            class = "weapon_mosin",
            isWeapon = true
        },
        {
            name = "СКС",
            price = 2200,
            class = "weapon_sks",
            isWeapon = true
        },
        {
            name = "Узи",
            price = 3500,
            class = "weapon_uzi",
            isWeapon = true
        },
        {   
            name = "ВПО-136",
            price = 4500,
            class = "weapon_vpo136",
            isWeapon = true
        },
        {
            name = "АКМ",
            price = 8000,
            class = "weapon_akm",
            isWeapon = true
        },
        {
            name = "Ак74у (Ксюха)",
            price = 6500,
            class = "weapon_ak74u",
            isWeapon = true
        },
        {
            name = "АК-74",
            price = 10000,
            class = "weapon_ak74",
            isWeapon = true
        },
        {
            name = "Подпольный АКМ",
            price = 7000,
            class = "weapon_akmwreked",
            isWeapon = true
        },
        -- Холодное оружие
        {
            name = "Молоток",
            price = 500,
            class = "weapon_hammer",
            isMelee = true
        },
        {
            name = "Карманный ножик",
            price = 500,
            class = "weapon_pocketknife",
            isMelee = true
        },
        {
            name = "Нож",
            price = 500,
            class = "weapon_sogknife",
            isMelee = true
        },
        -- Патроны
        {
            name = "Патроны 9x18 мм (Макаров/Травмат, x30)",
            price = 250,
            class = "ent_ammo_9x18mm",
            isAmmo = true
        },
        {
            name = "Патроны .45 ACP (M1911, x20)",
            price = 350,
            class = "ent_ammo_.45acp",
            isAmmo = true
        },
        {
            name = "Дробь 12/70 (Иж-43/Сайга, x10)",
            price = 400,
            class = "ent_ammo_12/70gauge",
            isAmmo = true
        },
        {
            name = "Пули 12/70 (Иж-43/Сайга, x10)",
            price = 500,
            class = "ent_ammo_12/70slug",
            isAmmo = true
        },
        {
            name = "Патроны 7.62x54R (Мосинка, x10)",
            price = 600,
            class = "ent_ammo_7.62x54mmr",
            isAmmo = true
        },
        {
            name = "Патроны 7.62x39 мм (СКС/ВПО/АКМ, x30)",
            price = 700,
            class = "ent_ammo_7.62x39mm",
            isAmmo = true
        },
        {
            name = "Патроны 9x19 мм (Узи, x30)",
            price = 300,
            class = "ent_ammo_9x19mmparabellum",
            isAmmo = true
        },
        {
            name = "Патроны 5.45x39 мм (АК-74/Ксюха, x30)",
            price = 600,
            class = "ent_ammo_5.45x39mm",
            isAmmo = true
        }
    }
}
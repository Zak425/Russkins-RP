TEAM_POLICE = 3

RP.Teams[TEAM_POLICE] = {
    name = "Милиция",
    color = Color(50, 50, 200),
    weapons = { "weapon_hands_sh", "weapon_key", "weapon_phone", "weapon_hg_tonfa", "weapon_handcuffs", "weapon_handcuffs_key", "weapon_tourniquet", "weapon_makarov", "weapon_bigbandage_sh", "weapon_medkit_sh" },
    ammo = {
        ["9x18 mm"] = 24 -- Выдаст 48 патронов (например, 6 магазинов по 8 патронов)
    },
    models = { 
        "models/player/kerry/policeru_03_patrol.mdl",
        "models/player/kerry/policeru_04_patrol.mdl",
        "models/player/kerry/policeru_05_patrol.mdl",
        "models/player/kerry/policeru_07_patrol.mdl",
        "models/player/kerry/policeru_06_patrol.mdl",
        "models/player/kerry/policeru_01_patrol.mdl",
        "models/player/kerry/policeru_05.mdl",
        "models/player/kerry/policeru_02_patrol.mdl",
        "models/player/kerry/policeru_06.mdl",
        "models/player/kerry/policeru_07.mdl",
        "models/player/kerry/policeru_02.mdl",
    },
    blockAppearance = true, -- ТЕГ БЛОКИРОВКИ КАСТОМИЗАЦИИ
    description = "Следит за порядком в городе.",
    salary = 2000
}
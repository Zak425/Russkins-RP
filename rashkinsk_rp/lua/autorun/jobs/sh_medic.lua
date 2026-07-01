TEAM_MEDIC = 4

RP.Teams[TEAM_MEDIC] = {
    name = "Скорая Помощь",
    color = Color(230, 230, 250),
    weapons = { "weapon_hands_sh", "weapon_key", "weapon_phone", "weapon_medkit_sh", "weapon_bigbandage_sh", "weapon_painkillers", "weapon_tourniquet", "weapon_morphine", "weapon_naloxone", "weapon_needle" },
    models = { 
        "models/player/Group03m/male_07.mdl","models/player/Group03m/male_05.mdl","models/player/Group03m/male_09.mdl","models/player/Group03m/male_08.mdl","models/player/Group03m/male_04.mdl"
    },
    blockAppearance = true, -- ТЕГ БЛОКИРОВКИ КАСТОМИЗАЦИИ
    description = "Оказывает медицинскую помощь пострадавшим.",
    salary = 1500,
    
    -- АССОРТИМЕНТ ДЛЯ ЗАКУПКИ В F4-МЕНЮ (МЕДИЦИНА)
    SupplierItems = {
        {
            name = "Аптечка",
            price = 350,
            class = "weapon_medkit_sh"
        },
        {
            name = "Большой бинт",
            price = 250,
            class = "weapon_bigbandage_sh"
        },
        {
            name = "Обезболивающие",
            price = 150,
            class = "weapon_painkillers"
        },
        {
            name = "Жгут",
            price = 100,
            class = "weapon_tourniquet"
        },
        {
            name = "Морфин",
            price = 400,
            class = "weapon_morphine"
        },
        {
            name = "Налоксон",
            price = 300,
            class = "weapon_naloxone"
        },
        {
            name = "Медицинская игла",
            price = 200,
            class = "weapon_needle"
        },
        {
            name = "Бинт",
            price = 100,
            class = "weapon_bandage_sh"
        }
    }
}
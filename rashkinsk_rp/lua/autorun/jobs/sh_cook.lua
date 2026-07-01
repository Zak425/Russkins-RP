TEAM_COOK = 5

RP.Teams[TEAM_COOK] = {
    name = "Повар",
    color = Color(255, 200, 50),
    weapons = { "weapon_hands_sh", "weapon_key", "weapon_phone" },
    description = "Готовит вкусную еду и продает её другим игрокам.",
    salary = 800,
    
    SupplierItems = {
        {
            name = "Плита для готовки",
            price = 1500,
            class = "ent_stove"
        },
        {
            name = "Сырое мясо",
            price = 50,
            class = "weapon_raw_meat"
        },
        {
            name = "Напиток",
            price = 30,
            class = "weapon_drink"
        },
        {
            name = "Снеки",
            price = 45,
            class = "weapon_snacks"
        }
    }
}

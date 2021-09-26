Config = {}

Config.Markers = {
    [0] = {
        Blip = { name = "Hunting Zone", coords = vector3(-1133.40, 4948.479, 222.26), sprite = 141, color = 1, scale = 1.2 },
        Pos = vector3(-1133.40, 4948.479, 222.26),
        Distance = 1.5,
        Peds = { 
            [0] = {
                coords = vector3(-1134.35, 4948.799, 221.26), heading = 247.55
            },
            [1] = {
                coords = vector3(-595.272, 5899.512, 24.348), heading = 178.5
            },
            [2] = {
                coords = vector3(-1137.49, 4940.250, 221.26), heading = 247.55
            }
         },
        Vehicle = { model = "mesa3", coords = vector3(-1123.31, 4933.765, 218.91), heading = 242.04 },
        HuntingZone = { coords = vector3(-595.272, 5899.512, 25.348) },
        SellMeat = { coords = vector3(-1136.40, 4939.853, 222.26) }
    }
}

Locale = {
    ['kill'] = '~w~Press ~o~E ~w~to kill',
    ['no_meat'] = '~r~You don\'t have enough meat.',
    ['sell_meat'] = '~w~Press ~o~E ~w~ to sell the meat',
    ['start_hunting'] = '~w~Press ~o~E ~w~ to start hunting',
    ['hunting_equipment'] = '~w~Press ~o~E ~w~ to prepare the hunting equipment',
    ['car_exists'] = '~r~There is a vehicle alredy spawned',
    ['gps'] = '~r~There is a vehicle alredy spawned',
}
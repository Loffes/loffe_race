Config = {}

Config.Strings = {
    ['drive_next'] = 'Kör till nästa ~y~checkpoint',
    ['start_npc'] = 'Klicka ~INPUT_CONTEXT~ för att starta race mot NPC',
    ['start_online'] = 'Klicka ~INPUT_CONTEXT~ för att starta race mot andra spelare',
    ['stop_online'] = 'Klicka ~INPUT_CONTEXT~ för att sluta vara redo'
}

Config.TPBack = true -- tp spelare till där man startar när racet är slut

Config.OnlineRace = {
    [1] = {
        Players = 3,
        Type = 'street_race', -- 'street_race' = eget fordon, 'event' = man får fordon
        Text = 'Klicka ~INPUT_CONTEXT~ för att köra ett race mot 2 andra spelare! (Eget fordon)',
        Start = {x = 2518.32, y = 1976.36, z = 19.09},
        Size = 5.5, 
        StartLine = {
            [1] = {x = 2498.56, y = 1983.25, z = 18.39, h = 27},
            [2] = {x = 2504.29, y = 1986.15, z = 18.46, h = 42},
            [3] = {x = 2500.21, y = 1984.2, z = 19.01, h = 28},
        },
        NumberOfZones = 11,
        Zones = {
            [1] = {x = 2490.99, y = 2004.07, z = 19.45},
            [2] = {x = 2462.04, y = 2182.04, z = 38.0},
            [3] = {x = 2332.49, y = 2438.84, z = 62.67},
            [4] = {x = 2290.45, y = 2184.35, z = 76.58},
            [5] = {x = 2165.56, y = 2446.77, z = 87.55},
            [6] = {x = 2055.97, y = 2419.84, z = 83.38},
            [7] = {x = 2031.41, y = 2347.62, z = 92.88},
            [8] = {x = 2125.73, y = 2409.28, z = 99.64},
            [9] = {x = 2164.33, y = 2128.36, z = 124.42},
            [10] = {x = 2282.78, y = 2057.74, z = 124.14},
            [11] = {x = 2357.52, y = 2272.24, z = 94.26}
        },
    },
    [2] = {
        Players = 2,
        Type = 'event',
        Text = 'Klicka ~INPUT_CONTEXT~ för att köra ett race mot 1 annan spelare (Får cross)',
        Vehicle = 'sanchez', -- fordon man får (om type = 'event')
        Start = {x = 833.92, y = 2406.88, z = 53.29},
        Size = 1.5, 
        StartLine = {
            [1] = {x = 835.16, y = 2403.99, z = 53.6, h = 260.0},
            [2] = {x = 834.92, y = 2408.49, z = 53.78, h = 258.0},
            [3] = {x = 838.07, y = 2406.46, z = 52.47, h = 265.0}
        },
        NumberOfZones = 17,
        Zones = {
            [1] = {x = 889.9, y = 2407.09, z = 48.53},
            [2] = {x = 963.21, y = 2467.93, z = 49.06},
            [3] = {x = 1062.89, y = 2437.45, z = 48.26},
            [4] = {x = 1157.31, y = 2471.15, z = 52.61},
            [5] = {x = 1165.36, y = 2336.65, z = 56.34},
            [6] = {x = 1135.93, y = 2253.15, z = 48.51},
            [7] = {x = 1100.15, y = 2409.92, z = 48.05},
            [8] = {x = 963.98, y = 2390.94, z = 49.36},
            [9] = {x = 961.59, y = 2353.98, z = 48.13},
            [10] = {x = 987.28, y = 2263.41, z = 46.6},
            [11] = {x = 1044.78, y = 2261.29, z = 42.59},
            [12] = {x = 1120.93, y = 2233.4, z = 47.27},
            [13] = {x = 1150.39, y = 2155.83, z = 51.9},
            [14] = {x = 1090.77, y = 2209.26, z = 47.95},
            [15] = {x = 939.23, y = 2248.64, z = 43.92},
            [16] = {x = 894.03, y = 2374.94, z = 49.49},
            [17] = {x = 844.19, y = 2405.23, z = 51.94},
        },
    }
}

Config.EntryPriceOffline = 5000

Config.OfflineRace = {
    --[[[1] = {
        Vehicle = 'sanchez',
        -- Start = {x = 2514.44, y = 1973.97, z = 19.0},
        Start = {x = 1.0, y = 1.0, z = 1.0},
        StartLine = {
            Player = {x = 2498.56, y = 1983.25, z = 18.39, h = 27},
            NPC = {
                {x = 2499.58, y = 1984.4, z = 18.47, h = 32},
                {x = 2501.01, y = 1985.47, z = 18.49, h = 34},
                {x = 2502.69, y = 1985.22, z = 18.5, h = 44},
                {x = 2504.29, y = 1986.15, z = 18.46, h = 42}
            },
        },
        NumberOfZones = 11,
        Zones = {
            [1] = {x = 2490.99, y = 2004.07, z = 19.45},
            [2] = {x = 2462.04, y = 2182.04, z = 38.0},
            [3] = {x = 2332.49, y = 2438.84, z = 62.67},
            [4] = {x = 2290.45, y = 2184.35, z = 76.58},
            [5] = {x = 2165.56, y = 2446.77, z = 87.55},
            [6] = {x = 2055.97, y = 2419.84, z = 83.38},
            [7] = {x = 2031.41, y = 2347.62, z = 92.88},
            [8] = {x = 2125.73, y = 2409.28, z = 99.64},
            [9] = {x = 2164.33, y = 2128.36, z = 124.42},
            [10] = {x = 2282.78, y = 2057.74, z = 124.14},
            [11] = {x = 2357.52, y = 2272.24, z = 94.26}
        },
    },]]
}
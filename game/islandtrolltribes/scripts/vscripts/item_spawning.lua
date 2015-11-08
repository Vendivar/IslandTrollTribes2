--[[

This handles spawning items randomly over the map at intervals
Code by Till Elton (Iced Coffee)

Globals related to item spawns, mostly taken from
https://github.com/island-troll-tribes/wc3-client/blob/1562854dd098180752f0f4a99df0c4968697b38b/src/lib/PublicLibrary.j
and
https://github.com/island-troll-tribes/wc3-client/blob/1562854dd098180752f0f4a99df0c4968697b38b/src/init/objects/Globals.j
]]--

-- How often a spawn wave occurs in seconds
GAME_ITEM_TICK_TIME         = 30

-- Spawnrates of items, seeded with initial rates from ITT1 globals file
TINDER_RATE                 = 5.00
FLINT_RATE                  = 3.00
STICK_RATE                  = 3.00
CLAYBALL_RATE               = 1.00
STONE_RATE                  = 1.00
MANACRYSTAL_RATE            = 0.00
MAGIC_RATE                  = 0.35

-- Relative rates start at 0 but will be set such that all should sum to one on first call of ITT:UpdateRelativePool
REL_TINDER_RATE             = 0
REL_FLINT_RATE              = 0
REL_STICK_RATE              = 0
REL_CLAYBALL_RATE           = 0
REL_STONE_RATE              = 0
REL_MANACRYSTAL_RATE        = 0
REL_MAGIC_RATE              = 0

-- Controls the base item spawn rate
ITEM_BASE                   = 2

-- Regions of the map, each has independant spawning to mitigate RNG
REGIONS                     = {}
--                            {xmin, xmax, ymin, ymax, spawnrate}
TOPLEFT                     = {-8000, -600, 8000, 500, 1}  
TOPRIGHT                    = {550, 8000, 8000, 800, 1}
BOTTOMRIGHT                 = {-1100, -8000, -600, -8000, 1}
BOTTOMLEFT                  = {950, 8000, -350, -8000, 1}
REGIONS[1]                  = TOPLEFT
REGIONS[2]                  = TOPRIGHT
REGIONS[3]                  = BOTTOMRIGHT
REGIONS[4]                  = BOTTOMLEFT

-- Handles one spawn wave
function ITT:OnItemThink()
    -- if its the first time, we need to set the relative values
    if REL_TINDER_RATE == 0 then
        ITT:UpdateRelativePool()
    -- over time the spawnrates change, tending from simple fire components, to components for more complex buildings, update these every spawn wave
    else
        ITT:AdjustItemSpawns()
    end
    for i=1, #REGIONS, 1 do
        for ii=1, math.floor(ITEM_BASE * REGIONS[i][5]), 1 do
            item = ITT:SpawnItem(REGIONS[i])
        end
    end
    return GAME_ITEM_TICK_TIME
end

-- Handles spawning in one region
function ITT:SpawnItem(island)
    local itemSpawned = ITT:GetItemFromPool()
    local item = CreateItem(itemSpawned, nil, nil)
    --item:SetPurchaseTime(Time)
    local randomVector = GetRandomVectorGivenBounds(island[1], island[2], island[3], island[4])
    CreateItemOnPositionSync(randomVector, item)
    item:SetOrigin(randomVector)
end

-- Updates the relative probabilties, called only when the actual probabilties are changed
-- They should always sum to one
function ITT:UpdateRelativePool()
    --print("Updating relative item probabilties")
    local Total = TINDER_RATE + FLINT_RATE + STICK_RATE + CLAYBALL_RATE + STONE_RATE + MANACRYSTAL_RATE + MAGIC_RATE
    REL_TINDER_RATE      = TINDER_RATE      / Total
    REL_FLINT_RATE       = FLINT_RATE       / Total
    REL_STICK_RATE       = STICK_RATE       / Total
    REL_CLAYBALL_RATE    = CLAYBALL_RATE    / Total
    REL_STONE_RATE       = STONE_RATE       / Total
    REL_MANACRYSTAL_RATE = MANACRYSTAL_RATE / Total
    REL_MAGIC_RATE       = MAGIC_RATE       / Total
end

-- Go though each item, order should not be relevant
function ITT:GetItemFromPool()
    local cumulProb = 0.0
    local rand      = RandomFloat(0,1)

    cumulProb = cumulProb + REL_TINDER_RATE
    if rand <= cumulProb then
        return "item_tinder"
    end

    cumulProb = cumulProb + REL_FLINT_RATE
    if rand <= cumulProb then
        return "item_flint"
    end

    cumulProb = cumulProb + REL_STICK_RATE
    if rand <= cumulProb then
        return "item_stick"
    end

    cumulProb = cumulProb + REL_CLAYBALL_RATE
    if rand <= cumulProb then
        return "item_ball_clay"
    end

    cumulProb = cumulProb + REL_STONE_RATE
    if rand <= cumulProb then
        return "item_stone"
    end

    cumulProb = cumulProb + REL_MANACRYSTAL_RATE
    if rand <= cumulProb then
        return "item_crystal_mana"
    end

    cumulProb = cumulProb + REL_MAGIC_RATE
    if rand <= cumulProb then
        return "item_magic_raw"
    end

    print("Should never happen, error in item spawning, commulative probability higher than items")
    print("cummulprob = " .. cumulProb)
    print("rand is " .. rand)
end

-- Item spawn distribution changes, later in the game it tends to a different ratio
-- From https://github.com/island-troll-tribes/wc3-client/blob/1562854dd098180752f0f4a99df0c4968697b38b/src/lib/PublicLibrary.j#L271-L292
function ITT:AdjustItemSpawns()
    --print("adjusting item spawns")
    FLINT_RATE = math.max(2.0,(FLINT_RATE-0.4))
    MANACRYSTAL_RATE = math.min(1.6,(MANACRYSTAL_RATE+0.2))
    STONE_RATE = math.min(3.3,(STONE_RATE+0.5))
    STICK_RATE = math.min(4.5,(STICK_RATE+0.5))
    TINDER_RATE = math.max(.7,(TINDER_RATE-0.6))
    CLAYBALL_RATE = math.min(1.85,(CLAYBALL_RATE+0.3))
    -- I don't get how item base works, it always seems too low in the wc3 file, it is disabled for the moment since it breaks everything, any help?
    -- ITEM_BASE = math.max(1.15,(ITEM_BASE-0.2))
    ITT:UpdateRelativePool()
end

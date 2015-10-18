function DebugSpawnAllHeroes(keys)
    local caster = keys.caster
    local unitTable = {     
        "npc_dota_hero_shadow_shaman",
        "npc_hero_herbmaster_tele_gatherer",
        "npc_hero_radar_tele_gatherer",
        "npc_hero_remote_tele_gatherer",
        "npc_dota_hero_huskar",
        "npc_hero_hunter_tracker",
        "npc_hero_hunter_warrior",
        "npc_hero_hunter_juggernaught",
        "npc_dota_hero_witch_doctor",
        "npc_hero_mage_elementalist",
        "npc_hero_mage_hypnotist",
        "npc_hero_mage_dementia_master",
        "npc_dota_hero_lion",
        "npc_hero_scout_observer",
        "npc_hero_scout_radar",
        "npc_hero_scout_spy",
        "npc_dota_hero_riki",
        "npc_hero_thief_escape_artist",
        "npc_hero_thief_contortionist",
        "npc_hero_thief_assassin",
        "npc_dota_hero_lycan",
        "npc_hero_beastmaster_packleader",
        "npc_hero_beastmaster_form_chicken",
        "npc_hero_beastmaster_shapeshifter",
        "npc_dota_hero_dazzle",
        "npc_hero_priest_booster",
        "npc_hero_priest_master_healer",
        "npc_hero_priest_sage"}

    for key,value in pairs(unitTable) do
        local spawnLocationX = (key-1)%4
        spawnLocationY = math.floor((key-1)/4)
        spawnLocation = Vector(1,0,0)*spawnLocationX*200 + Vector(0,-1,0)*spawnLocationY*300 + Vector(1,0,0)*200
        local unit = CreateUnitByName(value, caster:GetOrigin() + spawnLocation, true, nil, nil, caster:GetTeam())
        unit.vOwner = caster:GetOwner()
        unit:SetControllableByPlayer(caster:GetOwner():GetPlayerID(), true )
        unit:SetForwardVector(Vector(0,-1,0))
    end
end

function DebugSpawnAllCreeps(keys)
    print("Debug: Spawn All Creeps")
    local caster = keys.caster
    local owner = caster:GetOwner()
    local unitTable = {
        "npc_creep_fawn",
        "npc_creep_wolf_pup",
        "npc_creep_bear_cub",
        "npc_creep_mammoth_baby",
        "npc_creep_elk_pet",
        "npc_creep_elk_adult",
        "npc_creep_bear_jungle_adult",
        "npc_creep_drake_bone",
        "npc_creep_harpy_red",
        "npc_creep_bat_forest",
        "npc_creep_drake_nether",
        "npc_creep_fish",
        "npc_creep_fish_green",
        "npc_creep_elk_wild",
        "npc_creep_hawk",
        "npc_creep_wolf_jungle",
        "npc_creep_wolf_ice",
        "npc_creep_wolf_jungle_adult",
        "npc_creep_bear_jungle",
        "npc_creep_lizard",
        "npc_creep_panther",
        "npc_creep_panther_elder"
}
    for key,npcName in pairs(unitTable) do
        local spawnLocationX = (key-1)%6
        spawnLocationY = math.floor((key-1)/6)
        spawnLocation = Vector(1,0,0)*spawnLocationX*200 + Vector(0,-1,0)*spawnLocationY*300 + Vector(1,0,0)*200
        local unit = CreateUnitByName(npcName, caster:GetOrigin() + spawnLocation, true, nil, nil, caster:GetTeam())
        if unit == nil then
            print(npcName)
        end
        unit.vOwner = caster:GetOwner()
        unit:SetControllableByPlayer(caster:GetOwner():GetPlayerID(), true )
        unit:SetForwardVector(Vector(0,-1,0))
    end
end

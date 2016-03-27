var Root = $.GetContextPanel()
var hero = Players.GetPlayerHeroEntityIndex( Game.GetLocalPlayerID() )

// Global lazy toggle
GameUI.CustomUIConfig().ToggleCraftingList = function() {
    Show()
}

GameUI.CustomUIConfig().HideCraftingList = function() {
    Hide()
}

function CloseList() {
    GameUI.CustomUIConfig().ToggleCraftingList()
}

function CreateCraftingList()
{
    var values = CustomNetTables.GetAllTableValues("crafting")

    // Order: Basic Recipes first, then all the rest alphabetically
    CreateByName(values, "Recipes", false)
    CreateByName(values, "npc_building_armory", true)
    CreateByName(values, "npc_building_hut_witch_doctor", true)
    CreateByName(values, "npc_building_mix_pot", true)
    CreateByName(values, "npc_building_tannery", true)
    CreateByName(values, "npc_building_workshop", true) 
}

function CreateByName(values, name, bFold) {
    
    for (var i in values)
    {
        var crafting_table = values[i]
        if (crafting_table.key==name)
            CreateCraftingSection(name, crafting_table.value, Root, bFold, hero)
    }
}

function Hide() {
    Root.AddClass( "Hidden" )
}

function Show() {
    Root.RemoveClass( "Hidden" )
}

(function () {
    CreateCraftingList()
    Hide()
    GameEvents.Subscribe( "dota_player_update_hero_selection", Hide);
    GameEvents.Subscribe( "dota_player_update_query_unit", Hide);
    $.Msg("Done creating crafting list")
})();
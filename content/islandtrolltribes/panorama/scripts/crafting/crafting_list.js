var Root = $.GetContextPanel()
var hero = Players.GetPlayerHeroEntityIndex( Game.GetLocalPlayerID() )

function CreateCraftingList()
{
    var values = CustomNetTables.GetAllTableValues("crafting") //crafting.kv

    // Order: Basic Recipes first, then all the rest alphabetically
    CreateSectionByName(values, "Recipes", false)
    CreateSectionByName(values, "npc_building_armory", true)
    CreateSectionByName(values, "npc_building_hut_witch_doctor", true)
    CreateSectionByName(values, "npc_building_mixing_pot", true)
    CreateSectionByName(values, "npc_building_tannery", true)
    CreateSectionByName(values, "npc_building_workshop", true) 
}

function CreateSectionByName(values, name, bFold) {
    
    for (var i in values)
    {
        var crafting_table = values[i]
        if (crafting_table.key==name)
            CreateCraftingSection(name, crafting_table.value, Root, bFold, hero)
    }
}

(function () {
    CreateCraftingList() //Entry point
    Hide() //Initially hidden
    GameEvents.Subscribe( "dota_player_update_hero_selection", Hide);
    GameEvents.Subscribe( "dota_player_update_query_unit", Hide);
    $.Msg("Done creating crafting list")
})();

//-------------------------------------------------------

// Global lazy toggle
GameUI.CustomUIConfig().ToggleCraftingList = function() {
    Root.ToggleClass( "Hidden" )
    GameUI.AcceptWheeling = Root.BHasClass("Hidden")
}

GameUI.CustomUIConfig().HideCraftingList = function() {
    Hide()
}

function CloseList() {
    GameUI.CustomUIConfig().ToggleCraftingList()
}

function Hide() {
    Root.AddClass( "Hidden" )
}

function Show() {
    Root.RemoveClass( "Hidden" )
}
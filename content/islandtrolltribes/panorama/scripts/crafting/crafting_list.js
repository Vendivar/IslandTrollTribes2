var Root = $.GetContextPanel()
var hero = Players.GetPlayerHeroEntityIndex( Game.GetLocalPlayerID() )

// Global lazy toggle
GameUI.CustomUIConfig().ToggleCraftingList = function() {
    Root.visible = !Root.visible
    if ( Root.visible ) {
        FocusCraftingList() //When the focus is lost the list should be disappear
    }
}

function CloseList() {
    GameUI.CustomUIConfig().ToggleCraftingList()
}

function FocusCraftingList() {
   $("#CraftingRoot").SetAcceptsFocus(true)
   $("#CraftingRoot").SetFocus()
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
    Root.visible = false
}

function OnBlur(){
    Hide()
}

(function () {
    CreateCraftingList()
    $.Schedule(0.1, Hide)
    GameEvents.Subscribe( "dota_player_update_hero_selection", OnBlur);
    GameEvents.Subscribe( "dota_player_update_query_unit", OnBlur);
    $.Msg("Done creating crafting list")
})();
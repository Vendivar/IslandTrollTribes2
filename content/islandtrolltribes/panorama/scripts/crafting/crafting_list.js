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
/*
var inventory = {};
function checkInventoryUnique() {
  var item, item_name, i
  var change = false;
  for (i = 0; i < 6; i++) {
    item = Entities.GetItemInSlot(hero, i);
    if (item) {
      item_name = Abilities.GetAbilityName(item);
      if (item_name !== undefined) {
        if (inventory[i] !== item_name) {
          inventory[i] = item_name;
          change = true;
        }
      }
      else {
        inventory[i] = undefined;
      }
    }
    else {
      inventory[i] = undefined;
    }
  }

  if (change) {
    $.Msg("Inventory changed, updating crafting.");
    GameUI.popEvent("update_recipes");
  }

  $.Schedule(0.2, function(){ checkInventoryUnique() });
}
*/
(function () {
    GameUI.events = {};
    GameUI.event_callBacks = {};

    CreateCraftingList() //Entry point


    Hide() //Initially hidden
    GameEvents.Subscribe( "dota_player_update_hero_selection", Hide);
    GameEvents.Subscribe( "dota_player_update_query_unit", Hide);

    //checkInventoryUnique();

    $.Msg("Done creating crafting list")
})();

//-------------------------------------------------------

// Global lazy toggle
GameUI.CustomUIConfig().ToggleCraftingList = function() {
    Root.ToggleClass( "Hidden" )
    Root.SetFocus();
    if (Root.BHasClass("Hidden")) {
        GameUI.AcceptWheel();
    }
    else {
        GameUI.DenyWheel();
    }
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

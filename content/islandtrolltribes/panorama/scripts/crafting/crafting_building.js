var Root = $.GetContextPanel()
var iPlayerID = Players.GetLocalPlayer();
var hero = Players.GetPlayerHeroEntityIndex( iPlayerID )
var currentBuilding = 0
var fold = false

var Buildings = {}
Buildings['npc_building_armory'] = 1;
Buildings['npc_building_hut_witch_doctor'] = 1;
Buildings['npc_building_mix_pot'] = 1;
Buildings['npc_building_tannery'] = 1;
Buildings['npc_building_workshop'] = 1;

function Crafting_OnUpdateSelectedUnits() {
    var selectedEntities = Players.GetSelectedEntities( iPlayerID );
    var mainSelected = selectedEntities[0]
    var name = Entities.GetUnitName(mainSelected)

    if (Buildings[name])
    {
        HideCurrent()
        currentBuilding = name
        if (Buildings[name]==1)
        {
            var values = CustomNetTables.GetAllTableValues("crafting")
            for (var i in values)
            {
                var crafting_table = values[i]
                if (crafting_table.key==name)
                {
                    var panel = CreateCraftingSection(name, crafting_table.value, Root, false, mainSelected)
                    Buildings[name] = panel
                }
            }
        }
        else
        {
            MakeVisible(Buildings[name])
        }
    }
}

function HideCurrent() {
    Hide(Buildings[currentBuilding])
}

function Hide(panel) {
    if (panel !== undefined)
        panel.visible = false
}

function MakeVisible(panel) {
    panel.visible = true
}

(function () {
    GameEvents.Subscribe( "building_crafting_hide", HideCurrent );
    GameEvents.Subscribe( "dota_player_update_selected_unit", Crafting_OnUpdateSelectedUnits );
})();
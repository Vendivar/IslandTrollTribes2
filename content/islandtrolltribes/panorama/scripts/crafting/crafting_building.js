var Root = $.GetContextPanel()
var iPlayerID = Players.GetLocalPlayer();
var hero = Players.GetPlayerHeroEntityIndex( iPlayerID )
var currentBuilding = 0
var currentUnit = 0
var currentSelected
var fold = false

var Buildings = {}
var Units = {}
var UnFinishedBuildings = []
var KilledBuildings = []
Buildings['npc_building_armory'] = 1;
Buildings['npc_building_hut_witch_doctor'] = 1;
Buildings['npc_building_mixing_pot'] = 1;
Buildings['npc_building_tannery'] = 1;
Buildings['npc_building_workshop'] = 1;
Buildings['npc_building_craftmaster'] = 1;
Units['npc_dota_hero_shadow_shaman'] = 1;

function Crafting_OnUpdateSelectedUnits() {
    var selectedEntities = Players.GetSelectedEntities( iPlayerID );
    var mainSelected = selectedEntities[0]

    //If building is unfinished or killed, don't show the crafting menu.
    if (IsUnfinishedBuilding(mainSelected) || IsKilledBuilding(mainSelected) ) {
        return
    }

    //If building isn't owned by anyone on the team, don't show the crafting menu
    var controllable = IsControllableByMyTeam(iPlayerID, mainSelected)
    if (!controllable)
        return

    //$.Msg("Unit is owned by your team, continue showing the crafting UI")
    var name = Entities.GetUnitName(mainSelected)
    $.Msg("Crafting_OnUpdateSelectedUnits "+name)

    if (Buildings[name])
    {
        HideCurrent()
        currentBuilding = name
        currentSelected = mainSelected
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
    else
    {
        if (currentSelected == mainSelected) //Selected the same unit again
            HideCurrent()

        else //Selected a non crafting unit
            currentSelected = mainSelected
    }
}

function IsControllableByMyTeam(iPlayerID, entity) {
    var teamID = Game.GetPlayerInfo(iPlayerID).player_team_id
    var teamMembers = Game.GetPlayerIDsOnTeam(teamID)

    for (var i in teamMembers)
    {
        if (Entities.IsControllableByPlayer(entity, teamMembers[i]))
            return true
    }
    return false
}

function IsUnfinishedBuilding(building) {
    return UnFinishedBuildings.indexOf(building)!= -1 ? true: false
}

function IsKilledBuilding(building) {
    return KilledBuildings.indexOf(building)!= -1 ? true: false
}

function UpdateKilledBuildingList(event) {
    var name = Entities.GetUnitName(event.building)
    if (Buildings[name]) {
        KilledBuildings.push(event.building)
        if (event.building == currentBuilding) {
             Hide(Buildings[currentBuilding])
        }
    }

    if ( KilledBuildings.length > 10) {
        KilledBuildings.splice(0, 1) //Up to 10 killed buildings can be stored in this list
    }
}

function UpdateUnfinishedBuildingList(event) {
    var name = Entities.GetUnitName(event.building)
    if (Buildings[name]) {
         if (event.status == "started") {
             UnFinishedBuildings.push(event.building)
         }else if (event.status == "completed") {
             UnFinishedBuildings.splice(UnFinishedBuildings.indexOf(event.building), 1);
         }
    }
}

function ShowUnitCraftingMenu(event) {
    var unitName = event.unitName
    currentUnit = unitName
    var values = CustomNetTables.GetAllTableValues("crafting")
    if (Units[unitName]==1){
        for (var i in values)
        {
            var crafting_table = values[i]
            if (crafting_table.key==unitName) {
                var panel = CreateCraftingSection(unitName, crafting_table.value, Root, false, event.caster)
                Units[unitName] = panel
            }
        }
    } else {
         MakeVisible(Units[unitName])
    }
}

function HideCurrent() {
    Hide(Buildings[currentBuilding])
    Hide(Units[currentUnit])
}

function Hide(panel) {
    if (panel !== undefined)
        panel.visible = false
        GameUI.AcceptWheel();
}

function MakeVisible(panel) {
    panel.visible = true
    panel.SetFocus();
    GameUI.DenyWheel();
}

(function () {
    GameEvents.Subscribe( "building_crafting_hide", HideCurrent );
    GameEvents.Subscribe( "building_killed", UpdateKilledBuildingList);
    GameEvents.Subscribe( "show_crafting_menu", ShowUnitCraftingMenu);
    GameEvents.Subscribe( "dota_player_update_selected_unit", Crafting_OnUpdateSelectedUnits );
    GameEvents.Subscribe( "building_updated", UpdateUnfinishedBuildingList );
})();

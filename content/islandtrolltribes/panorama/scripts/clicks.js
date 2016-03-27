"use strict";

// Handle Right Button events
function OnRightButtonPressed()
{
    //$.Msg("OnRightButtonPressed")

    var iPlayerID = Players.GetLocalPlayer();
    var mainSelected = Players.GetLocalPlayerPortraitUnit(); 
    var hero = Players.GetPlayerHeroEntityIndex( iPlayerID );
    var mainSelectedName = Entities.GetUnitName( mainSelected );
    var cursor = GameUI.GetCursorPosition();
    var mouseEntities = GameUI.FindScreenEntities( cursor );
    //mouseEntities = mouseEntities.filter( function(e) { return e.entityIndex != mainSelected; } )
    
    var pressedShift = GameUI.IsShiftDown();

    // Builder Right Click
    if ( IsBuilder( mainSelected ) )
    {
        // Cancel BH
        SendCancelCommand();
    }

    for ( var e of mouseEntities )
    {
        var entityIndex = e.entityIndex
        if (Entities.IsInvulnerable( entityIndex ))
        {
            var order = {
                UnitIndex : hero,
                TargetIndex : entityIndex,
                OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_TARGET,
                QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
                ShowEffects : false
            };

            Game.PrepareUnitOrders( order );                

            return true
        }
        /*else if (IsRestBuilding(entityIndex) && IsTeamControlled(entityIndex) )
        {
            $.Msg("Right clicked on a rest building")
            GameEvents.SendCustomGameEventToServer( "player_rest_building", { entityIndex : entityIndex } );
            return false
        }*/
        else if (IsTeleportBeacon(entityIndex) && IsTeamControlled(entityIndex))
        {
            $.Msg("I think we lcicked on a tele beacon");
            // If we rightlicked a teleport beacon... 
            GameEvents.SendCustomGameEventToServer("player_teleport_beacon", { entityIndex: entityIndex });
            return true;
        }
    }

    return false;
}

function IsBush( entityIndex ){
    var name = Entities.GetUnitName( entityIndex )
    return (name.indexOf("bush") != -1)
}

function IsRestBuilding( entityIndex ) {
    var name = Entities.GetUnitName(entityIndex)
    return (name=="npc_building_hut_troll" || name=="npc_building_hut_mud"  || name=="npc_building_tent")
}

function IsTeamControlled ( entityIndex ) {
    var iPlayerID = Players.GetLocalPlayer();
    var hero = Players.GetPlayerHeroEntityIndex( iPlayerID );
    var teamID = Entities.GetTeamNumber( hero )
    var playersOnTeam = Game.GetPlayerIDsOnTeam( teamID );
    for (var i = 0; i < playersOnTeam.length; i++)
    {
        if (Entities.IsControllableByPlayer( entityIndex, playersOnTeam[i] ))
        {
            return true
        }
    };
    return false
}

// Builders require the "builder" label in its unit definition
function IsBuilder( entIndex ) {
    return (Entities.GetUnitLabel( entIndex ) == "builder")
}

function IsTeleportBeacon(entIndex)
{
    return (Entities.GetUnitName(entIndex) == "npc_building_teleport_beacon")
}

function ManageCraftListMouseEvents(eventName, arg){
    if ( eventName === "pressed" || eventName === "doublepressed"){
        var CONSUME_EVENT = true;
        var CONTINUE_PROCESSING_EVENT = false;
        var mPos = GameUI.GetCursorPosition();
        var GamePos = Game.ScreenXYToWorld(mPos[0], mPos[1]);
        if (GamePos != null && eventName === "pressed") { //User has clicked on the game area
            GameUI.CustomUIConfig().HideCraftingList()
        }
    }
    return CONTINUE_PROCESSING_EVENT
}


var maxCameraDistance = 1500
var minCameraDistance = 500

function ZoomEvent ( data )
{
    $.Msg(data) //this is the table containing all the passed info by Lua
    var distance = data.zoom_distance
    if (zoom_distance > maxCameraDistance) zoom_distance = maxCameraDistance
    if (zoom_distance < minCameraDistance) zoom_distance = minCameraDistance

        GameUI.SetCameraDistance( zoom_distance )

  // Do something with the zoom_distance here
}
   
    // jquery in use on DotA2 api?
    // just standard 'self calling' when the file loads. It's not really necessary but valve does it in their UIs
    // it could be done without the whole function encompasing just fine.
      
      // yeah, fair enough
(function()
{
        GameEvents.Subscribe ("zoom", ZoomEvent); //When the "zoom" event is detected, resolve ZoomEvent
})();



function ManageBuildHelperMouseEvents(eventName, arg) {
    var CONSUME_EVENT = true;
    var CONTINUE_PROCESSING_EVENT = false;
    var LEFT_CLICK = (arg === 0)
    var RIGHT_CLICK = (arg === 1)
    if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
        return CONTINUE_PROCESSING_EVENT;

    var mainSelected = Players.GetLocalPlayerPortraitUnit()

    // BuildingHelper clicks
    if ( eventName === "pressed" && IsBuilder(mainSelected))
    {
        // Left-click with a builder while BH is active
        if ( arg === 0 && state == "active")
        {
            return SendBuildCommand();
        }

        // Right-click (Cancel & Repair)
        if ( arg === 1 )
        {
            return OnRightButtonPressed();
        }
    }

    if ( eventName === "pressed" || eventName === "doublepressed")
    {
        if (LEFT_CLICK)
            return false;
        else if (RIGHT_CLICK)
            return OnRightButtonPressed();

    }
    
//      if ( eventName === "wheeled" )
//    {
//        arg == 1 ? cameraDistance -= 10 : cameraDistance += 10;
//      if (cameraDistance > maxCameraDistance) cameraDistance = maxCameraDistance
//        if (cameraDistance < minCameraDistance) cameraDistance = minCameraDistance
//       GameUI.SetCameraDistance( cameraDistance )
//        return CONSUME_EVENT;  
//    }

    return CONTINUE_PROCESSING_EVENT;
}

// Main mouse event callback
GameUI.SetMouseCallback( function( eventName, arg ) {
    ManageCraftListMouseEvents(eventName, arg) //CraftListener doesn't want to consume events
    return ManageBuildHelperMouseEvents( eventName, arg ) // It's up to Build helper to decide to consume the event or not.
} );
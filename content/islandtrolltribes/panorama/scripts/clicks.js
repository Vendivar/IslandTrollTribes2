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
        else if (IsRestBuilding(entityIndex) && IsTeamControlled(entityIndex) )
        {
            $.Msg("Right clicked on a rest building")
            GameEvents.SendCustomGameEventToServer( "player_rest_building", { entityIndex : entityIndex } );
            return false
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

function IsCustomBuilding( entityIndex ){
    var ability_building = Entities.GetAbilityByName( entityIndex, "ability_building")
    return (ability_building != -1)
}

// Builders require the "builder" label in its unit definition
function IsBuilder( entIndex ) {
    return (Entities.GetUnitLabel( entIndex ) == "builder")
}

// Main mouse event callback
GameUI.SetMouseCallback( function( eventName, arg ) {
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
    return CONTINUE_PROCESSING_EVENT;
} );
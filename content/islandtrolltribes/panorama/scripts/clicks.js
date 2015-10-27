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
	mouseEntities = mouseEntities.filter( function(e) { return e.entityIndex != mainSelected; } )
	
	var pressedShift = GameUI.IsShiftDown();

    for ( var e of mouseEntities )
    {
        var entityIndex = e.entityIndex
        if (IsBush(entityIndex) && (mainSelected == hero))
        {
            $.Msg("Right clicked on a bush")
            GameEvents.SendCustomGameEventToServer( "player_bush_gather", { entityIndex : entityIndex } );
            return true
        }
    }

	return false;
}

function IsBush( entityIndex ){
    var name = Entities.GetUnitName( entityIndex )
    return (name.indexOf("bush") != -1)
}

function IsCustomBuilding( entityIndex ){
    var ability_building = Entities.GetAbilityByName( entityIndex, "ability_building")
    return (ability_building != -1)
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

    if ( eventName === "pressed" || eventName === "doublepressed")
    {
        if (LEFT_CLICK) 
            return false;
        else if (RIGHT_CLICK) 
            return OnRightButtonPressed(); 
        
    }
    return CONTINUE_PROCESSING_EVENT;
} );
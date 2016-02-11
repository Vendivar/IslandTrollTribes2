"use strict";
var SpellBar = $.GetContextPanel()
var queryBuildings = [];
queryBuildings["npc_building_omnitower"] = "";

function UpdateTeamPanel()
{
	GameEvents.SendCustomGameEventToServer( "clearTeams", { });

	//Check radiant
	var radiantPlayers = Game.GetPlayerIDsOnTeam( DOTATeam_t.DOTA_TEAM_GOODGUYS );
    for ( var i = 0; i < radiantPlayers.length; ++i )
    {
        GameEvents.SendCustomGameEventToServer( "updateRadiant", { "key1" : radiantPlayers[i] });
    }

    //Check dire
	var direPlayers = Game.GetPlayerIDsOnTeam( DOTATeam_t.DOTA_TEAM_BADGUYS );
    for ( var i = 0; i < direPlayers.length; ++i )
    {
    	if (direPlayers[i] == Game.GetLocalPlayerID) {
           GameEvents.SendCustomGameEventToServer( "updateDire", { "key1" : direPlayers[i] });
    	}
    }

}
function UpdateDire(playerID)
{
	GameEvents.SendCustomGameEventToServer( "updateDire", { "key1" : playerID });
}
function UpdateRadiant( playerID )
{
   GameEvents.SendCustomGameEventToServer( "updateRadiant", { "key1" : playerID });
}

function MakeAbilityPanel( abilityListPanel, ability, queryUnit )
{
	var abilityPanel = $.CreatePanel( "Panel", abilityListPanel, "" );
	abilityPanel.SetAttributeInt( "ability", ability );
	abilityPanel.SetAttributeInt( "queryUnit", queryUnit );
	abilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/shared_action_bar_ability.xml", false, false );	
}

function UpdateAbilityList()
{
	var abilityListPanel = $( "#ability_list" );
	if ( !abilityListPanel )
		return;

	abilityListPanel.RemoveAndDeleteChildren();
	
	var queryUnit = Players.GetLocalPlayerPortraitUnit();
	
	// Buildings
	var unitName = Entities.GetUnitName(queryUnit);
	if (queryBuildings[unitName] == "") 
	{
		//UpdateTeamPanel;
		for ( var i = 0; i < Entities.GetAbilityCount( queryUnit ); ++i )
		{
			var ability = Entities.GetAbility( queryUnit, i );
			if ( ability == -1 )
				continue;

			if ( !Abilities.IsDisplayedAbility(ability) )
				continue;
			MakeAbilityPanel( abilityListPanel, ability, queryUnit );
		}
	}

    //Hero Float bar
	var iPlayerID = Players.GetLocalPlayer();
	var hero = Players.GetPlayerHeroEntityIndex( iPlayerID );
	var b = 19; 
  if ((Entities.GetAbilityByName( queryUnit , "ability_mage_quantum_nulldamage" )) != -1 )
  {
  	b = 11;
  }
  if ((Entities.GetAbilityByName( queryUnit , "ability_mage_nulldamage" )) != -1 )
  {
  	b = 6;
  }
  if ((Entities.GetAbilityByName( queryUnit , "ability_priest_theglow" )) != -1 )
  {
  	b = 6;
  }
  if ((Entities.GetAbilityByName( queryUnit , "ability_priest_angelicelemental" )) != -1 )
  {
  	b = 11;
  }
    if ((Entities.GetAbilityByName( queryUnit , "ability_priest_rangedheal" )) != -1 )
  {
  	b = 8;
  }
    if ((Entities.GetAbilityByName( queryUnit , "ability_priest_spiritwalk" )) != -1 )
  {
  	b = 8;
  }
  if (b != 19 ){
    GameUI.CustomUIConfig().EnableToggleSpellBarButton()
  } else {
    GameUI.CustomUIConfig().DisableToggleSpellBarButton()
  }
	if (hero == queryUnit){
		for ( var i = b; i < 16 ; ++i )
        {
			var ability = Entities.GetAbility( queryUnit, i );
			if ( ability == -1 ) {
				continue;
            }
			if ( !Abilities.IsDisplayedAbility(ability) ) {
				continue;
            }
            MakeAbilityPanel( abilityListPanel, ability, queryUnit );
		}
	}
}

(function()
{
	GameEvents.Subscribe( "dota_portrait_ability_layout_changed", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_pick_hero", UpdateTeamPanel );
	GameUI.CustomUIConfig().ToggleSpellBar = function() {
        SpellBar.visible = !SpellBar.visible
    }
	UpdateAbilityList(); // initial update
})();

"use strict";

function UpdateAbility()
{
	var ability = $.GetContextPanel().GetAttributeInt( "ability", -1 );
	var queryUnit = $.GetContextPanel().GetAttributeInt( "queryUnit", -1 );
	var abilityButton = $( "#AbilityButton" );
	var abilityName = Abilities.GetAbilityName( ability );

	var noLevel =( 0 == Abilities.GetLevel(ability) );
	var isCastable = !Abilities.IsPassive(ability) && !noLevel;
	var manaCost = Abilities.GetManaCost( ability );
	var hotkey = Abilities.GetKeybind( ability, queryUnit );
	var unitMana = Entities.GetMana( queryUnit );

	$.GetContextPanel().SetHasClass( "no_level", noLevel );
	$.GetContextPanel().SetHasClass( "is_passive", Abilities.IsPassive(ability) );
	$.GetContextPanel().SetHasClass( "no_mana_cost", ( 0 == manaCost ) );
	$.GetContextPanel().SetHasClass( "insufficient_mana", ( manaCost > unitMana ) );
	$.GetContextPanel().SetHasClass( "auto_cast_enabled", Abilities.GetAutoCastState(ability) );
	$.GetContextPanel().SetHasClass( "toggle_active", Abilities.GetToggleState(ability) );

	abilityButton.enabled = isCastable;
	
	$( "#HotkeyText" ).text = hotkey;
	
	$( "#AbilityImage" ).abilityname = abilityName;
	$( "#AbilityImage" ).contextEntityIndex = ability;
	
	$( "#ManaCost" ).text = manaCost;
	
	if ( Abilities.IsCooldownReady( ability ) )
	{
		$.GetContextPanel().SetHasClass( "cooldown_ready", true );
		$.GetContextPanel().SetHasClass( "in_cooldown", false );
	}
	else
	{
		$.GetContextPanel().SetHasClass( "cooldown_ready", false );
		$.GetContextPanel().SetHasClass( "in_cooldown", true );
		var cooldownLength = Abilities.GetCooldownLength( ability );
		var cooldownRemaining = Abilities.GetCooldownTimeRemaining( ability );
		var cooldownPercent = Math.ceil( 100 * cooldownRemaining / cooldownLength );
		$( "#CooldownTimer" ).text = Math.ceil( cooldownRemaining );
		$( "#CooldownOverlay" ).style.width = cooldownPercent+"%";
	}
	
	$.Schedule( 0.1, UpdateAbility );
}

function AbilityShowTooltip()
{
	var ability = $.GetContextPanel().GetAttributeInt( "ability", -1 );
	var queryUnit = $.GetContextPanel().GetAttributeInt( "queryUnit", -1 );
	var abilityButton = $( "#AbilityButton" );
	var abilityName = Abilities.GetAbilityName( ability );
	// If you don't have an entity, you can still show a tooltip that doesn't account for the entity
	//$.DispatchEvent( "DOTAShowAbilityTooltip", abilityButton, abilityName );
	
	// If you have an entity index, this will let the tooltip show the correct level / upgrade information
	$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", abilityButton, abilityName, queryUnit );
}

function AbilityHideTooltip()
{
	var abilityButton = $( "#AbilityButton" );
	$.DispatchEvent( "DOTAHideAbilityTooltip", abilityButton );
}

function ActivateAbility()
{
	var ability = $.GetContextPanel().GetAttributeInt( "ability", -1 );
	var queryUnit = $.GetContextPanel().GetAttributeInt( "queryUnit", -1 );
	Abilities.ExecuteAbility( ability, queryUnit, false );
}

function DoubleClickAbility()
{
	var ability = $.GetContextPanel().GetAttributeInt( "ability", -1 );
	var queryUnit = $.GetContextPanel().GetAttributeInt( "queryUnit", -1 );
	Abilities.CreateDoubleTapCastOrder( ability, queryUnit );
}

function RightClickAbility()
{
	var ability = $.GetContextPanel().GetAttributeInt( "ability", -1 );
	var queryUnit = $.GetContextPanel().GetAttributeInt( "queryUnit", -1 );
	if ( Abilities.IsAutocast(ability) )
	{
		Game.PrepareUnitOrders( { OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO, AbilityIndex: ability } );
	}
}

function RebuildAbilityUI()
{
	var ability = $.GetContextPanel().GetAttributeInt( "ability", -1 );
	var queryUnit = $.GetContextPanel().GetAttributeInt( "queryUnit", -1 );
	var abilityLevelContainer = $( "#AbilityLevelContainer" );
	abilityLevelContainer.RemoveAndDeleteChildren();
	var currentLevel = Abilities.GetLevel( ability );
	for ( var lvl = 0; lvl < Abilities.GetMaxLevel( ability ); lvl++ )
	{
		var levelPanel = $.CreatePanel( "Panel", abilityLevelContainer, "" );
		levelPanel.AddClass( "LevelPanel" );
		levelPanel.SetHasClass( "active_level", ( lvl < currentLevel ) );
		levelPanel.SetHasClass( "next_level", ( lvl == currentLevel ) );
	}
}

(function()
{
	GameEvents.Subscribe( "dota_ability_changed", RebuildAbilityUI ); // major rebuild
	RebuildAbilityUI();
	UpdateAbility(); // initial update of dynamic state
})();



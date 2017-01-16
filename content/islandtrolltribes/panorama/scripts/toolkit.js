"use strict";

function Cast (argument) {
    $.Msg("Cast ",argument)

    GameEvents.SendCustomGameEventToServer( "player_"+argument, {} );
}

function MouseOver(argument) {
    $.Msg("MouseOver "+argument)
    $("#"+argument).AddClass("Hover")
    $("#label_"+argument).visible = true;
    $("#label_"+argument).text = $.Localize(argument);

    $.DispatchEvent( "DOTAShowAbilityTooltip", $("#"+argument), argument );
}

function MouseOut(argument) {
    $.Msg("MouseOut "+argument)
    $("#"+argument).RemoveClass("Hover")
    $("#label_"+argument).visible = false;

    $.DispatchEvent( "DOTAHideAbilityTooltip", $("#"+argument) );
}

function DropAllItems() {
    var localPlayer = Players.GetLocalPlayer();
    var entIndex = Players.GetPlayerHeroEntityIndex(localPlayer);

    var Ability = Entities.GetAbilityByName(entIndex, "ability_drop_items");
    Abilities.ExecuteAbility(Ability, entIndex, false);
}

(function () {
    $.Msg("Toolkit Load");
    Game.AddCommand("+TogglePanic", function() {Cast("panic")}, "", 0);
    //Game.AddCommand("+DropAllItems", DropAllItems, "", 0);
    Game.AddCommand("+DropAllItems", function() {Cast("dropallitems")}, "", 0);
    Game.AddCommand("SleepOutside", function() {Cast("sleep_outside")}, "", 0);
    Game.AddCommand("DropRawMeat", function() {Cast("drop_meat")}, "", 0);
    Game.AddCommand("DropAllRawMeat", function() {Cast("drop_all_meat")}, "", 0);
    GameUI.SetCameraDistance( 1500 ) //Added default zoom levels
})();

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

(function () {
    $.Msg("Toolkit Load")
})();
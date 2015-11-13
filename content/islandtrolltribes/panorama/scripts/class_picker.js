"use strict";
//GameUI.SetCameraDistance( 1150 ); 
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false );      //Lefthand flyout scoreboard.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false );     //Shop portion of the Inventory.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, false );     //Quickbuy.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false );      //Courier controls.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false );      //Glyph.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false );      //Suggested items shop panel.
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS, false );      //Hides items to use panorama inventory replication

var currentlySelected = ""
var gatherers = 0

$("#btn_beastmaster").picked = false
$("#btn_gatherer").picked = false
$("#btn_hunter").picked = false
$("#btn_mage").picked = false
$("#btn_priest").picked = false
$("#btn_scout").picked = false
$("#btn_thief").picked = false

function Select (argument) {

    $.Msg("Selected ",argument)

    // Dont let "full" buttons be clicked
    if ($("#btn_"+argument).picked) return

    if (currentlySelected != "")
    {
        // If the currently selected was picked by someone else, don't update it
        if (! $("#btn_"+currentlySelected).picked)
        {
            $("#vid_"+currentlySelected).visible = false;
            $("#btn_"+currentlySelected).SetImage( "s2r://panorama/images/class_picker/"+currentlySelected+".png" )
        }
    }

    // Update the currently selected button
    currentlySelected = argument
    $("#vid_"+currentlySelected).visible = true;
    $("#btn_"+currentlySelected).SetImage( "s2r://panorama/images/class_picker/"+currentlySelected+"_hover.png" )

    $("#SelectText").text = $.Localize("Select_"+argument)
}

function MouseOver(argument) {
    $.Msg($("#vid_"+argument))
    if (!$("#btn_"+argument).picked)
    {
        $("#btn_"+argument).SetImage( "s2r://panorama/images/class_picker/"+argument+"_hover.png" )
        $("#ClassText").text = $.Localize("Description_"+argument);
        $("#vid_"+argument).visible = true;
        if (currentlySelected != "")
            $("#vid_"+currentlySelected).visible = false;
    }
}

function MouseOut(argument) {
    if (currentlySelected != argument && !$("#btn_"+argument).picked)
    {
        $("#btn_"+argument).SetImage( "s2r://panorama/images/class_picker/"+argument+".png" )
        $("#vid_"+argument).visible = false;

        if (currentlySelected != "")
        {
            $("#ClassText").text = $.Localize("Description_"+currentlySelected);
            $("#vid_"+currentlySelected).visible = true;
        }
        else
        {
            $("#ClassText").text = "";
        }
    }
}

function MouseOverPick(){
    if (currentlySelected == "")
        $("#SelectText").text = $.Localize("RandomClass");

    $("#SelectButtonImg").SetImage( "s2r://panorama/images/class_picker/pick_hover.png" )
}

function MouseOutPick() {
    if (currentlySelected == "")
        $("#SelectText").text = $.Localize("SelectText");
    $("#SelectButtonImg").SetImage( "s2r://panorama/images/class_picker/pick.png" )
}

function ChooseClass() {
    $.Msg("Class Chosen:", currentlySelected)
    if (currentlySelected == "")
        currentlySelected = "random"

    // Stop the videos
    $("#vid_beastmaster").DeleteAsync( 0 )
    $("#vid_gatherer").DeleteAsync( 0 )
    $("#vid_hunter").DeleteAsync( 0 )
    $("#vid_mage").DeleteAsync( 0 )
    $("#vid_priest").DeleteAsync( 0 )
    $("#vid_scout").DeleteAsync( 0 )
    $("#vid_thief").DeleteAsync( 0 )

    GameEvents.SendCustomGameEventToServer( "player_selected_class", { selected_class : currentlySelected } );
}

// Someone on the team has selected a class, check the class-per-team restriction and mark the button full
function TeamUpdate(keys) {
    var class_name = keys.class_name
    var player_name = keys.player_name

    $.Msg("Player "+player_name+" picked "+class_name)

    // Limit for gatherer is 2 instead of 1 like the rest of the classes
    if (class_name == "gatherer")
        gatherers++      

    if (class_name != "gatherer" || (class_name == "gatherer" && gatherers == 2))
    {
        $("#btn_"+class_name).SetImage( "s2r://panorama/images/class_picker/"+class_name+"_full.png" )
        $("#btn_"+class_name).picked = true;
    }

    if (class_name == "gatherer" && gatherers == 2)
        $("#"+class_name+"_players2").text = player_name;
    else
        $("#"+class_name+"_players").text = player_name;

    if (currentlySelected == class_name)
    {
        $.Msg("someone took another players selected troll")
        $("#vid_"+currentlySelected).visible = false;
        $("#ClassText").text = "";
        $("#SelectText").text = $.Localize("SelectText");
        currentlySelected = ""
    }
}

(function () {
    $.Msg("Class Picker Load")

    GameEvents.Subscribe( "team_update_class", TeamUpdate );

    $("#vid_beastmaster").visible = false;
    $("#vid_gatherer").visible = false;
    $("#vid_hunter").visible = false;
    $("#vid_mage").visible = false;
    $("#vid_priest").visible = false;
    $("#vid_scout").visible = false;
    $("#vid_thief").visible = false;

})();
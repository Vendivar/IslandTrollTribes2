"use strict";

var currentlySelected = ""

function Select (argument) {
    $.Msg("Selected ",argument)

    if (currentlySelected != "")
    {
        $("#vid_"+currentlySelected).visible = false;
        $("#btn_"+currentlySelected).style["background-image"] = "url('file://{images}/class_picker/"+currentlySelected+".png');"
    }

    currentlySelected = argument
    $("#vid_"+currentlySelected).visible = true;

    var image_path = "url('file://{images}/class_picker/"+currentlySelected+"_hover.png');"
    $("#btn_"+currentlySelected).style["background-image"] = image_path 

    $("#SelectText").text = $.Localize("Select_"+argument)
}

function MouseOver(argument) {
    $("#btn_"+argument).style["background-image"] = "url('file://{images}/class_picker/"+argument+"_hover.png');"
    $("#ClassText").text = $.Localize("Description_"+argument);
    $("#vid_"+argument).visible = true;
}

function MouseOut(argument) {
    if (currentlySelected != argument){
        $("#btn_"+argument).style["background-image"] = "url('file://{images}/class_picker/"+argument+".png');"
        $("#vid_"+argument).visible = false;
        $("#ClassText").text = "";
    }
}

function ChooseClass() {
    $.Msg("Class Chosen:", currentlySelected)
    GameEvents.SendCustomGameEventToServer( "player_selected_class", { selected_class : currentlySelected } );
}

(function () {
    $.Msg("Class Picker Load")

    $("#vid_beastmaster").visible = false;
    $("#vid_gatherer").visible = false;
    $("#vid_hunter").visible = false;
    $("#vid_mage").visible = false;
    $("#vid_priest").visible = false;
    $("#vid_scout").visible = false;
    $("#vid_thief").visible = false;

})();
"use strict";
var first_time = false;
var subclassPickerVisible;
var locked = Players.GetLevel(Game.GetLocalPlayerID()) < 6;
var class_name;
var heroToClass = [];
heroToClass['npc_dota_hero_lycan'] = "beastmaster";
heroToClass['npc_dota_hero_shadow_shaman'] = "gatherer";
heroToClass['npc_dota_hero_huskar'] = "hunter";
heroToClass['npc_dota_hero_witch_doctor'] = "mage";
heroToClass['npc_dota_hero_dazzle'] = "priest";
heroToClass['npc_dota_hero_lion'] = "scout";
heroToClass['npc_dota_hero_riki'] = "thief";

function UnlockSubclassPick() {
    $.Msg("Player ",Players.GetLocalPlayer()," unlocked subclass")
    $("#TogglePicker").RemoveClass("Locked")
    $("#TogglePicker").AddClass("Unlocked")
	var hero_name = Entities.GetUnitName(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ))
    class_name = heroToClass[hero_name]
    locked = false;
}

function ShowSubclassPick() {
		
    $("#SubclassTitle1").text = $.Localize(class_name+"_sub1_name")
    $("#SubclassTitle2").text = $.Localize(class_name+"_sub2_name")
    $("#SubclassTitle3").text = $.Localize(class_name+"_sub3_name")

    $("#SubclassImage1").SetImage( "s2r://panorama/images/subclass_picker/"+class_name+"_sub1.png" )
    $("#SubclassImage2").SetImage( "s2r://panorama/images/subclass_picker/"+class_name+"_sub2.png" )
    $("#SubclassImage3").SetImage( "s2r://panorama/images/subclass_picker/"+class_name+"_sub3.png" )

    $("#SubclassDesc1").text = $.Localize(class_name+"_sub1_desc")
    $("#SubclassDesc2").text = $.Localize(class_name+"_sub2_desc")
    $("#SubclassDesc3").text = $.Localize(class_name+"_sub3_desc")
}

function ChooseSubclass(num) {
    GameEvents.SendCustomGameEventToServer( "player_selected_subclass", { subclassID : num } );
    $("#SubclassPicker").AddClass("Hidden")
    $("#TogglePicker").AddClass("Hidden") //Could be made into a different image/button for subclass-related stuff
}

function MouseOver(num) {
    if (locked) return

    $("#SubclassImage"+num).SetImage( "s2r://panorama/images/subclass_picker/"+class_name+"_sub"+num+"_glow.png" )
}

function MouseOut(num) {
    if (locked) return

    $("#SubclassImage"+num).SetImage( "s2r://panorama/images/subclass_picker/"+class_name+"_sub"+num+".png" )
}

function TogglePicker() {
    if (locked) return

    subclassPickerVisible = !subclassPickerVisible

    $.Msg("TogglePicker, Visible: ",subclassPickerVisible)
    if (subclassPickerVisible)
    {
        $("#SubclassPicker").RemoveClass("Hidden")
        $("#TogglePicker").AddClass("Hover")
        ShowSubclassPick()
    }
    else
    {
        $("#SubclassPicker").AddClass("Hidden")
        $("#TogglePicker").RemoveClass("Hover")
    }
}


function ClosePicker() {
    $.Msg("Closed Picker")
    subclassPickerVisible = false;
    $("#SubclassPicker").AddClass("Hidden")
    $("#TogglePicker").RemoveClass("Hover")
}

function MouseOverPicker() {
    if (!subclassPickerVisible && !locked)
    {
        $("#TogglePicker").AddClass("Hover")
    }
}

function MouseOutPicker() {
    if (!subclassPickerVisible && !locked)
    {
        $("#TogglePicker").RemoveClass("Hover")
    }
}

(function () {
    $.Msg("Subclass Picker Load")

    $("#TogglePicker").AddClass("Locked")
    $("#SubclassPicker").AddClass("Hidden")
    subclassPickerVisible = false;
    
    var hero_name = Entities.GetUnitName(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ))
    class_name = heroToClass[hero_name]

    GameEvents.Subscribe( "player_unlock_subclass", UnlockSubclassPick );
})();
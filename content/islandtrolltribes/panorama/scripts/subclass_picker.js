"use strict";

GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false );      //Lefthand flyout scoreboard.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false );     //Shop portion of the Inventory.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, false );     //Quickbuy.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false );      //Courier controls.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false );      //Glyph.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false );      //Suggested items shop panel.

var subclassPickerVisible;
var class_name;
var heroToClass = [];
heroToClass['npc_dota_hero_lycan'] = "beastmaster";
heroToClass['npc_dota_hero_shadow_shaman'] = "gatherer";
heroToClass['npc_dota_hero_huskar'] = "hunter";
heroToClass['npc_dota_hero_witch_doctor'] = "mage";
heroToClass['npc_dota_hero_dazzle'] = "priest";
heroToClass['npc_dota_hero_lion'] = "scout";
heroToClass['npc_dota_hero_riki'] = "thief";

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

function MouseOver(num) {
    $.Msg(num)

    $("#SubclassImage"+num).SetImage( "s2r://panorama/images/subclass_picker/"+class_name+"_sub"+num+"_glow.png" )
}

function MouseOut(num) {
    $.Msg(num)

    $("#SubclassImage"+num).SetImage( "s2r://panorama/images/subclass_picker/"+class_name+"_sub"+num+".png" )
}

function TogglePicker() {
    subclassPickerVisible = !subclassPickerVisible

    $.Msg("TogglePicker, Visible: ",subclassPickerVisible)
    if (subclassPickerVisible)
    {
        $("#SubclassPicker").RemoveClass("Hidden")
        ShowSubclassPick()
    }
    else
        $("#SubclassPicker").AddClass("Hidden")
}

(function () {
    $.Msg("Subclass Picker Load")

    $("#SubclassPicker").AddClass("Hidden")
    subclassPickerVisible = false;
    var hero_name = Entities.GetUnitName(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ))
    class_name = heroToClass[hero_name]

    //GameEvents.Subscribe( "team_update_class", TeamUpdate );
})();
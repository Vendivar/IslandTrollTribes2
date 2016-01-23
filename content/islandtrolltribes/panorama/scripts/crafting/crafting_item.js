var Root = $.GetContextPanel()
var LocalPlayerID = Game.GetLocalPlayerID()
var itemName = Root.itemname

if (itemName.indexOf("item_") > -1)
    itemName = itemName.slice(5)

$('#Item').SetImage( "s2r://panorama/images/items/"+itemName+".png" )

var label = $.CreatePanel("Label", Root, "CraftLabel")
label.text = "CRAFT"
label.visible = false
label.hittest = false

function ShowToolTip(){ 
    var abilityButton = $( "#Item" );
    $.Msg("Show tooltip ",itemName)
    $.DispatchEvent( "DOTAShowAbilityTooltip", abilityButton, "item_"+itemName );

    if (Root.BHasClass("GlowGreen"))
    {
        Root.AddClass("GlowBright")
        label.visible = true
    }
}

function HideToolTip(){
    var abilityButton = $( "#Item" );
    $.DispatchEvent( "DOTAHideAbilityTooltip", abilityButton );
    Root.RemoveClass("GlowBright")
    label.visible = false
}
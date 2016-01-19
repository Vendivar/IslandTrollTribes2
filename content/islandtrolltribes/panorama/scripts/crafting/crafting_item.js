var Root = $.GetContextPanel()
var LocalPlayerID = Game.GetLocalPlayerID()
var itemName = Root.itemname

if (itemName.indexOf("item_") > -1)
    itemName = itemName.slice(5)

$('#Item').SetImage( "s2r://panorama/images/items/"+itemName+".png" )

function ShowToolTip(){ 
    var abilityButton = $( "#Item" );
    $.Msg("Show tooltip ",itemName)
    $.DispatchEvent( "DOTAShowAbilityTooltip", abilityButton, "item_"+itemName );
}

function HideToolTip(){
    var abilityButton = $( "#Item" );
    $.DispatchEvent( "DOTAHideAbilityTooltip", abilityButton );
}
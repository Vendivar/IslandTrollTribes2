function InstatiateCraftingItem(parent){
    var label = $.CreatePanel("Label", parent, "CraftLabel")
    label.text = "CRAFT"
    label.visible = false
    label.hittest = false

    var itemName = parent.itemname

    if (itemName.indexOf("item_") > -1)
        itemName = itemName.slice(5)

    var itemPanel = parent.FindChildTraverse("Item")
    itemPanel.SetImage( "s2r://panorama/images/items/"+itemName+".png" )
    itemPanel.SetPanelEvent('onmouseover', function ShowToolTip()
    {
        $.Msg("Show tooltip ",itemName)
        $.DispatchEvent( "DOTAShowAbilityTooltip", itemPanel, "item_"+itemName );

        if (parent.BHasClass("GlowGreen"))
        {
            parent.AddClass("GlowBright")
            label.visible = true
        }
    })

    itemPanel.SetPanelEvent('onmouseout', function HideToolTip()
    {
        $.DispatchEvent( "DOTAHideAbilityTooltip", itemPanel );
        parent.RemoveClass("GlowBright")
        label.visible = false
    })
}




function InstantiateCraftingSection(panel) {
    var visible = !panel.bFold

    var toggleButton = panel.FindChildTraverse("Toggle")
    toggleButton.SetPanelEvent('onactivate', function FoldSection()
    {
        visible = !visible
        $.Msg("Visible ",visible)
        var childNum = panel.GetChildCount()
        for (var i = 0; i < childNum; i++) {
            var child = panel.GetChild( i )
            if (child.id != "Toggle")
                child.visible = visible
        };

        // Update the fold icon
        if (visible)
            $('#FoldIcon').SetImage("s2r://panorama/images/crafting/minus.png"); 
        else
            $('#FoldIcon').SetImage("s2r://panorama/images/crafting/plus.png");
    })

    panel.FindChildTraverse("CraftingSectionTitle").text = $.Localize(panel.name)
    $.Msg("Instantiated Crafting Section")
}
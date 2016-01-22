var Root = $.GetContextPanel()
var visible = !Root.bFold

$('#CraftingListTitle').text = $.Localize(Root.name)

function FoldSection()
{
    visible = !visible
    $.Msg("Visible ",visible)
    var childNum = Root.GetChildCount()
    for (var i = 0; i < childNum; i++) {
        var child = Root.GetChild( i )
        if (child.id !="Toggle")
            child.visible = visible
    };
}
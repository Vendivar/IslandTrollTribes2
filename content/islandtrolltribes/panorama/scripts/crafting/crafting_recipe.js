var Root = $.GetContextPanel()
var LocalPlayerID = Game.GetLocalPlayerID()
var ingredients = Root.ingredients
var itemName = Root.itemname

for (var i = 0; i < ingredients.length; i++) {
    MakeItemPanel(ingredients[i], ingredients.length, i)
};

var equal = $.CreatePanel("Label", Root, "EqualSign")
equal.text = " ="

// Resulting from craft
MakeItemPanel(itemName, 0)

function MakeItemPanel(name, elements, num) {
    var item = $.CreatePanel("Panel", Root, name)
    item.itemname = name
    item.elements = elements
    item.BLoadLayout("file://{resources}/layout/custom_game/crafting/crafting_item.xml", false, false);
    
    /*if (elements>0)
    {
        var spacing = 70/elements
        item.style["width"] = spacing+"%"
    }*/
}

/* 
    Entities.HasItemInInventory( integer nEntityIndex, cstring pItemName ) 
    Entities.GetItemInSlot( integer nEntityIndex, integer nSlotIndex )
*/
var Root = $.GetContextPanel()
var LocalPlayerID = Game.GetLocalPlayerID()
var hero = Players.GetPlayerHeroEntityIndex( LocalPlayerID )
var ingredients = Root.ingredients
var table = Root.table
var itemName = Root.itemname
var itemsRequired = []

for (var i = 0; i < ingredients.length; i++) {
    MakeItemPanel(ingredients[i], ingredients.length, i)
};

var equal = $.CreatePanel("Label", Root, "EqualSign")
equal.text = "="

// Resulting from craft
MakeItemPanel(itemName, 0)

CheckInventory()

function MakeItemPanel(name, elements, num) {
    var item = $.CreatePanel("Panel", Root, name)
    item.itemname = name
    item.elements = elements

    // Track how many of this item does the recipe need
    itemsRequired[name] ? itemsRequired[name]++ : itemsRequired[name]=1

    if (num)
    {
        item.count = itemsRequired[name]
    }
    item.BLoadLayout("file://{resources}/layout/custom_game/crafting/crafting_item.xml", false, false);
    
    /*if (elements>0)
    {
        var spacing = 70/elements
        item.style["width"] = spacing+"%"
    }*/
}

function CheckInventory()
{
    var meetsAllIngredients = true

    // Build an array of items (with count) in inventory 
    var itemsOnInventory = []
    for (var i = 0; i < 6; i++) {
        var item = Entities.GetItemInSlot( hero, i )
        if (item)
        {
            var item_name = Abilities.GetAbilityName(item)
            itemsOnInventory[item_name] ? itemsOnInventory[item_name]++ : itemsOnInventory[item_name]=1
        }
    };

    if (Root.visible)
    {
        var childNum = Root.GetChildCount()
        for (var i = 0; i < childNum; i++) {
            var child = Root.GetChild(i)
            if (Entities.HasItemInInventory( hero, child.itemname ) && itemsOnInventory[child.itemname] > 0)
            {
                //$.Msg(itemName, " Requires ",itemsRequired[child.itemname], " ", child.itemname, " | Has ", itemsOnInventory[child.itemname])
                itemsOnInventory[child.itemname]--
                AddGlow(child)
            }
        };
    }

    $.Schedule(1, CheckInventory)
}

function AddGlow(panel) {
    panel.style['box-shadow'] = "0px 0px 100% gold";
}

function RemoveGlow(panel) {
    panel.style['box-shadow'] = "";
}

/* 
    
    Entities.GetItemInSlot( integer nEntityIndex, integer nSlotIndex )
*/
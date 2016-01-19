var Root = $.GetContextPanel()
var LocalPlayerID = Game.GetLocalPlayerID()
var hero = Players.GetPlayerHeroEntityIndex( LocalPlayerID )
var ingredients = Root.ingredients
var table = Root.table
var itemResult = Root.itemname

if (itemsRequired === undefined)
    var itemsRequired = {}

for (var i = 0; i < ingredients.length; i++) {
    MakeItemPanel(ingredients[i], ingredients.length, i)
};

var equal = $.CreatePanel("Label", Root, "EqualSign")
equal.text = "="

// Resulting from craft
var resultPanel = MakeItemPanel(itemResult, 0)

CheckInventory()

function MakeItemPanel(name, elements, num) {
    var itemPanel = $.CreatePanel("Panel", Root, name)
    itemPanel.itemname = name
    itemPanel.elements = elements

    // Track how many of this item does the recipe need
    if (name != itemResult)
        itemsRequired[name] ? itemsRequired[name]++ : itemsRequired[name]=1

    itemPanel.BLoadLayout("file://{resources}/layout/custom_game/crafting/crafting_item.xml", false, false);
    
    return itemPanel

    /*if (elements>0)
    {
        var spacing = 70/elements
        itemPanel.style["width"] = spacing+"%"
    }*/
}

function CheckInventory()
{
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
        var meetsAllRequirements = true
        for (var i in itemsRequired) {
            if (itemsOnInventory[i] === undefined || itemsRequired[i] > itemsOnInventory[i])
            {
                meetsAllRequirements = false
                break
            }
        };

        var childNum = Root.GetChildCount()
        for (var i = 0; i < childNum; i++) {
            var child = Root.GetChild(i)
            if (Entities.HasItemInInventory( hero, child.itemname ) && itemsOnInventory[child.itemname] > 0)
            {
                //$.Msg(resultName, " Requires ",itemsRequired[child.itemname], " ", child.itemname, " | Has ", itemsOnInventory[child.itemname])
                itemsOnInventory[child.itemname]--
                AddGlow(child)
            }
            else
            {
                RemoveGlow(child)
            }
        };
    }

    if (meetsAllRequirements)
        GlowCraft(resultPanel)
    else
        RemoveGlow(resultPanel)

    $.Schedule(1, CheckInventory)
}


function AddGlow(panel) {
    panel.style['box-shadow'] = "0px 0px 100% gold";
}

function RemoveGlow(panel) {
    panel.style['box-shadow'] = "0px 0px 0%";
}

function GlowCraft(panel) {
    panel.style['box-shadow'] = "0px 0px 100% green";
}

/* 
    
    Entities.GetItemInSlot( integer nEntityIndex, integer nSlotIndex )
*/
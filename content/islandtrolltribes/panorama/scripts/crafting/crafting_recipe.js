var Root = $.GetContextPanel()
var entity = Root.entity
var ingredients = Root.ingredients
var table = Root.table
var section_name = Root.section_name
var itemResult = Root.itemname
var aliasTable = CustomNetTables.GetTableValue( "crafting", "Alias" )

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
    // Build an array of items in inventory 
    var itemsOnInventory = []

    for (var i = 0; i < 6; i++) {
        var item = Entities.GetItemInSlot( entity, i )
        if (item)
        {
            var item_name = Abilities.GetAbilityName(item)
            if (item_name != "item_slot_locked")
                itemsOnInventory.push(item_name)
        }
    };

    if (Root.visible)
    {
        var meetsAllRequirements = true
        var childNum = Root.GetChildCount()
        for (var i = 0; i < childNum; i++) {
            var child = Root.GetChild(i)
            if (child.itemname !== undefined && child.itemname != itemResult)
            {
                var itemIndex = FindItemInArray(child.itemname, itemsOnInventory)
                if (itemIndex > -1)
                {
                    itemsOnInventory.splice(itemIndex, 1)
                    AddGlow(child)
                }
                else
                {
                    meetsAllRequirements = false
                    RemoveGlow(child)
                }
            }
        };
    }

    if (meetsAllRequirements)
        GlowCraft(resultPanel)
    else
        RemoveGlowCraft(resultPanel)

    $.Schedule(1, CheckInventory)
}

// Search for an item by name taking alias into account
function FindItemInArray(itemName, itemList) {
    for (var index in itemList)
    {
        if (itemList[index] == itemName)
        {
            return index
        }
        else if (MatchesAlias(itemName, itemList[index]))
        {
            return index
        }
    }
    return -1
}

function MatchesAlias( aliasName, targetItemName ) {
    if (aliasName.indexOf("any_") > -1)
    {
        for (var itemName in aliasTable[aliasName])
        {
            if (itemName==targetItemName)
            {
                return true
            }
        }
    }
    return false
}

function AddGlow(panel) {
    panel.AddClass("GlowGold");
}

function RemoveGlow(panel) {
    panel.RemoveClass("GlowGold");
}

function GlowCraft(panel) {
    panel.SetPanelEvent('onactivate', SendCraft)

    panel.AddClass("GlowGreen");
    panel.craft = true
}

function SendCraft() {
    GameEvents.SendCustomGameEventToServer( "craft_item", {itemname: itemResult, section: section_name, entity: entity} );
}

function RemoveGlowCraft(panel) {  
    panel.ClearPanelEvent('onactivate')
    panel.craft = false
    panel.RemoveClass("GlowGreen");
}
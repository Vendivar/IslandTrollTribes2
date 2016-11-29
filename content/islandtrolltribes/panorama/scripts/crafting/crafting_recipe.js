var aliasTable = CustomNetTables.GetTableValue( "crafting", "Alias" );
function InstantiateCraftingRecipe(panel) {
    var entity = panel.entity;
    var ingredients = panel.ingredients;
    var table = panel.table;
    var section_name = panel.section_name;
    var itemResult = panel.itemname;

    for (var i = 0; i < ingredients.length; i++) {
        MakeItemPanel(panel, ingredients[i], ingredients.length);
    }

    var equal = $.CreatePanel("Label", panel, "EqualSign");
    equal.text = "=";

    // Resulting from craft
    var resultPanel = MakeItemPanel(panel, itemResult, 0);
    resultPanel.section_name = section_name;
    resultPanel.entity = entity;
    resultPanel.itemname = itemResult;

    CheckInventory(panel, resultPanel);

    GameUI.pushEvent("update_recipes_" + panel.entity, function(context, inventory) {
        CheckInventory(context.panel, context.resultPanel, inventory);
    }, {panel: panel, resultPanel: resultPanel});

    GameUI.build_cb("update_recipes_" + panel.entity, {
        entity: panel.entity,
        inventory: {}
    })();
}

function MakeItemPanel(parent, name, elements) {
    var itemPanel = $.CreatePanel("Panel", parent, name);
    itemPanel.itemname = name;
    itemPanel.elements = elements;
    itemPanel.BLoadLayoutSnippet("Crafting_Item");
    InstatiateCraftingItem(itemPanel);

    return itemPanel;
}

function CheckInventory(panel, resultPanel, inventory)
{
    // Think glows and craft state
    var itemsInInventory = {};
    if (!inventory) {
        // Build an array of items in inventory
        for (var i = 0; i < 6; i++) {
            var item = Entities.GetItemInSlot(panel.entity, i);
            if (item)
            {
                var item_name = Abilities.GetAbilityName(item);
                if (item_name !== undefined && item_name != "item_slot_locked")
                {
                    var charges = Items.GetCurrentCharges(item);
                    if (!itemsInInventory[item_name]) {
                        itemsInInventory[item_name] = 0;
                    }

                    if (charges > 1) {
                        itemsInInventory[item_name] += charges;
                    }
                    else {
                        itemsInInventory[item_name] += 1;
                    }
                }
            }
        }
    }
    else {
        // Deep cloning an object.
        // More at http://stackoverflow.com/questions/122102/what-is-the-most-efficient-way-to-deep-clone-an-object-in-javascript
        itemsInInventory = JSON.parse(JSON.stringify(inventory));
    }

    if (panel && panel.visible) {
        var meetsAllRequirements = true;
        var childNum = panel.GetChildCount();
        for (var i = 0; i < childNum; i++) {
            var child = panel.GetChild(i);
            if (child.itemname !== undefined && child.itemname != resultPanel.itemname)
            {
                var name = IsAnAlias(child.itemname, itemsInInventory);
                if (itemsInInventory[name] && itemsInInventory[name] > 0) {
                    itemsInInventory[name] -= 1;
                    AddGlow(child);
                }
                else {
                    meetsAllRequirements = false;
                    RemoveGlow(child);
                }
                /*
                var itemIndex = FindItemInArray(child.itemname, inventory);
                if (itemIndex > -1)
                {
                    itemsOnInventory.splice(itemIndex, 1);

                }
                else
                {
                    meetsAllRequirements = false;

                }
                */
            }
        }
    }

    if (meetsAllRequirements)
        GlowCraft(resultPanel);
    else
        RemoveGlowCraft(resultPanel);

    /*if (panel.entity != Players.GetPlayerHeroEntityIndex( Game.GetLocalPlayerID() )) {
        $.Schedule(1, function() {
            CheckInventory(panel, resultPanel)
        });
    }*/
}

function IsAnAlias(name, inventory) {
    if (name.indexOf("any_") > -1) {
        for (var itemName in aliasTable[name]) {
            if (inventory[itemName]) {
                return itemName;
            }
        }
        return name; // Not found in inventory, just return the original.
    }
    else {
        return name;
    }
}

// Search for an item by name taking alias into account
function FindItemInArray(itemName, itemList) {
    for (var index in itemList)
    {
        if (itemList[index] == itemName)
        {
            return index;
        }
        else if (MatchesAlias(itemName, itemList[index]))
        {
            return index;
        }
    }
    return -1;
}

function MatchesAlias( aliasName, targetItemName ) {
    if (aliasName.indexOf("any_") > -1)
    {
        for (var itemName in aliasTable[aliasName])
        {
            if (itemName==targetItemName)
            {
                return true;
            }
        }
    }
    return false;
}

function AddGlow(panel) {
    panel.AddClass("GlowGold");
}

function RemoveGlow(panel) {
    panel.RemoveClass("GlowGold");
}

function GlowCraft(panel) {
    panel.SetPanelEvent('onactivate', function SendCraft() {
        GameEvents.SendCustomGameEventToServer( "craft_item", {itemname: panel.itemname, section: panel.section_name, entity: panel.entity} );
    })

    panel.AddClass("GlowGreen");
    panel.craft = true //Show a craft button when hovering
}

function RemoveGlowCraft(panel) {
    panel.ClearPanelEvent('onactivate');
    panel.craft = false;
    panel.RemoveClass("GlowGreen");
}

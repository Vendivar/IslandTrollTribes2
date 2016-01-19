var Root = $.GetContextPanel()

// Global lazy toggle
GameUI.CustomUIConfig().ToggleCraftingList = function() {
    Root.visible = !Root.visible
}

function CreateCraftingList()
{ 
    
    var values = CustomNetTables.GetAllTableValues("crafting")

    // Order: Basic Recipes first, then all the rest alphabetically
    CreateByName(values, "Recipes")
    CreateByName(values, "npc_building_armory")
    CreateByName(values, "npc_building_hut_witch_doctor")
    CreateByName(values, "npc_building_mix_pot")
    CreateByName(values, "Tannery")
    CreateByName(values, "npc_building_workshop")    
}

function CreateByName(values, name) {
    
    for (var i in values)
    {
        var crafting_table = values[i]
        if (crafting_table.key==name)
            CreateCraftingSection(name, crafting_table.value)
    }
}

// Create a section to hold a list of crafting items
function CreateCraftingSection (name, table) {
    $.Msg("CreateCraftingSection ",name)
    var section = $.CreatePanel("Panel", Root, name)
    section.name = name
    section.BLoadLayout("file://{resources}/layout/custom_game/crafting/crafting_section.xml", false, false);

    // Tannery takes an extra level second level
    if (name == "Tannery")
    {
        for (var type in table)
        {
            var subtable = table[type]
            for (var item_result in subtable)
            {
                var ingredients = []
                for (var ingredient in subtable[item_result])
                {
                    var times = subtable[item_result][ingredient]
                    for (var i = 0; i < times; i++) {
                        ingredients.push(ingredient)
                    }
                }
                CreateCraftingRecipe(section, item_result, ingredients, subtable[item_result])
            }
        }
    }

    else
    {
        for (var item_result in table)
        {
            var ingredients = []
            for (var ingredient in table[item_result])
            {
                var times = table[item_result][ingredient]
                for (var i = 0; i < times; i++) {
                    ingredients.push(ingredient)
                }
            }
            CreateCraftingRecipe(section, item_result, ingredients, table[item_result])
        }
    }

    // All sections but Recipes are initially hidden
    if (name != "Recipes")
    {
        var childNum = section.GetChildCount()
        for (var i = 0; i < childNum; i++) {
            var child = section.GetChild( i )
            if (child.id !="Toggle")
                child.visible = false
        };
    }
}


// Create a crafting recipe panel
function CreateCraftingRecipe (section, result, ingredients, table) {

    var crafting_item = $.CreatePanel("Panel", section, result)
    crafting_item.itemname = result
    crafting_item.ingredients = ingredients
    crafting_item.table = table
    crafting_item.BLoadLayout("file://{resources}/layout/custom_game/crafting/crafting_recipe.xml", false, false);
}

function GlowItems()
{   
    $.Schedule(1, GlowItems())
}

function Hide() {
    Root.visible = false
}

(function () {
    CreateCraftingList()
    $.Schedule(0.1, Hide)
    $.Msg("Done creating crafting list")
})();
// Create a section to hold a list of crafting items
function CreateCraftingSection (name, table, panel, bFold, entity) {
    $.Msg("CreateCraftingSection ",name)
    var section = $.CreatePanel("Panel", panel, name)
    section.name = name
    section.bFold = bFold //Whether the panel starts initially folded
    section.BLoadLayout("file://{resources}/layout/custom_game/crafting/crafting_section.xml", false, false);

    // Tannery takes an extra level second level
    if (name == "npc_building_tannery")
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
                CreateCraftingRecipe(section, item_result, ingredients, subtable[item_result], name, entity)
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
            CreateCraftingRecipe(section, item_result, ingredients, table[item_result], name, entity)
        }
    }

    // Hide elements if the panel should start fold
    if (section.bFold)
    {
        var childNum = section.GetChildCount()
        for (var i = 0; i < childNum; i++) {
            var child = section.GetChild( i )
            if (child.id !="Toggle")
                child.visible = false
        };
    }

    return section
}

// Create a crafting recipe panel
function CreateCraftingRecipe (section, result, ingredients, table, name, entity) {
    var crafting_item = $.CreatePanel("Panel", section, result)
    crafting_item.section_name = name
    crafting_item.itemname = result
    crafting_item.ingredients = ingredients
    crafting_item.table = table
    crafting_item.entity = entity
    crafting_item.BLoadLayout("file://{resources}/layout/custom_game/crafting/crafting_recipe.xml", false, false);
}


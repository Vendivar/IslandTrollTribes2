// Create a section to hold a list of crafting items
function CreateCraftingSection (name, table, panel, bFold, entity) {
    var section = $.CreatePanel("Panel", panel, name)
    section.name = name
    section.bFold = bFold //Whether the panel starts initially folded
    section.BLoadLayoutSnippet("Crafting_Section");
    InstantiateCraftingSection(section)

    // Create the recipes in order
    for (var i in table)
    {
        var subtable = table[i]
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
            $.Msg(item_result,"=",ingredients)
            CreateCraftingRecipe(section, item_result, ingredients, subtable[item_result], name, entity)
        }
    }

    // Need to refresh itempen inventory here so all the recipes can get it.
    GameUI.refresh_items = true;


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
    crafting_item.BLoadLayoutSnippet("Crafting_Recipe")
    InstantiateCraftingRecipe(crafting_item)
}

var crafting_currentSelected
var iPlayerID = Players.GetLocalPlayer();
function Crafting_OnUpdateSelectedUnits() {
    var selectedEntities = Players.GetSelectedEntities( iPlayerID );
    var mainSelected = selectedEntities[0]
    if (crafting_currentSelected == mainSelected)
        GameUI.CustomUIConfig().HideCraftingList();
    else
        crafting_currentSelected = mainSelected
}

function Itempen_Updated(args) {
    $.Msg(args);
    GameUI.itempens[args.itempen_id] = args.inventory;
    for (var i in args.buildings) {
        var index = args.buildings[i];
        if (!GameUI.itempens[index]) {
            GameUI.itempens[index] = [];
        }

        if (GameUI.itempens[index].indexOf(args.itempen_id) == -1) {
            GameUI.itempens[index].push(args.itempen_id);
        }
    }
}

function Itempen_CheckDestroy(args) {
    var name = Entities.GetUnitName(event.building);
    if (name === "npc_building_itempen") {
        // Itempen got destroyed!
        if (GameUI.itempens[event.building]) {
            // Remove our inventory
            delete GameUI.itempens[event.building];
            for (var id in GameUI.itempens) {
                // Look for any references to our inventory and remove them!
                var val = GameUI.itempens[id];
                if (val.indexOf && val.indexOf(event.building) > -1) {
                  GameUI.itempens[id].splice(val.indexOf(event.building), 1);
                }
            }
        }
    }
}

(function () {
    GameUI.itempens = {};
    GameEvents.Subscribe( "dota_player_update_selected_unit", Crafting_OnUpdateSelectedUnits );
    GameEvents.Subscribe( "itempen_updated", Itempen_Updated);
    GameEvents.Subscribe( "building_killed", Itempen_CheckDestroy);
})();

// Needed for the new crafting inventory checks.

GameUI.pushEvent = function(eventName, callback, ctx) {
  if (!GameUI.events) {
    GameUI.events = {};
  }

  if (!GameUI.events[eventName]) {
    GameUI.events[eventName] = [];
  }
  GameUI.events[eventName].push({
    callback: callback,
    context: ctx
  });
}

GameUI.popEvent = function(eventName, context) {
  if (GameUI.events[eventName]) {
    for (var i in GameUI.events[eventName]) {
        var event = GameUI.events[eventName][i];
        event.callback(event.context, context);
    }
  }
}

GameUI.check_cb = function(name) {
  if (!GameUI.event_callBacks) {
    GameUI.event_callBacks = {};
    return false;
  }

  return GameUI.event_callBacks[name] === true;
}

GameUI.build_cb = function(name, context) {
  if (!GameUI.event_callBacks) {
    GameUI.event_callBacks = {};
  }

  if (GameUI.check_cb(name)) {
    return function() {}; // Need to return this because we are executing immediately.
  }
  $.Msg("Creating callback for entity " + context.entity);
  $.Msg("Current callbacks: ");
  GameUI.event_callBacks[name] = true;
  var ctx = context

  $.Msg(GameUI.event_callBacks);

  var checkInventoryUnique = function() {
    var item, item_name, i, res, charges;

    if (!Entities.IsValidEntity(ctx.entity)) {
      $.Msg("Our building was destroyed!");
      return;
    }

    var current_inventory = {};
    for (i in ctx.inventory) {
        current_inventory[i] = 0;
    }

    for (i = 0; i < 6; i++) {
      item = Entities.GetItemInSlot(ctx.entity, i);
      if (item) {
        item_name = Abilities.GetAbilityName(item);
        if (item_name !== undefined && item_name !== "item_slot_locked" && item_name !== "") {
          if (!current_inventory[item_name]) {
            current_inventory[item_name] = 0;
          }

          var charges = Items.GetCurrentCharges(item);
          if (charges > 1) {
            current_inventory[item_name] += charges;
          }
          else {
            current_inventory[item_name] += 1;
          }
        }
      }
    }

    if (GameUI.itempens[ctx.entity]) {
      var itempen, itempen_inventory, item, count;
      for (i in GameUI.itempens[ctx.entity]) {
        itempen = GameUI.itempens[ctx.entity][i];
        itempen_inventory = GameUI.itempens[itempen];
        for (item in itempen_inventory) {
          count = itempen_inventory[item];
          if (!current_inventory[item]) {
            current_inventory[item] = 0;
          }

          current_inventory[item] += count;
        }
      }
    }

    var change = false;
    for (var itemName in current_inventory) {
        if (ctx.inventory[itemName] !== current_inventory[itemName]) {
            change = true;
            ctx.inventory[itemName] = current_inventory[itemName];
            if (ctx.inventory[itemName] === 0) {
                delete ctx.inventory[itemName];
            }
        }
    }

    if (!change && GameUI.refresh_items) {
        change = true;
        GameUI.refresh_items = false;
    }

    if (change) {
        $.Msg(current_inventory);
        $.Msg("Inventory changed, updating crafting.");
        GameUI.popEvent("update_recipes_" + ctx.entity, current_inventory);
    }

    $.Schedule(0.2, function(){ checkInventoryUnique() });
  };

  return checkInventoryUnique;
}

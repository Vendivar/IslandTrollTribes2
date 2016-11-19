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

(function () {
    GameEvents.Subscribe( "dota_player_update_selected_unit", Crafting_OnUpdateSelectedUnits );
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

GameUI.popEvent = function(eventName) {
  if (GameUI.events[eventName]) {
    for (var i in GameUI.events[eventName]) {
        var event = GameUI.events[eventName][i];
        event.callback(event.context);
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
    var item, item_name, i
    var change = false;
    for (i = 0; i < 6; i++) {
      item = Entities.GetItemInSlot(ctx.entity, i);
      if (item) {
        item_name = Abilities.GetAbilityName(item);
        if (item_name !== undefined) {
          if (!ctx.inventory[i]) {
            ctx.inventory[i] = {
              item: item_name,
              charges: charges
            };
            change = true;
          }
          else {
            var charges = Items.GetCurrentCharges(item);
            if (ctx.inventory[i].item !== item_name || ctx.inventory[i].charges !== charges) {
              ctx.inventory[i] = {
                item: item_name,
                charges: charges
              };
              change = true;
            }
          }
        }
        else {
          ctx.inventory[i] = undefined;
        }
      }
      else {
        ctx.inventory[i] = undefined;
      }
    }

    if (change) {
      $.Msg("Inventory changed, updating crafting.");
      GameUI.popEvent("update_recipes_" + ctx.entity);
    }

    $.Schedule(0.2, function(){ checkInventoryUnique() });
  };

  return checkInventoryUnique;
}

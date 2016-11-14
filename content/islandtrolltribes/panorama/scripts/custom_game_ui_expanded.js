/*
    This contains scripts to reutilize through various interface files
    The file doesn't need to be included, as the functions are accessible in global GameUI scope
*/

GameUI.AcceptWheeling = 1 // Accept scrolling by default
GameUI.DenyWheel = function() {
    $.Msg("Denying World Scrolling")
    GameUI.AcceptWheeling = 0;
}

GameUI.AcceptWheel = function() {
    GameUI.AcceptWheeling = 1;
}

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
          if (ctx.inventory[i] !== item_name) {
            ctx.inventory[i] = item_name;
            change = true;
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

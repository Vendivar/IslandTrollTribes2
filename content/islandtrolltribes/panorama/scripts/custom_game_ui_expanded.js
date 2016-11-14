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

GameUI.pushEvent = function(eventName, callback) {
  if (!GameUI.events) {
    GameUI.events = {};
  }

  if (!GameUI.events[eventName]) {
    GameUI.events[eventName] = [];
  }
  GameUI.events[eventName].push(callback);
}

GameUI.popEvent = function(eventName) {
  if (GameUI.events[eventName]) {
    for (var i in GameUI.events[eventName]) {
        GameUI.events[eventName][i]();
    }
  }
}

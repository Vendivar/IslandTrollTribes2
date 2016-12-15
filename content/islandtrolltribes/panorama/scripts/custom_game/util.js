
function LuaColor(color){
    color = color || [0, 128, 128, 128];

    return "rgb(" + [color[1], color[2], color[3]].join(",") + ")";
}

if (!GameUI.enterListeners) {
    GameUI.enterListeners = {};
}

Game.OnEnterPressed = function() {
    for (var key in GameUI.enterListeners) {
        GameUI.enterListeners[key]();
    }
}

GameUI.AddEnterListener = function(name, callback) {
    GameUI.enterListeners[name] = callback;
}

GameUI.RemoveEnterListener = function(name) {
    delete GameUI.enterListeners[name];
}

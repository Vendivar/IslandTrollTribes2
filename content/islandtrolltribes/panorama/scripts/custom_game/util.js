
function LuaColor(color){
    color = color || [0, 128, 128, 128];

    return "rgb(" + [color[1], color[2], color[3]].join(",") + ")";
}

if (!Game.enterListeners) {
    Game.enterListeners = {};
}

Game.OnEnterPressed = function() {
    $.Msg("Enter pressed!");
    for (var key in Game.enterListeners) {
        Game.enterListeners[key]();
    }
}

function AddEnterListener(name, callback) {
    Game.enterListeners[name] = callback;
}

function RemoveEnterListener(name) {
    delete Game.enterListeners[name];
}

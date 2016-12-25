var ArrowButton = $.GetContextPanel()

var first_time = false;
function ToggleArrows() {
    $.Msg("ToggleArrow");
    GameUI.CustomUIConfig().ToggleArrows();

    if (!first_time) {
        first_time = true;
        GameEvents.SendCustomGameEventToServer("start_quests", {
            playerID: Players.GetLocalPlayer()
        });
    }
}

(function () {
    GameUI.CustomUIConfig().EnableToggleArrowButton = function() {
        ArrowButton.RemoveClass("Hidden")
    }
    GameUI.CustomUIConfig().DisableToggleArrowButton = function() {
        ArrowButton.AddClass("Hidden")
    }
})();


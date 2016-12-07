var ArrowButton = $.GetContextPanel()
function ToggleArrows() {
    $.Msg("ToggleArrow");
    GameUI.CustomUIConfig().ToggleArrows();
}

(function () {
    GameUI.CustomUIConfig().EnableToggleArrowButton = function() {
        ArrowButton.RemoveClass("Hidden")
    }
    GameUI.CustomUIConfig().DisableToggleArrowButton = function() {
        ArrowButton.AddClass("Hidden")
    }
})();

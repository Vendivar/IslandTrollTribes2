var HelpButton = $.GetContextPanel()
function ToggleHelp() {
    $.Msg("ToggleHelp");
    GameUI.CustomUIConfig().ToggleHelp();
}

(function () {
    Game.AddCommand( "+ToggleHelp", ToggleHelp, "", 0 );
    GameUI.CustomUIConfig().EnableToggleHelpButton = function() {
        HelpButton.RemoveClass("Hidden")
    }
    GameUI.CustomUIConfig().DisableToggleHelpButton = function() {
        HelpButton.AddClass("Hidden")
    }
})();

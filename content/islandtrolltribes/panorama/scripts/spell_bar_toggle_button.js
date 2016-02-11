var SpellBarButton = $.GetContextPanel()
function ToggleSpellBar() {
    $.Msg("ToggleSpellBar")
    GameUI.CustomUIConfig().ToggleSpellBar()
}

(function () {
    Game.AddCommand( "+ToggleSpellBar", ToggleSpellBar, "", 0 );
    GameUI.CustomUIConfig().EnableToggleSpellBarButton = function() {
        SpellBarButton.RemoveClass("Hidden")
    }
    GameUI.CustomUIConfig().DisableToggleSpellBarButton = function() {
        SpellBarButton.AddClass("Hidden")
    }
})();
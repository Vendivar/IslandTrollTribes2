function ToggleCraftingList() {
    $.Msg("ToggleCraftingList")
    GameUI.CustomUIConfig().ToggleCraftingList()
}

(function () {
    Game.AddCommand( "+ToggleCraft", ToggleCraftingList, "", 0 );
})();
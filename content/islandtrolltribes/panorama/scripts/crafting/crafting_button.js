function ToggleCraftingList() {
    $.Msg("ToggleCraftingList")
    if (GameUI.crafting_error) {
        $.Msg("Apparently crafting has errored, here's the error:");
        $.Msg(GameUI.crafting_error);
        return;
    }
    GameUI.CustomUIConfig().ToggleCraftingList()
}

(function () {
    Game.AddCommand( "+ToggleCraft", ToggleCraftingList, "", 0 );
    Game.AddCommand( "-ToggleCraft", function() {}, "", 0);
})();

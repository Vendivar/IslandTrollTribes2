
function ToggleArrows() {
    $("#Help_Arrows").ToggleClass("hidden");
}

(function() {
    GameUI.CustomUIConfig().ToggleArrows = function() {
        ToggleArrows();
    }
})();


function ToggleArrows() {
    $("#Help_Arrows").ToggleClass("hidden");
	
}

(function() {
    GameUI.CustomUIConfig().ToggleArrows = function() {
        ToggleArrows();
	  GameUI.SetCameraDistance( 1500 ) //Added default zoom levels
    }
})();

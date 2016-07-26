var Root = $.GetContextPanel();
var tabs;
var contents;
var activeTab = 0;

function SelectTab(num) {
    if (num !== activeTab) {
        tabs[activeTab].RemoveClass("active");
        tabs[num].AddClass("active");

        contents[activeTab].AddClass("hidden");
        contents[num].RemoveClass("hidden");

        activeTab = num;
    }
}

function OnCloseHover() {
    $("#Close_btn").AddClass("hover");
}

function OnCloseHoverOut() {
    $("#Close_btn").RemoveClass("hover");
}

function OnArrowHover() {
    $("#Arrow_btn").AddClass("hover");
}

function OnArrowHoverOut() {
    $("#Arrow_btn").RemoveClass("hover");
}

function ToggleArrows() {
    $("#Help_Arrows").ToggleClass("hidden");
}

function OnTabHover(num) {
    if (num !== activeTab) {
        tabs[num].AddClass("hover");
    }
}

function OnTabHoverOut(num) {
    tabs[num].RemoveClass("hover");
}

(function() {
    tabs = $("#Help_Tabs").Children();
    contents = $("#Help_Content").Children();
    HideHelp();
    $.Msg("Help menu loaded!");
})();

// Global lazy toggle
GameUI.CustomUIConfig().ToggleHelp = function() {
    Root.ToggleClass( "hide_menu" )
    Root.SetFocus();
    if (Root.BHasClass("hide_menu")) {
        GameUI.AcceptWheel();
    }
    else {
        GameUI.DenyWheel();
    }
}

function HideHelp() {
  Root.AddClass("hide_menu");
}

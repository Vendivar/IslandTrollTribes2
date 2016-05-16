/* 
    This contains scripts to reutilize through various interface files
    The file doesn't need to be included, as the functions are accessible in global GameUI scope
*/

GameUI.AcceptWheeling = 1 // Accept scrolling by default
GameUI.DenyWheel = function() {
    GameUI.AcceptWheeling = 0;
}

GameUI.AcceptWheel = function() {
    GameUI.AcceptWheeling = 1;
}
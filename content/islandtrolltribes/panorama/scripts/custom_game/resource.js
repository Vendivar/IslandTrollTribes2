"use strict";

(function () {
	UpdateGold();
})();

function UpdateGold(){
	var CurrentGold = Players.GetGold( Game.GetLocalPlayerID() );
	
	$("#GoldText").text = CurrentGold;
	$.Schedule(0.1, UpdateGold);
};
"use strict";

(function () {
	$('#UpkeepText').AddClass('Green');
	$('#UpkeepText').text = $.Localize( "#no_upkeep" );
	UpdateGold();
})();

function UpdateGold(){
	var CurrentGold = Players.GetGold( Game.GetLocalPlayerID() );
	
	$("#GoldText").text = CurrentGold;
	$.Schedule(0.1, UpdateGold);
};
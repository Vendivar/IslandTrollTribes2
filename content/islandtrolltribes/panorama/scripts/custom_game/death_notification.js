
function teamMemberDown(args) {
  var player = args.player;
  var hero = args.hero;

  // Taken from chat.js
  var line = $.CreatePanel("Panel", $("#DeathPanel"), "");
  line.AddClass("DeathNotification");

  var playerName = "You have"
  if (player != Players.GetLocalPlayer()) {
    playerName = Players.GetPlayerName(player);
    playerName = playerName + " has"
  }

  var img = $.CreatePanel("DOTAHeroImage", line, "");
  img.AddClass("DeathNotification_icon");
  img.heroimagestyle = "icon";
  img.heroname = hero;

  var label = $.CreatePanel("Label", line, "");
  label.SetDialogVariable("name", playerName);
  label.html = true;
  label.text = $.Localize("#DeathMessage", label);

  $.Schedule(4, function(){
      line.DeleteAsync(0)
  });
}

(function() {
  GameEvents.Subscribe("team_member_down", teamMemberDown);
})();

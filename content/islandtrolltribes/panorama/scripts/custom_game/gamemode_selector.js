
var settings = {
  speed: 2,
  pick: 1,
  custom_noob: false,
  custom_fixedbush: false,
  custom_norevive: false,
  custom_noislandbosses: false
};

var voted = false;

var notvoted_players = {};
var voted_players = {};

var custom_active = false;

function onHover(cls) {
  var panel = $("#" + cls);

  $.DispatchEvent("DOTAShowTextTooltip", panel, "#Gamemode_tooltip_" + cls);
}

function offHover(cls) {
  var panel = $("#" + cls);

  $.DispatchEvent("DOTAHideTextTooltip", panel);
}

function setSpeed(speed, force) {
  if (voted && !force) return;
  $("#speed_" + settings["speed"]).RemoveClass("active_speed");

  settings["speed"] = speed;
  $("#speed_" + speed).AddClass("active_speed");
}

function setPick(pick, force) {
  if (voted && !force) return;
  $("#pick_" + settings["pick"]).RemoveClass("active_pick")

  settings["pick"] = pick;
  $("#pick_" + pick).AddClass("active_pick")
}

function toggleCustom(force) {
  if (voted && !force) return;
  custom_active = !custom_active

  if (custom_active) {
    $("#Gamemode_customwrapper").RemoveClass("hidden");
    $("#Gamemode_picks").RemoveClass("hidden");
    $("#custom_options").AddClass("active_custom");
  }
  else {
    $("#Gamemode_customwrapper").AddClass("hidden");
    $("#Gamemode_picks").AddClass("hidden");
    $("#custom_options").RemoveClass("active_custom");

    setPick(1);

    for (var i in settings) {
      if (i.slice(0,6) === "custom" && settings[i]) {
        setCustomToggle(i);
      }
    }
  }
}

function setCustomToggle(key, force) {
  if (voted && !force) return;
  settings[key] = !settings[key];

  if (settings[key]) {
    $("#" + key).AddClass("active_custom");
  }
  else {
    $("#" + key).RemoveClass("active_custom");
  }
}

function sendVote() {
  if (voted) return;
  GameEvents.SendCustomGameEventToServer("game_mode_selected", {
    settings: settings
  });
  voted = true

  $("#Gamemode_confirm").AddClass("hidden");
  $("#Gamemode_confirmed").RemoveClass("hidden");
}

var votingLeft = 60;
function setInitialTimer() {
  if (votingLeft == 0) {
    return;
  }

  var label = $("#Gamemode_timer");
  label.SetDialogVariable("time", votingLeft);
  label.text = $.Localize("#Gamemode_timer", label);

  $.Schedule(1, function() {
    votingLeft -= 1;
    setInitialTimer();
  })
}

function setNotVoted() {
  var labels = $("#Gamemode_notvoted").Children();
  for (i in labels) {
    if (i > 0) {
      labels[i].DeleteAsync(0);
    }
  }

  var i = 0;
  var player;
  var label;
  for (i in notvoted_players) {
    player = notvoted_players[i];

    label = $.CreatePanel("Label",$("#Gamemode_notvoted"),"");
    label.AddClass("player_line");
    label.text = player;
  }
}

var PICKS = ["","ALL_PICK","ALL_RANDOM","SAME_HERO"];
var SPEEDS = ["","FAST","NORMAL","SLOW"];

function setVoted() {
  var labels = $("#Gamemode_voted").Children();
  for (i in labels) {
    if (i > 0) {
      labels[i].DeleteAsync(0);
    }
  }

  var i = 0;
  var player;
  var settings;
  var label;
  $.Msg(voted_players);
  for (i in voted_players) {
    player = voted_players[i].player;
    settings = voted_players[i].settings;

    label = $.CreatePanel("Label", $("#Gamemode_voted"), "");
    label.AddClass("player_line");
    label.SetDialogVariable("player", player);
    label.SetDialogVariable("speed", SPEEDS[settings.speed]);
    label.SetDialogVariable("pick", PICKS[settings.pick]);
    label.html = true
    label.text = $.Localize("#Gamemode_player_line", label);

    var c = 0;
    var setting;
    var img;
    for (c in settings) {
      if (c.slice(0,6) === "custom") {
        setting = settings[c];
        if (setting) {
          img = $.CreatePanel("Panel", label, "");
          img.AddClass("Gamemode_icon");
          img.AddClass("Gamemode_icon_" + c);

          (function(nam, imag) {
            imag.SetPanelEvent("onmouseover", function() {
              $.DispatchEvent("DOTAShowTextTooltip", imag, "#Gamemode_tooltip_icon_" + nam);
            });

            imag.SetPanelEvent("onmouseout", function() {
              $.DispatchEvent("DOTAHideTextTooltip", imag);
            });
          })(c,img);
        }
      }
    }
  }
}

function setPlayerList() {
  // Sets the initial playerlist.
  var i = 0;
  var player;
  for (i; i < 16; i++) {
    if (Players.IsValidPlayerID(i)) {
      player = Players.GetPlayerName(i);
      notvoted_players[i] = player;
    }
  }

  setNotVoted();
}

var timeLeft = 5
function VoteEnd() {
  if (timeLeft == 0) {
    return;
  }

  var label = $("#Gamemode_confirmed");
  label.SetDialogVariable("time", timeLeft);
  label.text = $.Localize("#Gamemode_votingend", label);

  $.Schedule(1, function() {
    timeLeft -= 1;
    VoteEnd();
  })
}

function OnVoteConfirmed(vote) {
  if (!vote.timer_up) {
    var player_confirmed = Players.GetPlayerName(vote.player);
    voted_players[vote.player] = {
      player: player_confirmed,
      settings: vote.settings
    };

    delete notvoted_players[vote.player];

    setNotVoted();
    setVoted();
  }
  else {
    voted = true

    $("#Gamemode_confirm").AddClass("hidden");
    $("#Gamemode_confirmed").RemoveClass("hidden");
  }

  if (vote.voting_ended) {
    $("#Gamemode_timer").AddClass("hidden");
    $.Msg("Voting has ended!");
    // Voting has ended!

    VoteEnd();

    // Show settings.
    var voted_settings = vote.voted_settings;
    var custom_settings = voted_settings.custom_settings;

    // Map server's settings to local settings.
    var map = {
      "ALL_PICK": 1,
      "ALL_RANDOM": 2,
      "SAME_HERO": 3,
      "FAST": 1,
      "NORMAL": 2,
      "SLOW": 3,
      "noob_mode": "custom_noob",
      "fixed_bush_spawning": "custom_fixedbush",
      "norevive": "custom_norevive",
      "noislandbosses": "custom_noislandbosses"
    }

    setPick(map[voted_settings.pick_mode], true);
    setSpeed(map[voted_settings.game_mode], true);

    // Show custom options, regardless if they are actually set.
    custom_active = false;
    toggleCustom(true);

    // Only change what you have to.
    var i = "";
    var str = "";
    for (var i in custom_settings) {
      str = map[i];
      $.Msg(settings[str]);
      $.Msg(custom_settings[i]);
      if (settings[str] != custom_settings[i]) {
        setCustomToggle(str, true);
      }
    }

    $.Schedule(5, function() {
      // We only have to hide the gamemodes when we need the hero selection.
      // This is also useful for testing.
      if (voted_settings.pick_mode == "ALL_PICK") {
        $("#Gamemode_container").AddClass("hidden");
      }
    });

    // class_picker.js is handling the pick mode.
  }
}

(function() {
  GameEvents.Subscribe("vote_confirmed", OnVoteConfirmed);

  setPlayerList();
  setInitialTimer();
  $.GetContextPanel().SetFocus();
  GameUI.DenyWheel();

  $("#GamemodeSelectionChat").BLoadLayout("file://{resources}/layout/custom_game/simple_chat.xml", false, false);
  $("#GamemodeSelectionChat").RegisterListener("GamemodeSelectionEnter");

  $.Msg("Gamemode selection loaded!");
})()

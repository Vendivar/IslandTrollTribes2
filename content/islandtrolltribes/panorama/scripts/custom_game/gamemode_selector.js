
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

var mock_votes = [
  {
    pick: 1,
    speed: 1,
    custom_noob: 0,
    custom_norevive: 1,
    custom_noislandbosses: 0,
    custom_fixedbushes: 1
  },
  {
    pick: 2,
    speed: 3,
    custom_noob: 1,
    custom_norevive: 1,
    custom_noislandbosses: 0,
    custom_fixedbushes: 1
  },
  {
    pick: 1,
    speed: 1,
    custom_noob: 0,
    custom_norevive: 1,
    custom_noislandbosses: 0,
    custom_fixedbushes: 0
  }
];

var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
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
    $("#Gamemode_customheader").text = $.Localize("#Gamemode_customheader_disable")
  }
  else {
    $("#Gamemode_customwrapper").AddClass("hidden");
    $("#Gamemode_picks").AddClass("hidden");
    $("#Gamemode_customheader").text = $.Localize("#Gamemode_customheader_enable")

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
    $("#" + key + "_label").AddClass("active_custom");
  }
  else {
    $("#" + key + "_label").RemoveClass("active_custom");
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

  GameUI.Wrapper.Unlock();
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

var PICKS = ["","ALL PICK","ALL RANDOM","SAME HERO"];
var SPEEDS = ["","FAST","NORMAL","SLOW"];

function countVotes() {
  var votes = {};
  var settings;
  for (i in voted_players) {
    settings = voted_players[i].settings;
    if (votes[PICKS[settings.pick]]) {
      votes[PICKS[settings.pick]] = votes[PICKS[settings.pick]] + 1
    }
    else {
      votes[PICKS[settings.pick]] = 1
    }

    if (votes[SPEEDS[settings.speed]]) {
      votes[SPEEDS[settings.speed]] = votes[SPEEDS[settings.speed]] + 1
    }
    else {
      votes[SPEEDS[settings.speed]] = 1
    }

    if (settings.custom_noob === 1) {
      votes["custom_noob"] = votes["custom_noob"] ? votes["custom_noob"] + settings.custom_noob : 1;
    }

    if (settings.custom_norevive === 1) {
      votes["custom_norevive"] = votes["custom_norevive"] ? votes["custom_norevive"] + settings.custom_norevive : 1;
    }

    if (settings.custom_noislandbosses === 1) {
      votes["custom_noislandbosses"] = votes["custom_noislandbosses"] ? votes["custom_noislandbosses"] + settings.custom_noislandbosses : 1;
    }

    if (settings.custom_fixedbush === 1) {
      votes["custom_fixedbush"] = votes["custom_fixedbush"] ? votes["custom_fixedbush"] + settings.custom_fixedbush : 1;
    }
  }

  return votes;
}

function addVotedLine(setting, vote_count, final_votes) {
  var panel = $.CreatePanel("Panel", $("#Gamemode_voted"), "");
  panel.AddClass("player_line");

  var header = $.CreatePanel("Panel", panel, "");
  header.AddClass("player_line_header");
  if (setting.slice(0,6) === "custom") {
    var icon = $.CreatePanel("Panel", header, "");
    icon.AddClass("Gamemode_icon");
    icon.AddClass("Gamemode_icon_" + setting);

    (function(nam, imag) {
      imag.SetPanelEvent("onmouseover", function() {
        $.DispatchEvent("DOTAShowTextTooltip", imag, "#Gamemode_tooltip_icon_" + nam);
      });

      imag.SetPanelEvent("onmouseout", function() {
        $.DispatchEvent("DOTAHideTextTooltip", imag);
      });
    })(setting, icon);
  }
  else {
    var label = $.CreatePanel("Label", header, "");
    label.text = setting;
  }

  var bar = $.CreatePanel("Panel", panel, "");
  bar.AddClass("vote_bar");
  bar.style.width = ((vote_count / 16) * 100) + "%";

  if (final_votes && final_votes[setting]) {
    bar.AddClass("vote_bar_final");
  }
}

function setVoted(final_votes) {
  var panels = $("#Gamemode_voted").Children();
  for (i in panels) {
    if (i > 0) {
      panels[i].DeleteAsync(0);
    }
  }

  var setting;
  var vote_count;
  var votes = countVotes();
  $.Msg(votes);
  for (setting in votes) {
    if (setting === "ALL PICK" || setting === "ALL RANDOM" || setting === "SAME HERO") {
      vote_count = votes[setting];
      addVotedLine(setting, vote_count, final_votes);
    }
  }

  for (setting in votes) {
    if (setting === "FAST" || setting === "NORMAL" || setting === "SLOW") {
      vote_count = votes[setting];
      addVotedLine(setting, vote_count, final_votes);
    }
  }

  for (setting in votes) {
    if (setting.slice(0,6) === "custom") {
      vote_count = votes[setting];
      addVotedLine(setting, vote_count, final_votes);
    }
  }
}
/*
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
*/
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

  /*
  for (i in mock_votes) {
    var mock = mock_votes[i];
    voted_players[i] = {
      settings: mock
    }
  }
  setVoted();
  */
}

var timeLeft = 5
function VoteEnd() {
  var label = $("#Gamemode_confirmed");
  if (timeLeft == 0) {
    label.text = $.Localize("Gamemode_votingendnotimer");
	GameUI.Wrapper.ToRight();
    return;
  }

  label.SetDialogVariable("time", timeLeft);
  label.text = $.Localize("#Gamemode_votingend", label);

  $.Schedule(1, function() {
    timeLeft -= 1;
    VoteEnd();
  })
}

function addPlayer(player, settings) {
  var player_confirmed = Players.GetPlayerName(player);
  voted_players[player] = {
    player: player_confirmed,
    settings: settings
  }
  $.Msg(voted_players);

  delete notvoted_players[player];

  setNotVoted();
  setVoted();
}

function EndingVoting(settings) {
  $("#Gamemode_timer").AddClass("hidden");
  $.Msg("Voting has ended!");
  // Voting has ended!

  VoteEnd();
  $("#Gamemode_voted_header").text = $.Localize("#Gamemode_final_votes_header");

  // Show settings.
  var voted_settings = settings;
  var custom_settings = settings.custom_settings;

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

  var mapped_settings = {};
  mapped_settings[PICKS[map[voted_settings.pick_mode]]] = 1;
  mapped_settings[SPEEDS[map[voted_settings.game_mode]]] = 1;

  for (i in custom_settings) {
    if (custom_settings[i] === 1) {
      mapped_settings[map[i]] = 1;
    }
  }

  setVoted(mapped_settings);

  $.Schedule(3, function() {
    // We only have to hide the gamemodes when we need the hero selection.
    // This is also useful for testing.
    if (voted_settings.pick_mode == "ALL_PICK") {
      //$("#Gamemode_container").AddClass("hidden");
    }
  });

  // class_picker.js is handling the pick mode.
}

function IncomingData(table, changes, deletions) {
  $.Msg(changes);
  for (var key in changes) {
    if (!isNaN(parseInt(key))) {  // Keys are playerIDs.
      addPlayer(parseInt(key), changes[key]);
    }
    else {
      if (key == "voting_ended" && changes[key]) {
        EndingVoting(changes["voted_settings"]);
      }
      else if (key == "timer_up" && changes[key]) {
        voted = true;

        $("#Gamemode_confirm").AddClass("hidden");
        $("#Gamemode_confirmed").RemoveClass("hidden");
      }
    }
  }
}

(function() {
  // Changed voting from events to playertables. Better support for reconnection.
  GameUI.voteListenerID = PlayerTables.SubscribeNetTableListener("gamemode_votes", IncomingData);

  setPlayerList();
  setInitialTimer();
  $.GetContextPanel().SetFocus();
  GameUI.DenyWheel();

  //$("#GamemodeSelectionChat").BLoadLayout("file://{resources}/layout/custom_game/simple_chat.xml", false, false);

  $.Msg("Gamemode selection loaded!");
})()

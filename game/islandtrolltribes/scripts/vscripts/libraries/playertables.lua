PLAYERTABLES_VERSION = "0.80"

--[[
  Lua-controlled Frankenstein PlayerTables Library by BMD

  Installation
  -"require" this file inside your code in order to gain access to the PlayerTables global table.
  -Optionally require "libraries/notifications" before this file so that the Attachment Configuration GUI can display messages via the Notifications library.
  -Additionally, ensure that this file is placed in the vscripts/libraries path
  -Additionally, ensure that you have the barebones_PlayerTables.xml, barebones_PlayerTables.js, and barebones_PlayerTables.css files in your panorama content folder to use the GUI.
  -Finally, include the "PlayerTables.txt" in your scripts directory if you have a pre-build database of attachment settings.

  Library Usage
  -The library when required in loads in the "scripts/PlayerTables.txt" file containing the attachment properties database for use during your game mode.
  -Attachment properties are specified as a 3-tuple of unit model name, attachment point string, and attachment prop model name.
    -Ex: ("models/heroes/antimage/antimage.vmdl" // "attach_hitloc" // "models/items/axe/weapon_heavy_cutter.vmdl")
  -Optional particles can be specified in the "Particles" block of attachmets.txt.
  -To attach a prop to a unit, use the PlayerTables:AttachProp(unit, attachPoint, model[, scale[, properties] ]) function
    -Ex: PlayerTables:AttachProp(unit, "attach_hitloc", "models/items/axe/weapon_heavy_cutter.vmdl", 1.0)
    -This will create the prop and retrieve the properties from the database to attach it to the provided unit
    -If you pass in an already created prop or unit as the 'model' parameter, the attachment system will scale, position, and attach that prop/unit without creating a new one
    -Scale is the prop scale to be used, and defaults to 1.0.  The scale of the prop will also be scaled based on the unit model scale.
    -It is possible not to use the attachment database, but to instead provide the properties directly in the 'properties' parameter.
    -This properties table will look like:
      {
        pitch = 45.0,
        yaw = 55.0,
        roll = 65.0,
        XPos = 10.0,
        YPos = -10.0,
        ZPos = -33.0,
        Animation = "idle_hurt"
      }
  -To retrieve the currently attached prop entity, you can call PlayerTables:GetCurrentAttachment(unit, attachPoint)
    -Ex: local prop = PlayerTables:AttachProp(unit, "attach_hitloc")
    -Calling prop:RemoveSelf() will automatically detach the prop from the unit
  -To access the loaded Attachment database directly (for reading properties directly), you can call PlayerTables:GetAttachmentDatabase()

  Attachment Configuration Usage
  -In tools-mode, execute "attachment_configure <ADDON_NAME>" to activate the attachment configuration GUI for setting up the attachment database.
  -See https://www.youtube.com/watch?v=PS1XmHGP3sw for an example of how to generally use the GUI
  -The Load button will reload the database from disk and update the current attach point/prop model if values are stored therein.
  -The Hide button will hide/remove the current atatach point/prop model being displayed
  -The Save button will save the current properties as well as any other adjusted properties in the attachment database to disk.  
  -Databases will be saved to the scripts/PlayerTables.txt file of the addon you set when calling the attachment_configure <ADDON_NAME> command.
  -More detail to come...

  Notes
  -"attach_origin" can be used as the attachment string for attaching a prop do the origin of the unit, even if that unit has no attachment point named "attach_origin"
  -Attached props will automatically scale when the parent unit/models are scaled, so rescaling individual props after attachment is not necessary.
  -This library requires that the "libraries/timers.lua" be present in your vscripts directory.

  Examples:
  --Attach an Axe axe model to the "attach_hitloc" to a given unit at a 1.0 Scale.
    PlayerTables:AttachProp(unit, "attach_hitloc", "models/items/axe/weapon_heavy_cutter.vmdl", 1.0)

  --For GUI use, see https://www.youtube.com/watch?v=PS1XmHGP3sw

]]

--LinkLuaModifier( "modifier_animation_freeze", "libraries/modifiers/modifier_animation_freeze.lua", LUA_MODIFIER_MOTION_NONE )

if not PlayerTables then
  PlayerTables = class({})
end

function PlayerTables:start()
  self.tables = {}
  self.subscriptions = {}

  CustomGameEventManager:RegisterListener("PlayerTables_Connected", Dynamic_Wrap(PlayerTables, "PlayerTables_Connected"))
end

function PlayerTables:equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or self:equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function PlayerTables:copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[self:copy(k, s)] = self:copy(v, s) end
  return res
end

function PlayerTables:PlayerTables_Connected(args)
  print('PlayerTables_Connected')
  PrintTable(args)

  local pid = args.pid
  if not pid then
    return
  end

  local player = PlayerResource:GetPlayer(pid)
  print('player: ', player)

  for k,v in pairs(PlayerTables.subscriptions) do
    if v[pid] then
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_table_full_update", {name=k, table=PlayerTables.tables[k]} )
      end
    end
  end
end

function PlayerTables:CreateTable(tableName, tableContents, pids)
  tableContents = tableContents or {}
  pids = pids or {}

  if self.tables[tableName] then
    print("[playertables.lua] Warning: player table '" .. tableName .. "' already exists.  Overriding.")
  end

  self.tables[tableName] = tableContents
  self.subscriptions[tableName] = {}

  for pid,v in pairs(pids) do
    if pid >= 0 and pid < DOTA_MAX_TEAM_PLAYERS then
      self.subscriptions[tableName][pid] = true
      local player = PlayerResource:GetPlayer(pid)
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_table_full_update", {name=tableName, table=tableContents} )
      end
    else
      print("[playertables.lua] Warning: Pid value '" .. pid .. "' is not an integer between [0," .. DOTA_MAX_TEAM_PLAYERS .. "].  Ignoring.")
    end
  end
end

function PlayerTables:DeleteTable(tableName)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local pids = self.subscriptions[tableName]

  for k,v in pairs(pids) do
    local player = PlayerResource:GetPlayer(k)
    if player then  
      CustomGameEventManager:Send_ServerToPlayer(player, "pt_table_full_update", {name=tableName, table=nil} )
    end
  end

  self.tables[tableName] = nil
  self.subscriptions[tableName] = nil  
end

function PlayerTables:TableExists(tableName)
  return self.tables[tableName] ~= nil
end

function PlayerTables:SetPlayerSubscriptions(tableName, pids)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local oldPids = self.subscriptions[tableName]
  self.subscriptions[tableName] = {}

  for k,v in pairs(pids) do
    if v >= 0 and v < DOTA_MAX_TEAM_PLAYERS then
      self.subscriptions[tableName][v] = true
      local player = PlayerResource:GetPlayer(v)
      if player and oldPids[v] == nil then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_table_full_update", {name=tableName, table=table} )
      end
    else
      print("[playertables.lua] Warning: Pid value '" .. v .. "' is not an integer between [0," .. DOTA_MAX_TEAM_PLAYERS .. "].  Ignoring.")
    end
  end
end

function PlayerTables:AddPlayerSubscription(tableName, pid)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local oldPids = self.subscriptions[tableName]

  if not oldPids[pid] then
    if pid >= 0 and pid < DOTA_MAX_TEAM_PLAYERS then
      self.subscriptions[tableName][pid] = true
      local player = PlayerResource:GetPlayer(pid)
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_table_full_update", {name=tableName, table=table} )
      end
    else
      print("[playertables.lua] Warning: Pid value '" .. v .. "' is not an integer between [0," .. DOTA_MAX_TEAM_PLAYERS .. "].  Ignoring.")
    end
  end
end

function PlayerTables:RemovePlayerSubscription(tableName, pid)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local oldPids = self.subscriptions[tableName]
  oldPids[pid] = nil
end

function PlayerTables:GetTableValue(tableName, key)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local ret = self.tables[tableName][key]
  if type(ret) == "table" then
    return self:copy(ret)
  end
  return ret
end

function PlayerTables:GetAllTableValues(tableName)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local ret = self.tables[tableName]
  if type(ret) == "table" then
    return self:copy(ret)
  end
  return ret
end

function PlayerTables:DeleteTableKey(tableName, key)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local pids = self.subscriptions[tableName]

  if table[key] ~= nil then
    table[key] = nil
    for pid,v in pairs(pids) do
      local player = PlayerResource:GetPlayer(pid)
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_table_key_delete", {name=tableName, keys={[key]=true}} )
      end
    end
  end
end

function PlayerTables:DeleteTableKeys(tableName, keys)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local pids = self.subscriptions[tableName]

  local deletions = {}
  local notempty = false

  for k,v in pairs(keys) do
    if type(k) == "string" then
      if table[k] ~= nil then
        deletions[k] = true
        table[k] = nil
        notempty = true
      end
    elseif type(v) == "string" then
      if table[v] ~= nil then
        deletions[v] = true
        table[v] = nil
        notempty = true
      end
    end
  end

  if notempty then
    for pid,v in pairs(pids) do
      local player = PlayerResource:GetPlayer(pid)
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_table_key_delete", {name=tableName, keys=deletions} )
      end
    end
  end
end

function PlayerTables:SetTableValue(tableName, key, value)
  if value == nil then
    self:DeleteTableKey(tableName, key)
    return 
  end
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local pids = self.subscriptions[tableName]

  if not self:equals(table[key], value) then
    table[key] = value
    for pid,v in pairs(pids) do
      local player = PlayerResource:GetPlayer(pid)
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_table_update", {name=tableName, changes={[key]=value}} )
      end
    end
  end
end

function PlayerTables:SetTableValues(tableName, changes)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local pids = self.subscriptions[tableName]

  for k,v in pairs(changes) do
    if self:equals(table[k], v) then
      changes[k] = nil
    else
      table[k] = v
    end
  end

  local notempty, _ = next(changes, nil)

  if notempty then
    for pid,v in pairs(pids) do
      local player = PlayerResource:GetPlayer(pid)
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_table_update", {name=tableName, changes=changes} )
      end
    end
  end
end

if not PlayerTables.tables then PlayerTables:start() end
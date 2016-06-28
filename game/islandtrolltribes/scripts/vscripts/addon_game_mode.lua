---------------------------------------------------------------------------
if ITT == nil then
	_G.ITT = class({})
end
---------------------------------------------------------------------------

require('libraries/timers')
require('libraries/stats')
require('libraries/popups')
require('libraries/notifications')
require('libraries/animations')
require('libraries/playertables')
require('libraries/containers')
require('libraries/physics')
require('mechanics/require')
require('itt')
require('spawn')
require('gamemodes')
require('filters')
require('bushes')
require('shops')
require('developer')
require('item_spawning')
require('subclass_system')
require("crafting")
require('util')
require('libraries/buildinghelper')


-- This should be a KV Table
require('recipe_list')

---------------------------------------------------------------------------

function Precache( context )
	GameRules.Precache = LoadKeyValues("scripts/kv/precache.kv")

    for key, values in pairs(GameRules.Precache.Sync) do
        for entry,_ in pairs(values) do
            if key == "unit" then
                PrecacheUnitByNameSync(entry, context)
            elseif key == "item" then
            	PrecacheItemByNameSync(entry, context)
            else
                PrecacheResource(key, entry, context)
            end
        end
    end    
    
	PrecacheResource("particle", "particles/status_fx/status_effect_frost_lich.vpcf", context) 
	ITT:PrecacheSubclassModels(context)
end

-- Create our game mode and initialize it
function Activate()
	print ( '[ITT] Creating Game Mode' )
	ITT:InitGameMode()
end

---------------------------------------------------------------------------
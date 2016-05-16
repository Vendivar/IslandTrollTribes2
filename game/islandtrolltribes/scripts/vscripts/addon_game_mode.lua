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
require('mechanics/require')
require('itt')
require('spawn')
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
                PrecacheResource(k, entry, context)
            end
        end
    end

	PrecacheResource("particle_folder", "particles/custom",context)
	PrecacheResource("soundfile", "soundevents/chicken.vsndevts",context)
	PrecacheResource("soundfile", "soundevents/spells.vsndevts",context)
    PrecacheResource("soundfile", "soundevents/trollgeneral.vsndevts",context)
    
    
	ITT:PrecacheSubclassModels(context)

end

-- Create our game mode and initialize it
function Activate()
	print ( '[ITT] Creating Game Mode' )
	ITT:InitGameMode()
end

---------------------------------------------------------------------------
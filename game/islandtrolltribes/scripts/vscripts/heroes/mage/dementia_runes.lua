function RunesTelegatherInit(keys)
    local caster = keys.caster
    local target = keys.target
    keys.caster.targetFire = target
end

-- ItemRunes, RunesManip
-- ToggleOn RunesManip:         ItemRunes, RunesManip, Ability1, 2, 3, 4.
function ToggleOnRunes( event )
    local caster = event.caster
    local runesAbilityList = {
        "ability_mage_dementia_runes",
        "ability_mage_karune",
        "ability_mage_lezrune",
        "ability_mage_nelrune"
    }
    HideAllAbilities(caster)
    ShowTheSpellBook(caster, runesAbilityList)
end

-- Turns the layout back to normal
function ToggleOffRunes( event )
    local caster = event.caster
    local spellBook = GameRules.SpellBookInfo[MAGE]["dementia_master"]["book2"]
    HideAllAbilities(caster)
    ShowTheSpellBook(caster, spellBook)
end

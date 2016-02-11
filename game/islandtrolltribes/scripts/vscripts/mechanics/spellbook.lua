
function SwapSpellBook(keys)
    local caster = keys.caster
    local book = keys.activeBook
    local class = caster:GetClassname()
    local book1 = {}
    local book2 = {}

    mage_book1Spells = {
        "ability_mage_spellbook_toggle",
        "ability_mage_nulldamage",
        "ability_mage_pumpup",
        "ability_mage_magefire",
        "ability_mage_reducefood"
    }
    mage_book2Spells = {
        "ability_mage_spellbook_toggle",
        "ability_mage_negativeblast",
        "ability_mage_flamespray",
        "ability_mage_depress",
        "ability_mage_metronome"
    }
    priest_book1Spells = {
        "ability_priest_swap1",
        "ability_priest_theglow",
        "ability_priest_cureall",
        "ability_priest_resistall",
        "ability_priest_pumpup",
        "ability_priest_sprayhealing",
    }
    priest_book2Spells = {
        "ability_priest_swap2",
        "ability_priest_pacifyingsmoke",
        "ability_priest_mixheat",
        "ability_priest_mixenergy",
        "ability_priest_mixhealth",
    }

    local Book1Visibility = (book == 2)
    local Book2Visibility = (book == 1)

    if class == MAGE then
        book1 = mage_book1Spells
        book2 = mage_book2Spells
    elseif class == PRIEST then
        book1 = priest_book1Spells
        book2 = priest_book2Spells
    end

    for _,spell in pairs(book1) do
        SetAbilityVisibility(caster, spell, Book1Visibility)
    end
    for _,spell in pairs(book2) do
        SetAbilityVisibility(caster, spell, Book2Visibility)
    end
end
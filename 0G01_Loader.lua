-- 0G01 Loader.lua
local vb = renoise.ViewBuilder()

-- Define Preferences
local preferences = renoise.Document.create("ScriptingToolPreferences") {
    _0G01_Loader = false,
    RandomBPM = false
}

renoise.tool().preferences = preferences

-- Function to update Random BPM and its dependent functions
local function update_random_bpm_preferences()
    -- No additional actions needed here for now, could be expanded if needed
end

-- Dialog reference, should be accessible globally within this script
local dialog

-- Function to handle creation of a new track and inputting notes/effects upon sample change
local function on_sample_count_change()
    if not preferences._0G01_Loader.value then return end
    local song = renoise.song()
    if not song or #song.tracks == 0 or song.selected_track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER then return end
    
    local selected_track_index = song.selected_track_index
    local new_track_idx = selected_track_index + 1
    
    song:insert_track_at(new_track_idx)
    local line = song.patterns[song.selected_pattern_index].tracks[new_track_idx]:line(1)
    song.selected_track_index = new_track_idx
    line.note_columns[1].note_string = "C-4"
    line.note_columns[1].instrument_value = song.selected_instrument_index - 1
    line.effect_columns[1].number_string = "0G"
    line.effect_columns[1].amount_value = 01
end

-- Attach or remove observer based on the _0G01_Loader preference
local function manage_sample_count_observer(attach)
    local song = renoise.song()
    local instr = song.selected_instrument
    if attach then
        if not instr.samples_observable:has_notifier(on_sample_count_change) then
            instr.samples_observable:add_notifier(on_sample_count_change)
        end
    else
        if instr.samples_observable:has_notifier(on_sample_count_change) then
            instr.samples_observable:remove_notifier(on_sample_count_change)
        end
    end
end

-- Function to update dynamic menu entries and synchronize with preferences GUI
local function update_dynamic_menu_entries()
    local enableMenuEntryName = "Main Menu:Tools:Paketti..:!Preferences:0G01 Loader Enable"
    local disableMenuEntryName = "Main Menu:Tools:Paketti..:!Preferences:0G01 Loader Disable"

    if preferences._0G01_Loader.value then
        if renoise.tool():has_menu_entry(enableMenuEntryName) then
            renoise.tool():remove_menu_entry(enableMenuEntryName)
        end
        if not renoise.tool():has_menu_entry(disableMenuEntryName) then
            renoise.tool():add_menu_entry{
                name = disableMenuEntryName,
                invoke = function()
                    preferences._0G01_Loader.value = false
                    update_dynamic_menu_entries()
                    -- Ensure GUI is updated (if open)
                    if dialog and dialog.visible then
                        dialog:close() -- Close the dialog to reset state
                        show_paketti_preferences() -- Reopen with updated values
                    end
                end
            }
        end
    else
        if renoise.tool():has_menu_entry(disableMenuEntryName) then
            renoise.tool():remove_menu_entry(disableMenuEntryName)
        end
        if not renoise.tool():has_menu_entry(enableMenuEntryName) then
            renoise.tool():add_menu_entry{
                name = enableMenuEntryName,
                invoke = function()
                    preferences._0G01_Loader.value = true
                    update_dynamic_menu_entries()
                    -- Ensure GUI is updated (if open)
                    if dialog and dialog.visible then
                        dialog:close() -- Close the dialog to reset state
                        show_paketti_preferences() -- Reopen with updated values
                    end
                end
            }
        end
 end
 end

-- Function to update the 0G01 Loader setting and manage observer attachment based on preference
local function update_0G01_loader_menu_entries()
    manage_sample_count_observer(preferences._0G01_Loader.value)
    update_dynamic_menu_entries()
end

-- Initialization and observer attachment
local function initialize_tool()
    update_0G01_loader_menu_entries()
end

-- Ensure initialization occurs safely when a Renoise song is available
local function safe_initialize()
    if not renoise.tool().app_idle_observable:has_notifier(initialize_tool) then
        renoise.tool().app_idle_observable:add_notifier(initialize_tool)
    end
end

safe_initialize()

-- GUI for setting preferences
function show_paketti_preferences()
    if dialog and dialog.visible then return end

    local checkbox_0G01_Loader = vb:checkbox {
        value = preferences._0G01_Loader.value,
        notifier = function(value)
            preferences._0G01_Loader.value = value
            update_0G01_loader_menu_entries()
        end
    }

    local checkbox_RandomBPM = vb:checkbox {
        value = preferences.RandomBPM.value,
        notifier = function(value)
            preferences.RandomBPM.value = value
            update_random_bpm_preferences()
        end
    }

    local dialog_content = vb:column {
        margin = 10,
        vb:row {
            checkbox_0G01_Loader,
            vb:text { text = "Enable 0G01 Loader" }
        },
        vb:row {
            checkbox_RandomBPM,
            vb:text { text = "Enable Random BPM Write to Master" }
        },
        vb:horizontal_aligner {
            mode = "distribute",
            vb:button {
                text = "OK",
                notifier = function()
                    dialog:close()
                end
            },
            vb:button {
                text = "Cancel",
                notifier = function()
                    dialog:close()
                end
            }
        }
    }

    dialog = renoise.app():show_custom_dialog("Paketti Preferences", dialog_content)
end

-- Add menu entry and keybinding for showing the preferences dialog
renoise.tool():add_menu_entry{
    name = "Main Menu:Tools:Paketti..:!Preferences:Paketti Preferences...",
    invoke = show_paketti_preferences
}
renoise.tool():add_keybinding{
    name = "Global:Paketti:Show Paketti Preferences...",
    invoke = show_paketti_preferences
}


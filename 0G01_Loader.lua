local vb = renoise.ViewBuilder()
local dialog -- Reference to the dialog
local checkbox -- Reference to the checkbox for dynamic updates
local checkboxRandomBPM -- Reference to the RandomBPM checkbox for dynamic updates

-- Define Preferences
local preferences = renoise.Document.create("ScriptingToolPreferences") {
    _0G01_Loader = false,
    _RandomBPM = false
}

renoise.tool().preferences = preferences

-- Function to handle the creation of a new track and inputting notes/effects upon sample change
local function on_sample_count_change()
    if not preferences._0G01_Loader.value then return end
    local song = renoise.song()
    if not song or #song.tracks == 0 or song.selected_track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER then return end
    
    local selected_track_index = song.selected_track_index
    local new_track_idx = selected_track_index + 1 -- Insert after the currently selected track
    
    song:insert_track_at(new_track_idx)
    local line = song.patterns[song.selected_pattern_index].tracks[new_track_idx]:line(1)

    song.selected_track_index = new_track_idx -- Select the new track
    line.note_columns[1].note_string = "C-4"
    line.note_columns[1].instrument_value = song.selected_instrument_index - 1
    line.effect_columns[1].number_string = "0G"
    line.effect_columns[1].amount_value = 01
end

-- Attach or remove the observer based on the _0G01_Loader preference
local function manage_sample_count_observer(attach)
    local song = renoise.song()
    if not song or not song.selected_instrument or song.selected_track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER then return end
    
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

-- Function to update dynamic menu entries
local function update_dynamic_menu_entries()
    local enableMenuEntryName = "Main Menu:Tools:Paketti..:!Preferences:0G01 Loader Enable"
    local disableMenuEntryName = "Main Menu:Tools:Paketti..:!Preferences:0G01 Loader Disable"

    -- Ensure we only add the menu entry that's relevant and remove the other
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
                end
            }
        end
    end
end

-- Update the 0G01 Loader setting and manage observer attachment based on preference
-- This function is simplified as the dynamic menu updates are now separately handled
function update_0G01_loader_menu_entries()
    manage_sample_count_observer(preferences._0G01_Loader.value)
end

-- Create the GUI for Paketti Preferences
function show_paketti_preferences()
    if dialog and dialog.visible then return end

    checkbox = vb:checkbox {
        value = preferences._0G01_Loader.value,
        notifier = function(value)
            preferences._0G01_Loader.value = value
            update_0G01_loader_menu_entries()
            update_dynamic_menu_entries() -- Update dynamic menu entries when preferences change
        end
    }

    checkboxRandomBPM = vb:checkbox {
        value = preferences._RandomBPM.value,
        notifier = function(value)
            preferences._RandomBPM.value = value
        end
    }

    local dialog_content = vb:column {
        margin = 10,
        vb:row {
            checkbox,
            vb:text { text = "Enable 0G01 Loader" }
        },
        vb:row {
            checkboxRandomBPM,
            vb:text { text = "Enable Random BPM" }
        },
        vb:horizontal_aligner {
            mode = "distribute",
            vb:button {
                text = "Save",
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
    update_dynamic_menu_entries() -- Ensure menu entries are correctly set when preferences dialog is opened
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

-- Initialization and observer attachment
local function initialize_tool()
    update_0G01_loader_menu_entries()
    update_dynamic_menu_entries() -- Ensure correct initial state of dynamic menu entries
end

-- Ensure initialization occurs safely when a Renoise song is available
local function safe_initialize()
    local idle_notifier = function()
        initialize_tool()
    end

    -- Only add the idle_notifier if it hasn't been added yet
    if not renoise.tool().app_idle_observable:has_notifier(idle_notifier) then
        renoise.tool().app_idle_observable:add_notifier(idle_notifier)
    end
end

safe_initialize()


renoise.tool():add_keybinding{
    name = "Pattern Editor:Paketti:Enable/Disable 0G01",
    invoke = function()
    if preferences._0G01_Loader.value == true then
    preferences._0G01_Loader.value = false
    update_dynamic_menu_entries()
    renoise.app():show_status("0G01 Disabled")
    else
    preferences._0G01_Loader.value = true
    update_dynamic_menu_entries()
    renoise.app():show_status("0G01 Enabled")
   end
   end
}



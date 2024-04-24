-- 0G01 Loader.lua
local vb = renoise.ViewBuilder()

-- Define Preferences
preferences = renoise.Document.create("ScriptingToolPreferences") {
    _0G01_Loader = false, -- Default is false "don't apply 0G01 and write to new channel when loading sample"
    RandomBPM = false, -- Default is false "don't write BPM to Master"
    loadPaleGreenTheme = false, -- Default is false "don't load Pale Green Theme"
    WipeSlicesLoopSetting = 2, -- Default is "Forward"
    WipeSlicesBeatSyncMode = 2, -- Default is (Time-Stretch (Percussion))
    WipeSlicesOneShot = false, -- Default is Off
    WipeSlicesAutoseek = true,
}

renoise.tool().preferences = preferences

-- Function to update Random BPM and its dependent functions
local function update_random_bpm_preferences()
    -- No additional actions needed here for now, could be expanded if needed
end

local function  update_loadPaleGreenTheme_preferences()
renoise.app():load_theme("Presets/palegreen.xrnc")
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

safe_initialize()-- GUI for setting preferences
-- GUI for setting preferences
function show_paketti_preferences()
    if dialog and dialog.visible then return end

    local vb = renoise.ViewBuilder()

    -- Define all checkbox variables at the start to ensure they are accessible throughout the function
    local checkboxOff, checkboxForward, checkboxReverse, checkboxPingPong
    local checkboxRepitch, checkboxPercussion, checkboxTexture
    local checkboxOneShotOn, checkboxOneShotOff
    local checkboxAutoseekOn, checkboxAutoseekOff

    -- Helper function to create a horizontal rule
    local function horizontal_rule()
        return vb:horizontal_aligner {mode = "justify", width = "100%", vb:space {width = 2}, vb:row {height = 2, style = "panel", width = "100%"}, vb:space {width = 2}}
    end

    -- Helper function to add vertical space
    local function vertical_space(height)
        return vb:row {height = height}
    end

    -- Initialize the checkboxes with their specific settings and notifiers
    checkboxOff = vb:checkbox {value = preferences.WipeSlicesLoopSetting.value == 1, notifier = function(checked) if checked then preferences.WipeSlicesLoopSetting.value = 1; checkboxForward.value = false; checkboxReverse.value = false; checkboxPingPong.value = false; end end}
    checkboxForward = vb:checkbox {value = preferences.WipeSlicesLoopSetting.value == 2, notifier = function(checked) if checked then preferences.WipeSlicesLoopSetting.value = 2; checkboxOff.value = false; checkboxReverse.value = false; checkboxPingPong.value = false; end end}
    checkboxReverse = vb:checkbox {value = preferences.WipeSlicesLoopSetting.value == 3, notifier = function(checked) if checked then preferences.WipeSlicesLoopSetting.value = 3; checkboxOff.value = false; checkboxForward.value = false; checkboxPingPong.value = false; end end}
    checkboxPingPong = vb:checkbox {value = preferences.WipeSlicesLoopSetting.value == 4, notifier = function(checked) if checked then preferences.WipeSlicesLoopSetting.value = 4; checkboxOff.value = false; checkboxForward.value = false; checkboxReverse.value = false; end end}

    checkboxRepitch = vb:checkbox {value = preferences.WipeSlicesBeatSyncMode.value == 1, notifier = function(checked) if checked then preferences.WipeSlicesBeatSyncMode.value = 1; checkboxPercussion.value = false; checkboxTexture.value = false; end end}
    checkboxPercussion = vb:checkbox {value = preferences.WipeSlicesBeatSyncMode.value == 2, notifier = function(checked) if checked then preferences.WipeSlicesBeatSyncMode.value = 2; checkboxRepitch.value = false; checkboxTexture.value = false; end end}
    checkboxTexture = vb:checkbox {value = preferences.WipeSlicesBeatSyncMode.value == 3, notifier = function(checked) if checked then preferences.WipeSlicesBeatSyncMode.value = 3; checkboxRepitch.value = false; checkboxPercussion.value = false; end end}

    checkboxOneShotOn = vb:checkbox {value = preferences.WipeSlicesOneShot.value, notifier = function(checked) preferences.WipeSlicesOneShot.value = checked; checkboxOneShotOff.value = not checked; end}
    checkboxOneShotOff = vb:checkbox {value = not preferences.WipeSlicesOneShot.value, notifier = function(checked) preferences.WipeSlicesOneShot.value = not checked; checkboxOneShotOn.value = not checked; end}

    checkboxAutoseekOn = vb:checkbox {value = preferences.WipeSlicesAutoseek.value, notifier = function(checked) preferences.WipeSlicesAutoseek.value = checked; checkboxAutoseekOff.value = not checked; end}
    checkboxAutoseekOff = vb:checkbox {value = not preferences.WipeSlicesAutoseek.value, notifier = function(checked) preferences.WipeSlicesAutoseek.value = not checked; checkboxAutoseekOn.value = not checked; end}

    -- Construct the dialog with all elements
    local dialog_content = vb:column {
        margin = 10,
        vb:row {vb:checkbox {value = preferences._0G01_Loader.value, notifier = function(value) preferences._0G01_Loader.value = value; update_0G01_loader_menu_entries(); end}, vb:text {text = "Enable 0G01 Loader"}},
        vb:row {vb:checkbox {value = preferences.RandomBPM.value, notifier = function(value) preferences.RandomBPM.value = value; update_random_bpm_preferences(); end}, vb:text {text = "Enable Random BPM Write to Master"}},
        vb:row {vb:checkbox {value = preferences.loadPaleGreenTheme.value, notifier = function(value) preferences.loadPaleGreenTheme.value = value; update_loadPaleGreenTheme_preferences(); end}, vb:text {text = "Load Pale Green Theme"}},
        vertical_space(10),
        horizontal_rule(),
        vb:column {
            style = "group",
            margin = 10,
            vb:text {style = "strong", text = "Wipe & Slices Settings"},
            vertical_space(5),
            vb:text {text = "Slice Loop Mode"},
            vb:row {checkboxOff, vb:text {text = "Off"}, checkboxForward, vb:text {text = "Forwards"}, checkboxReverse, vb:text {text = "Reverse"}, checkboxPingPong, vb:text {text = "Ping-Pong"}},
            vb:text {text = "Slice BeatSync Mode"},
            vb:row {checkboxRepitch, vb:text {text = "Repitch"}, checkboxPercussion, vb:text {text = "Time-Stretch (Percussion)"}, checkboxTexture, vb:text {text = "Time-Stretch (Texture)"}},
            vb:text {text = "Slice One-Shot"},
            vb:row {checkboxOneShotOn, vb:text {text = "On"}, checkboxOneShotOff, vb:text {text = "Off"}},
            vb:text {text = "Slice Autoseek"},
            vb:row {checkboxAutoseekOn, vb:text {text = "On"}, checkboxAutoseekOff, vb:text {text = "Off"}}
        },
        vb:space {height = 10},
        vb:horizontal_aligner {
            mode = "distribute",
            vb:button {text = "OK", width = "50%", notifier = function() dialog:close(); end},
            vb:button {text = "Cancel", width = "50%", notifier = function() dialog:close(); end}
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


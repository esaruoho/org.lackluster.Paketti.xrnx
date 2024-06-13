renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:!! Donate !!",invoke=function()
renoise.app():open_url("http://paypal.me/esaruoho")
end}




local dialog
local vb = renoise.ViewBuilder()

local sample_rates = {22050, 44100, 48000, 88200, 96000, 192000}

-- Function to find the index of the sample rate
local function find_sample_rate_index(rate)
    for i, v in ipairs(sample_rates) do
        if v == rate then
            return i
        end
    end
    return 1 -- default to 22050 if not found
end

preferences = renoise.Document.create("ScriptingToolPreferences") {
    upperFramePreference = 0,
    _0G01_Loader = false,
    RandomBPM = false,
    loadPaleGreenTheme = false,
    WipeSlicesLoopMode = 2,
    WipeSlicesBeatSyncMode = 1,
    WipeSlicesOneShot = false,
    WipeSlicesAutoseek = false,
    WipeSlicesMuteGroup = 1,
    WipeSlicesNNA = 1,
    WipeSlicesBeatSyncGlobal = false,
    sliceCounter = 1,
    slicePreviousDirection = 1,
    renderSampleRate = 88200,
    renderBitDepth = 32,
    pakettiEditMode = 2,
    pakettiLoaderInterpolation = 1,
    pakettiLoaderOverSampling = true,
    pakettiLoaderAutoFade = true,
    pakettiLoaderLoopMode = 1,
    selectionNewInstrumentSelect = false,
    selectionNewInstrumentLoop = 2,
    shortcuts = renoise.Document.create("KeyBindings") {},
    midimappings = renoise.Document.create("MidiMappings") {},
    AppSelection1 = "",
    AppSelection2 = "",
    AppSelection3 = "",
    AppSelection4 = "",
    AppSelection5 = "",
    AppSelection6 = ""
}

renoise.tool().preferences = preferences

function load_preferences()
    if io.exists("preferences.xml") then
        preferences:load_from("preferences.xml")
    end
end

function update_random_bpm_preferences()
end

function update_loadPaleGreenTheme_preferences()
    renoise.app():load_theme("Presets/palegreen.xrnc")
end

function loadPlaidZap()
    renoise.app():load_instrument("Gifts/plaidzap.xrni")
end

function update_sample_rate(sample_rate)
    preferences.renderSampleRate.value = sample_rate
end

function update_bit_depth(bit_depth)
    preferences.renderBitDepth.value = bit_depth
end

function horizontal_rule()
    return vb:horizontal_aligner{mode="justify", width="100%", vb:space{width=2}, vb:row{height=2, style="panel", width="100%"}, vb:space{width=2}}
end

function vertical_space(height)
    return vb:row{height = height}
end

function update_interpolation_mode(value)
    preferences.pakettiLoaderInterpolation.value = value
    renoise.song().selected_sample.interpolation_mode = 5 - value -- Map 1-4 to 4-1
end

function update_loop_mode(loop_mode_pref, value)
    loop_mode_pref.value = value
    renoise.song().selected_sample.loop_mode = value - 1 -- Map 1-4 to 0-3
end

function create_loop_mode_switch(preference)
    return vb:switch{
        items = {"Off", "Forward", "Backward", "PingPong"},
        value = preference.value,
        width = 300,
        notifier = function(value)
            update_loop_mode(preference, value)
        end
    }
end

function show_paketti_preferences()
    if dialog and dialog.visible then return end

    local dialog_content = vb:column{margin = 10,
        vb:text{text = "UpperFrame Control F2 F3 F4 F11", font = "bold"},
        vb:row{vb:text{text = "Upper Frame", width = 120},
            vb:switch{items = {"Off", "Scopes", "Spectrum"},
                value = preferences.upperFramePreference.value + 1,
                width = 200,
                notifier = function(value)
                    preferences.upperFramePreference.value = value - 1
                end}},
        horizontal_rule(),
        vb:row{vb:text{text = "0G01 Loader", width = 120},
            vb:switch{items = {"Off", "On"},
                value = preferences._0G01_Loader.value and 2 or 1,
                width = 200,
                notifier = function(value)
                    preferences._0G01_Loader.value = (value == 2)
                    update_0G01_loader_menu_entries()
                end}},
        vb:row{vb:text{text = "Random BPM", width = 120},
            vb:switch{items = {"Off", "On"},
                value = preferences.RandomBPM.value and 2 or 1,
                width = 200,
                notifier = function(value)
                    preferences.RandomBPM.value = (value == 2)
                    update_random_bpm_preferences()
                end}},
        vb:row{
            vb:text{text = "Pale Green Theme", width = 120},
            vb:button{text = "Load", notifier = function() update_loadPaleGreenTheme_preferences() end}
        },
        vb:row{
            vb:text{text = "Gifts: Plaid Zap Load", width = 120},
            vb:button{text = "Load", notifier = function() loadPlaidZap() end}
        },
        vertical_space(10),
        horizontal_rule(),
        vb:column{style = "group", margin = 10,
            vb:row{vb:text{text = "Create New Instrument & Loop from Selection", style = "strong"}},
            vb:row{vb:text{text = "Select Newly Created Instrument", width = 200},
                vb:switch{items = {"Off", "On"},
                    value = preferences.selectionNewInstrumentSelect.value and 2 or 1,
                    width = 200,
                    notifier = function(value)
                        preferences.selectionNewInstrumentSelect.value = (value == 2)
                    end}},
            vb:row{vb:text{text = "Loop on Newly Created Instrument", width = 200},
                create_loop_mode_switch(preferences.selectionNewInstrumentLoop)}},
        horizontal_rule(),
        vb:column{style = "group", margin = 10,
            vb:text{style = "strong", text = "Paketti Loader Settings"},
            vertical_space(5),
            vb:row{vb:text{text = "Sample Interpolation", width = 150},
                vb:switch{items = {"None", "Linear", "Cubic", "Sinc"},
                    value = preferences.pakettiLoaderInterpolation.value,
                    width = 200,
                    notifier = function(value)
                        update_interpolation_mode(value)
                    end}},
            vb:row{vb:text{text = "Sample OverSampling", width = 150},
                vb:switch{items = {"Off", "On"},
                    value = preferences.pakettiLoaderOverSampling and 2 or 1,
                    width = 200,
                    notifier = function(value)
                        preferences.pakettiLoaderOverSampling = (value == 2)
                    end}},
            vb:row{vb:text{text = "Sample AutoFade", width = 150},
                vb:switch{items = {"Off", "On"},
                    value = preferences.pakettiLoaderAutoFade and 2 or 1,
                    width = 200,
                    notifier = function(value)
                        preferences.pakettiLoaderAutoFade = (value == 2)
                    end}},
            vb:row{vb:text{text = "Loop Mode", width = 150},
                create_loop_mode_switch(preferences.pakettiLoaderLoopMode)}},
        horizontal_rule(),
        vb:column{style = "group", margin = 10,
            vb:text{style = "strong", text = "Wipe & Slices Settings"},
            vertical_space(5),
            vb:row{vb:text{text = "Slice Loop Mode", width = 150},
                create_loop_mode_switch(preferences.WipeSlicesLoopMode)},
            vb:row{vb:text{text = "Slice BeatSync Mode", width = 150},
                vb:switch{items = {"Repitch", "Time-Stretch (Percussion)", "Time-Stretch (Texture)"},
                    value = preferences.WipeSlicesBeatSyncMode.value,
                    width = 400,
                    notifier = function(value)
                        preferences.WipeSlicesBeatSyncMode.value = value
                    end}},
            vb:row{vb:text{text = "Slice One-Shot", width = 150},
                vb:switch{items = {"Off", "On"},
                    value = preferences.WipeSlicesOneShot.value and 2 or 1,
                    width = 200,
                    notifier = function(value)
                        preferences.WipeSlicesOneShot.value = (value == 2)
                    end}},
            vb:row{vb:text{text = "Slice Autoseek", width = 150},
                vb:switch{items = {"Off", "On"},
                    value = preferences.WipeSlicesAutoseek.value and 2 or 1,
                    width = 200,
                    notifier = function(value)
                        preferences.WipeSlicesAutoseek.value = (value == 2)
                    end}},
            vb:row{vb:text{text = "New Note Action (NNA) Mode", width = 150},
                vb:switch{items = {"Cut", "Note-Off", "Continue"},
                    value = preferences.WipeSlicesNNA.value,
                    width = 300,
                    notifier = function(value)
                        preferences.WipeSlicesNNA.value = value
                    end}},
            vb:row{vb:text{text = "Mute Group", width = 150},
                vb:switch{items = {"Off", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"},
                    value = preferences.WipeSlicesMuteGroup.value + 1,
                    width = 400,
                    notifier = function(value)
                        preferences.WipeSlicesMuteGroup.value = value - 1
                    end}}},
        horizontal_rule(),
        vb:column{style = "group", margin = 10,
            vb:text{style = "strong", text = "Render Settings"},
            vertical_space(5),
            vb:row{vb:text{text = "Sample Rate", width = 150},
                vb:switch{
                    items = {"22050", "44100", "48000", "88200", "96000", "192000"},
                    value = find_sample_rate_index(preferences.renderSampleRate.value),
                    width = 300,
                    notifier = function(value)
                        preferences.renderSampleRate.value = sample_rates[value]
                    end}},
            vb:row{vb:text{text = "Bit Depth", width = 150},
                vb:switch{items = {"16", "24", "32"},
                    value = preferences.renderBitDepth.value == 16 and 1 or preferences.renderBitDepth.value == 24 and 2 or 3,
                    width = 300,
                    notifier = function(value)
                        preferences.renderBitDepth.value = (value == 1 and 16 or value == 2 and 24 or 32)
                    end}}},
        horizontal_rule(),
  
  
  
  vb:column{style = "group", margin = 10,
    vb:text{style = "strong", text = "Edit Mode Colouring"},
    vertical_space(5),
    vb:row{
        vb:text{text = "Edit Mode", width = 150},
        vb:switch{
            items = {"None", "Selected Track", "All Tracks"},
            value = preferences.pakettiEditMode.value,
            width = 300,
            notifier = function(value)
                preferences.pakettiEditMode.value = value
            end
        },
        vb:text{
            style = "strong",
            text = "Enable Scope Highlight by going to Settings -> GUI -> Show Track Color Blends."
        }
    },
    vb:space{height = 10},
},      vb:horizontal_aligner{mode = "distribute",
            vb:button{text = "OK", width = "50%", notifier = function() preferences:save_as("preferences.xml"); dialog:close() end},
            vb:button{text = "Cancel", width = "50%", notifier = function() dialog:close() end}}}
    
    dialog = renoise.app():show_custom_dialog("Paketti Preferences", dialog_content)
end

function on_sample_count_change()
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

function manage_sample_count_observer(attach)
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

function update_dynamic_menu_entries()
    local enableMenuEntryName = "Main Menu:Tools:Paketti..:!Preferences:0G01 Loader Enable"
    local disableMenuEntryName = "Main Menu:Tools:Paketti..:!Preferences:0G01 Loader Disable"

    if preferences._0G01_Loader.value then
        if renoise.tool():has_menu_entry(enableMenuEntryName) then
            renoise.tool():remove_menu_entry(enableMenuEntryName)
        end
        if not renoise.tool():has_menu_entry(disableMenuEntryName) then
            renoise.tool():add_menu_entry{name = disableMenuEntryName,
                invoke = function()
                    preferences._0G01_Loader.value = false
                    update_dynamic_menu_entries()
                    if dialog and dialog.visible then
                        dialog:close()
                        show_paketti_preferences()
                    end
                end}
        end
    else
        if renoise.tool():has_menu_entry(disableMenuEntryName) then
            renoise.tool():remove_menu_entry(disableMenuEntryName)
        end
        if not renoise.tool():has_menu_entry(enableMenuEntryName) then
            renoise.tool():add_menu_entry{name = enableMenuEntryName,
                invoke = function()
                    preferences._0G01_Loader.value = true
                    update_dynamic_menu_entries()
                    if dialog and dialog.visible then
                        dialog:close()
                        show_paketti_preferences()
                    end
                end}
        end
    end
end

function update_0G01_loader_menu_entries()
    manage_sample_count_observer(preferences._0G01_Loader.value)
    update_dynamic_menu_entries()
end

function initialize_tool()
    update_0G01_loader_menu_entries()
end

function safe_initialize()
    if not renoise.tool().app_idle_observable:has_notifier(initialize_tool) then
        renoise.tool().app_idle_observable:add_notifier(initialize_tool)
    end
    load_preferences()
end

safe_initialize()

renoise.tool():add_menu_entry{name = "Main Menu:Tools:Paketti..:!Preferences:Paketti Preferences...", invoke = show_paketti_preferences}
renoise.tool():add_keybinding{name = "Global:Paketti:Show Paketti Preferences...", invoke = show_paketti_preferences}


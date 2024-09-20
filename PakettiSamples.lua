local vb = renoise.ViewBuilder()

local app_paths = {}
local smart_folder_paths = {}

-- Function to browse for an app and update the corresponding field
function appSelectionBrowseForApp(index)
    local file_extensions = {"*.*"}
    local dialog_title = "Select an Application"

    local selected_file = renoise.app():prompt_for_filename_to_read(file_extensions, dialog_title)
    if selected_file ~= "" then
        -- Detect the operating system
        local os_name = os.platform()
        if os_name == "WINDOWS" then
            -- Replace backslashes with double backslashes for Windows paths
            selected_file = string.gsub(selected_file, "\\", "\\\\")
        end
        preferences.AppSelection["AppSelection"..index].value = selected_file
        if app_paths[index] then
            app_paths[index].text = selected_file
        end
        renoise.app():show_status("Selected file: " .. selected_file)
    else
        renoise.app():show_status("No file selected")
    end
end

-- Function to browse for a smart folder and update the corresponding field
function browseForSmartFolder(index)
    local dialog_title = "Select a Smart Folder / Backup Folder"

    local selected_folder = renoise.app():prompt_for_path(dialog_title)
    if selected_folder ~= "" then
        preferences.AppSelection["SmartFoldersApp"..index].value = selected_folder
        if smart_folder_paths[index] then
            smart_folder_paths[index].text = selected_folder
        end
        renoise.app():show_status("Selected folder: " .. selected_folder)
    else
        renoise.app():show_status("No folder selected")
    end
end

-- Function to save selected sample to temp and open with the selected app
function saveSelectedSampleToTempAndOpen(app_path)
    if renoise.song() == nil then return end
    local song = renoise.song()
    if song.selected_sample == nil or not song.selected_sample.sample_buffer.has_sample_data then
        renoise.app():show_status("No sample data available.")
        return
    end

    local temp_file_path = os.tmpname() .. ".wav"
    song.selected_sample.sample_buffer:save_as(temp_file_path, "wav")
    
    -- Detect the operating system
    local os_name = os.platform()
    local command

    if os_name == "WINDOWS" then
        command = 'start "" "' .. app_path .. '" "' .. temp_file_path .. '"'
    elseif os_name == "MACINTOSH" then
        command = 'open -a "' .. app_path .. '" "' .. temp_file_path .. '"'
    else
        command = 'exec "' .. app_path .. '" "' .. temp_file_path .. '" &'
    end

    os.execute(command)
    renoise.app():show_status("Sample sent to " .. app_path)
end

-- Create the dialog UI
local function create_dialog_content(close_dialog)
    app_paths = {}
    smart_folder_paths = {}

    return vb:column{
        margin=10,
        --spacing=10,
        width=900,
        vb:row{vb:text{text="App Selection", font="bold", style="strong"}},
        vb:row{
            spacing=10,
            vb:button{
                text="Browse",
                notifier=function() appSelectionBrowseForApp(1) end
            },
            vb:button{
                text="Send Selected Sample to App",
                notifier=function() 
                    saveSelectedSampleToTempAndOpen(preferences.AppSelection.AppSelection1.value) 
                end,
                width=200
            },
            (function()
                local path = vb:text{
                    text=(preferences.AppSelection.AppSelection1.value ~= "" and preferences.AppSelection.AppSelection1.value or "None"),
                    width=600,
                    font="bold"
                }
                app_paths[1] = path
                return path
            end)()
        },
        vb:row{
            spacing=10,
            vb:button{
                text="Browse",
                notifier=function() appSelectionBrowseForApp(2) end
            },
            vb:button{
                text="Send Selected Sample to App",
                notifier=function() 
                    saveSelectedSampleToTempAndOpen(preferences.AppSelection.AppSelection2.value) 
                end,
                width=200
            },
            (function()
                local path = vb:text{
                    text=(preferences.AppSelection.AppSelection2.value ~= "" and preferences.AppSelection.AppSelection2.value or "None"),
                    width=600,
                    font="bold"
                }
                app_paths[2] = path
                return path
            end)()
        },
        vb:row{
            spacing=10,
            vb:button{
                text="Browse",
                notifier=function() appSelectionBrowseForApp(3) end
            },
            vb:button{
                text="Send Selected Sample to App",
                notifier=function() 
                    saveSelectedSampleToTempAndOpen(preferences.AppSelection.AppSelection3.value) 
                end,
                width=200
            },
            (function()
                local path = vb:text{
                    text=(preferences.AppSelection.AppSelection3.value ~= "" and preferences.AppSelection.AppSelection3.value or "None"),
                    width=600,
                    font="bold"
                }
                app_paths[3] = path
                return path
            end)()
        },
        vb:row{
            spacing=10,
            vb:button{
                text="Browse",
                notifier=function() appSelectionBrowseForApp(4) end
            },
            vb:button{
                text="Send Selected Sample to App",
                notifier=function() 
                    saveSelectedSampleToTempAndOpen(preferences.AppSelection.AppSelection4.value) 
                end,
                width=200
            },
            (function()
                local path = vb:text{
                    text=(preferences.AppSelection.AppSelection4.value ~= "" and preferences.AppSelection.AppSelection4.value or "None"),
                    width=600,
                    font="bold"
                }
                app_paths[4] = path
                return path
            end)()
        },
        vb:row{
            spacing=10,
            vb:button{
                text="Browse",
                notifier=function() appSelectionBrowseForApp(5) end
            },
            vb:button{
                text="Send Selected Sample to App",
                notifier=function() 
                    saveSelectedSampleToTempAndOpen(preferences.AppSelection.AppSelection5.value) 
                end,
                width=200
            },
            (function()
                local path = vb:text{
                    text=(preferences.AppSelection.AppSelection5.value ~= "" and preferences.AppSelection.AppSelection5.value or "None"),
                    width=600,
                    font="bold"
                }
                app_paths[5] = path
                return path
            end)()
        },
        vb:row{
            spacing=10,
            vb:button{
                text="Browse",
                notifier=function() appSelectionBrowseForApp(6) end
            },
            vb:button{
                text="Send Selected Sample to App",
                notifier=function() 
                    saveSelectedSampleToTempAndOpen(preferences.AppSelection.AppSelection6.value) 
                end,
                width=200
            },
            (function()
                local path = vb:text{
                    text=(preferences.AppSelection.AppSelection6.value ~= "" and preferences.AppSelection.AppSelection6.value or "None"),
                    width=600,
                    font="bold"
                }
                app_paths[6] = path
                return path
            end)()
        },
        vb:row{vb:text{text="Smart Folders / Backup Folders", font="bold", style="strong"}},
        vb:row{
            spacing=10,
            vb:button{
                text="Browse",
                notifier=function() browseForSmartFolder(1) end
            },
            vb:button{
                text="Save Selected Sample to Folder",
                notifier=function() 
                    saveSampleToSmartFolder(1) 
                end,
                width=200
            },
            vb:button{
                text="Save All Samples to Folder",
                notifier=function() 
                    saveSamplesToSmartFolder(1) 
                end,
                width=200
            },
            (function()
                local path = vb:text{
                    text=(preferences.AppSelection.SmartFoldersApp1.value ~= "" and preferences.AppSelection.SmartFoldersApp1.value or "None"),
                    width=600,
                    font="bold"
                }
                smart_folder_paths[1] = path
                return path
            end)()
        },
        vb:row{
            spacing=10,
            vb:button{
                text="Browse",
                notifier=function() browseForSmartFolder(2) end
            },
            vb:button{
                text="Save Selected Sample to Folder",
                notifier=function() 
                    saveSampleToSmartFolder(2) 
                end,
                width=200
            },
            vb:button{
                text="Save All Samples to Folder",
                notifier=function() 
                    saveSamplesToSmartFolder(2) 
                end,
                width=200
            },
            (function()
                local path = vb:text{
                    text=(preferences.AppSelection.SmartFoldersApp2.value ~= "" and preferences.AppSelection.SmartFoldersApp2.value or "None"),
                    width=600,
                    font="bold"
                }
                smart_folder_paths[2] = path
                return path
            end)()
        },
        vb:row{
            spacing=10,
            vb:button{
                text="Browse",
                notifier=function() browseForSmartFolder(3) end
            },
            vb:button{
                text="Save Selected Sample to Folder",
                notifier=function() 
                    saveSampleToSmartFolder(3) 
                end,
                width=200
            },
            vb:button{
                text="Save All Samples to Folder",
                notifier=function() 
                    saveSamplesToSmartFolder(3) 
                end,
                width=200
            },
            (function()
                local path = vb:text{
                    text=(preferences.AppSelection.SmartFoldersApp3.value ~= "" and preferences.AppSelection.SmartFoldersApp3.value or "None"),
                    width=600,
                    font="bold"
                }
                smart_folder_paths[3] = path
                return path
            end)()
        },
        vb:button{
            text="OK",
            notifier=function()
                close_dialog()
            end
        }
    }
end

-- Show the dialog
function show_app_selection_dialog()
    local dialog = nil
    dialog = renoise.app():show_custom_dialog("App Selection & Smart Folders / Backup Folders", create_dialog_content(function()
        dialog:close()
    end))
end

renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:App Selection & Smart Folders",invoke=show_app_selection_dialog}

-- Add key bindings and MIDI mappings for AppSelection shortcuts
for i=1, 6 do
    renoise.tool():add_keybinding{
        name="Global:Paketti:Send Selected Sample to AppSelection" .. i,
        invoke=function()
            saveSelectedSampleToTempAndOpen(preferences.AppSelection["AppSelection"..i].value)
        end
    }

    renoise.tool():add_midi_mapping{name="Paketti:Send Selected Sample to AppSelection" .. i,
        invoke=function(message)
            if message:is_trigger() then saveSelectedSampleToTempAndOpen(preferences.AppSelection["AppSelection"..i].value)
            end
        end
    }
end

for i=1, 3 do
    renoise.tool():add_keybinding{name="Global:Paketti:Save Sample to Smart/Backup Folder " .. i, invoke=function() saveSampleToSmartFolder(i) end }
    renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Save Sample to Smart/Backup Folder " .. i, invoke=function() saveSampleToSmartFolder(i) end }
    renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Save Sample to Smart/Backup Folder " .. i, invoke=function() saveSampleToSmartFolder(i) end }
    renoise.tool():add_midi_mapping{name="Paketti:Save Sample to Smart/Backup Folder " .. i, invoke=function(message) if message:is_trigger() then saveSampleToSmartFolder(i) end end}
end

for i=1, 3 do
    renoise.tool():add_keybinding{name="Global:Paketti:Save All Samples to Smart/Backup Folder " .. i, invoke=function() saveSamplesToSmartFolder(i) end}
    renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Save All Samples to Smart/Backup Folder " .. i, invoke=function() saveSamplesToSmartFolder(i) end }
    renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Save All Samples to Smart/Backup Folder " .. i, invoke=function() saveSamplesToSmartFolder(i) end }
    renoise.tool():add_midi_mapping{ name="Paketti:Save All Samples to Smart/Backup Folder " .. i, invoke=function(message)
    if message:is_trigger() then saveSamplesToSmartFolder(i) end end}
end



----------------
-- Function to save selected sample to the specified Smart Folder
function saveSampleToSmartFolder(index)
    local smart_folder_path = preferences.AppSelection["SmartFoldersApp"..index].value
    if smart_folder_path == "" then
        renoise.app():show_status("Please set the Smart Folder path for " .. index)
        renoise.app():show_custom_dialog("Set Smart Folder Path", create_dialog_content())
        return
    end

    local lsfvariable = nil
    lsfvariable = os.tmpname("wav")
    local path = smart_folder_path .. "/"
    local s = renoise.song()
    local instboxname = s.selected_instrument.name

    if not s.selected_sample or not s.selected_sample.sample_buffer.has_sample_data then
        renoise.app():show_status("No sample data available.")
        return
    end

    local sample = s.selected_sample.sample_buffer
    local file_name = instboxname .. ".wav"
    
    if sample.bit_depth == 32 then
        -- local temp_sample = sample:clone()
        -- temp_sample.bit_depth = 24
        -- temp_sample:save_as(path .. file_name, "wav")
        sample:save_as(path .. file_name, "wav")
    else
        sample:save_as(path .. file_name, "wav")
    end
    renoise.app():show_status("Saved " .. file_name .. " to Smart Folder " .. path)
end

-- Function to save all samples to the specified Smart Folder
function saveSamplesToSmartFolder(index)
    local smart_folder_path = preferences.AppSelection["SmartFoldersApp"..index].value
    if smart_folder_path == "" then
        renoise.app():show_status("Please set the Smart Folder path for " .. index)
        renoise.app():show_custom_dialog("Set Smart Folder Path", create_dialog_content())
        return
    end

    local s = renoise.song()
    local path = smart_folder_path .. "/"
    local saved_samples_count = 0

    for i = 1, #s.instruments do
        local instrument = s.instruments[i]
        if instrument and #instrument.samples > 0 then
            for j = 1, #instrument.samples do
                local sample = instrument.samples[j].sample_buffer
                if sample.has_sample_data then
                    local file_name = instrument.name .. "_" .. j .. ".wav"
                    if sample.bit_depth == 32 then
                        -- local temp_sample = sample:clone()
                        -- temp_sample.bit_depth = 24
                        -- temp_sample:save_as(path .. file_name, "wav")
                        sample:save_as(path .. file_name, "wav")
                    else
                        sample:save_as(path .. file_name, "wav")
                    end
                    saved_samples_count = saved_samples_count + 1
                end
            end
        end
    end

    renoise.app():show_status("Saved " .. saved_samples_count .. " samples to Smart Folder " .. path)
    os.execute("cd " .. smart_folder_path .. ";open .")
end


-------------

function pakettiPreferencesDefaultInstrumentLoader()
  local defaultInstrument = preferences.pakettiDefaultXRNI.value
  local fallbackInstrument = "Presets/12st_Pitchbend.xrni"

  -- Function to check if a file exists
  local function file_exists(file)
    local f = io.open(file, "r")
    if f then f:close() end
    return f ~= nil
  end

  -- Check if the defaultInstrument is nil or the file doesn't exist
  if not defaultInstrument or not file_exists(defaultInstrument) then
    defaultInstrument = fallbackInstrument
    renoise.app():show_status("The Default XRNI has not been set, using Paketti/Presets/12st_Pitchbend.xrni")
  end

  print("Loading instrument from path: " .. defaultInstrument)
  renoise.app():load_instrument(defaultInstrument)
  if preferences.pakettiPitchbendLoaderEnvelope.value then
renoise.song().selected_instrument.sample_modulation_sets[1].devices[2].is_active = true else end


  if preferences.pakettiLoaderFilterType.value then
  renoise.song().selected_instrument.sample_modulation_sets[1].filter_type=preferences.pakettiLoaderFilterType.value end
end


---------------
function pitchBendDrumkitLoader()
  -- Prompt the user to select multiple sample files to load
  local selected_sample_filenames = renoise.app():prompt_for_multiple_filenames_to_read({"*.wav", "*.aif", "*.flac", "*.mp3", "*.aiff"}, "Paketti PitchBend Drumkit Sample Loader")

  -- Check if files are selected, if not, return
  if #selected_sample_filenames == 0 then
    renoise.app():show_status("No files selected.")
    return
  end

  -- Check for any existing instrument with samples or plugins and select a new instrument slot if necessary
  local song = renoise.song()
  local current_instrument_index = song.selected_instrument_index
  local current_instrument = song:instrument(current_instrument_index)

  if #current_instrument.samples > 0 or current_instrument.plugin_properties.plugin_loaded then
    song:insert_instrument_at(current_instrument_index + 1)
    song.selected_instrument_index = current_instrument_index + 1
  end

  -- Ensure the new instrument is selected
  current_instrument_index = song.selected_instrument_index
  current_instrument = song:instrument(current_instrument_index)

  -- Load the preset instrument
  renoise.app():load_instrument("Presets/" .. preferences.pakettiDefaultDrumkitXRNI.value)
--  renoise.app():load_instrument("Presets/12st_Pitchbend_Drumkit_C0.xrni")

  -- Ensure the new instrument is selected
  current_instrument_index = song.selected_instrument_index
  current_instrument = song:instrument(current_instrument_index)

  -- Generate the instrument name based on the instrument slot using hexadecimal format, adjusting by -1
  local instrument_slot_hex = string.format("%02X", current_instrument_index - 1)
  local instrument_name_prefix = instrument_slot_hex .. "_Drumkit"

  -- Limit the number of samples to 120
  local max_samples = 120
  local num_samples_to_load = math.min(#selected_sample_filenames, max_samples)

  -- Overwrite the "Placeholder" with the first sample
  local selected_sample_filename = selected_sample_filenames[1]
  local sample = current_instrument.samples[1]
  local sample_buffer = sample.sample_buffer
  local samplefilename = selected_sample_filename:match("^.+[/\\](.+)$")

  -- Set names for the instrument and sample
  current_instrument.name = instrument_name_prefix
  sample.name = ("12st_" .. samplefilename)

  -- Load the first sample file into the sample buffer
  if sample_buffer:load_from(selected_sample_filename) then
    renoise.app():show_status("Sample " .. selected_sample_filename .. " loaded successfully.")
  else
    renoise.app():show_status("Failed to load the sample.")
  end
-- Set additional sample properties
  
  sample.interpolation_mode=preferences.pakettiLoaderInterpolation.value
  sample.oversample_enabled = preferences.pakettiLoaderOverSampling.value
  sample.autofade = preferences.pakettiLoaderAutoFade.value
  sample.autoseek = preferences.pakettiLoaderAutoseek.value
  sample.oneshot = preferences.pakettiLoaderOneshot.value
  sample.loop_mode = preferences.pakettiLoaderLoopMode.value
  sample.new_note_action = preferences.pakettiLoaderNNA.value
  sample.loop_release = preferences.pakettiLoaderLoopExit.value

  -- Iterate over the rest of the selected files and insert them sequentially
  for i = 2, num_samples_to_load do
    selected_sample_filename = selected_sample_filenames[i]

  sample.interpolation_mode=preferences.pakettiLoaderInterpolation.value
  sample.oversample_enabled = preferences.pakettiLoaderOverSampling.value
  sample.oneshot = preferences.pakettiLoaderOneshot.value
  sample.autofade = preferences.pakettiLoaderAutoFade.value
  sample.autoseek = preferences.pakettiLoaderAutoseek.value
  sample.loop_mode = preferences.pakettiLoaderLoopMode.value
  sample.oneshot = preferences.pakettiLoaderOneshot.value
  sample.new_note_action = preferences.pakettiLoaderNNA.value
  sample.loop_release = preferences.pakettiLoaderLoopExit.value


    -- Insert a new sample slot if necessary
    if #current_instrument.samples < i then
      current_instrument:insert_sample_at(i)
    end

    sample = current_instrument.samples[i]
    sample_buffer = sample.sample_buffer
    samplefilename = selected_sample_filename:match("^.+[/\\](.+)$")

    -- Set names for the sample
    sample.name = ("12st_" .. samplefilename)

    -- Load the sample file into the sample buffer
    if sample_buffer:load_from(selected_sample_filename) then
      renoise.app():show_status("Sample " .. selected_sample_filename .. " loaded successfully.")
    else
      renoise.app():show_status("Failed to load the sample.")
    end

    -- Set additional sample properties
    --sample.oversample_enabled = true
    --sample.autofade = true
    --sample.interpolation_mode = renoise.Sample.INTERPOLATE_CUBIC
  end

  -- Check if there are more samples than the limit
  if #selected_sample_filenames > max_samples then
    local not_loaded_count = #selected_sample_filenames - max_samples
    renoise.app():show_status("Maximum Drumkit Zones is 120 - was not able to load " .. not_loaded_count .. " samples.")
  end

  -- Load the *Instr. Macros device and rename it
  loadnative("Audio/Effects/Native/*Instr. Macros")
  local macro_device = song.selected_track:device(2)
  macro_device.display_name = instrument_name_prefix
  song.selected_track.devices[2].is_maximized = false

  -- Additional actions after loading samples
  on_sample_count_change()
  -- showAutomation()
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:Paketti PitchBend Drumkit Sample Loader", invoke=function() pitchBendDrumkitLoader() end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Paketti PitchBend Drumkit Sample Loader", invoke=function() pitchBendDrumkitLoader() end}
renoise.tool():add_menu_entry{name="--Disk Browser Files:Paketti..:Paketti PitchBend Drumkit Sample Loader", invoke=function() pitchBendMultipleSampleLoader() end}

renoise.tool():add_keybinding{name="Global:Paketti:Paketti PitchBend Drumkit Sample Loader", invoke=function() pitchBendDrumkitLoader() end}
renoise.tool():add_midi_mapping{name="Paketti:Midi Paketti PitchBend Drumkit Sample Loader", invoke=function(message) if message:is_trigger() then pitchBendDrumkitLoader() end end}



-- Function to create a new instrument from the selected sample buffer range
function create_new_instrument_from_selection()
  local song = renoise.song()
  local selected_sample = song.selected_sample
  local selected_instrument_index = song.selected_instrument_index
  local selected_instrument = song.selected_instrument

if renoise.song().selected_sample ~= nil then 

  if not selected_sample.sample_buffer.has_sample_data then
    renoise.app():show_error("No sample buffer data found in the selected sample.")
    print("Error: No sample buffer data found in the selected sample.")
    return
  end
  print("Sample buffer data is valid.")

  local sample_buffer = selected_sample.sample_buffer

  if sample_buffer.selection_range == nil or #sample_buffer.selection_range < 2 then
    renoise.app():show_error("No valid selection range found.")
    print("Error: No valid selection range found.")
    return
  end
  print("Selection range is valid.")

  local selection_start = sample_buffer.selection_range[1]
  local selection_end = sample_buffer.selection_range[2]
  local selection_length = selection_end - selection_start

  local bit_depth = sample_buffer.bit_depth
  local sample_rate = sample_buffer.sample_rate
  local num_channels = sample_buffer.number_of_channels

  print(string.format("Sample properties - Bit depth: %d, Sample rate: %d, Number of channels: %d", bit_depth, sample_rate, num_channels))

  -- Insert a new instrument right below the current instrument
  local new_instrument_index = selected_instrument_index + 1
  song:insert_instrument_at(new_instrument_index)
  song.selected_instrument_index = new_instrument_index
  print("Inserted new instrument at index " .. new_instrument_index)

  -- Load the 12st_Pitchbend instrument into the new instrument slot
  
  pakettiPreferencesDefaultInstrumentLoader()

  
  print("Loaded Default XRNI instrument into the new instrument slot.")

  local new_instrument = song:instrument(new_instrument_index)
  new_instrument.name = "Pitchbend Instrument"
  new_instrument.macros_visible = true
  new_instrument.sample_modulation_sets[1].name = "Pitchbend"
  print("Configured new instrument properties.")

  -- Overwrite the "Placeholder sample" with the selected sample
  local placeholder_sample = new_instrument.samples[1]

  -- Create sample data and prepare to make changes
  placeholder_sample.sample_buffer:create_sample_data(sample_rate, bit_depth, num_channels, selection_length)
  local new_sample_buffer = placeholder_sample.sample_buffer
  new_sample_buffer:prepare_sample_data_changes()
  print("Created and prepared new sample data.")

  -- Copy the selection range to the new sample buffer
  for channel = 1, num_channels do
    for i = 1, selection_length do
      new_sample_buffer:set_sample_data(channel, i, sample_buffer:sample_data(channel, selection_start + i - 1))
    end
  end
  print("Copied selection range to the new sample buffer.")

  -- Finalize sample data changes
  new_sample_buffer:finalize_sample_data_changes()
  print("Finalized sample data changes.")

  -- Set the loop mode based on preferences.selectionNewInstrumentLoop
  local loop_mode_message = ""
  if preferences.selectionNewInstrumentLoop.value == 1 then
    placeholder_sample.loop_mode = renoise.Sample.LOOP_MODE_OFF
    loop_mode_message = "No Loop"
    print("Set loop mode to 'Off'.")
  elseif preferences.selectionNewInstrumentLoop.value == 2 then
    placeholder_sample.loop_mode = renoise.Sample.LOOP_MODE_FORWARD
    loop_mode_message = "Forward Loop"
    print("Set loop mode to 'Forward'.")
  elseif preferences.selectionNewInstrumentLoop.value == 3 then
    placeholder_sample.loop_mode = renoise.Sample.LOOP_MODE_REVERSE
    loop_mode_message = "Backward Loop"
    print("Set loop mode to 'Reverse'.")
  elseif preferences.selectionNewInstrumentLoop.value == 4 then
    placeholder_sample.loop_mode = renoise.Sample.LOOP_MODE_PING_PONG
    loop_mode_message = "PingPong Loop"
    print("Set loop mode to 'Ping-Pong'.")
  end

  -- Set the names for the new instrument and sample
  local instrument_slot_hex = string.format("%02X", new_instrument_index - 1)
  local original_sample_name = selected_sample.name
  new_instrument.name = string.format("%s_%s", instrument_slot_hex, original_sample_name)
  placeholder_sample.name = string.format("%s_%s", instrument_slot_hex, original_sample_name)
  print(string.format("Set names for the new instrument and sample: %s_%s", instrument_slot_hex, original_sample_name))

  -- Load the *Instr. Macros device and rename it
  loadnative("Audio/Effects/Native/*Instr. Macros")
  local macro_device = song.selected_track:device(2)
  macro_device.display_name = string.format("%s_%s", instrument_slot_hex, original_sample_name)
  song.selected_track.devices[2].is_maximized = false
  print("Loaded and configured *Instr. Macros device.")
  
  placeholder_sample.new_note_action = 1

  -- Select the new instrument and sample if preferences.selectionNewInstrumentSelect is true
  if preferences.selectionNewInstrumentSelect.value == true then
    song.selected_instrument_index = new_instrument_index
    song.selected_sample_index = 1
    renoise.song().instruments[renoise.song().selected_instrument_index].samples[1].interpolation_mode = preferences.selectionNewInstrumentInterpolation.value
    renoise.song().instruments[renoise.song().selected_instrument_index].samples[1].oversample_enabled = preferences.pakettiLoaderOverSampling.value
    renoise.song().instruments[renoise.song().selected_instrument_index].samples[1].autofade = preferences.selectionNewInstrumentAutoFade.value
    renoise.song().instruments[renoise.song().selected_instrument_index].samples[1].autoseek = preferences.selectionNewInstrumentAutoseek.value
    renoise.song().instruments[renoise.song().selected_instrument_index].samples[1].oneshot = preferences.pakettiLoaderOneshot.value
    print("Selected the new instrument and sample.")
  else
  local plusOne=renoise.song().selected_instrument_index+1
    song.selected_instrument_index = selected_instrument_index
    renoise.song().instruments[new_instrument_index].samples[1].interpolation_mode=preferences.selectionNewInstrumentInterpolation.value
    renoise.song().instruments[new_instrument_index].samples[1].oversample_enabled=preferences.pakettiLoaderOverSampling.value
    renoise.song().instruments[new_instrument_index].samples[1].autofade=preferences.selectionNewInstrumentAutoFade.value
    renoise.song().instruments[new_instrument_index].samples[1].autoseek=preferences.selectionNewInstrumentAutoseek.value
    renoise.song().instruments[new_instrument_index].samples[1].oneshot=preferences.pakettiLoaderOneshot.value
    print("Stayed in the current sample editor view of the instrument you chopped out of.")
  end

  renoise.app():show_status("New instrument created from selection with " .. loop_mode_message .. ".")
else
renoise.app():show_status("There is no sample in the sample slot, doing nothing.")
end


end

renoise.tool():add_keybinding{name="Global:Paketti:Create New Instrument & Loop from Selection", invoke=create_new_instrument_from_selection}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Create New Instrument & Loop from Selection", invoke=create_new_instrument_from_selection}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Create New Instrument & Loop from Selection", invoke=create_new_instrument_from_selection}

-- Function to load a pitchbend instrument
function pitchedInstrument(st)
  renoise.app():load_instrument("Presets/" .. st .. "st_Pitchbend.xrni")
  local selected_instrument = renoise.song().selected_instrument
  selected_instrument.name = st .. "st_Pitchbend Instrument"
  selected_instrument.macros_visible = true
  selected_instrument.sample_modulation_sets[1].name = st .. "st_Pitchbend"
end

-------------
function pitchBendMultipleSampleLoader(normalize)
  local selected_sample_filenames = renoise.app():prompt_for_multiple_filenames_to_read({"*.wav", "*.aif", "*.flac", "*.mp3", "*.aiff"}, "Paketti PitchBend Multiple Sample Loader")

  if #selected_sample_filenames > 0 then
    rprint(selected_sample_filenames)
    for index, filename in ipairs(selected_sample_filenames) do
      local next_instrument = renoise.song().selected_instrument_index + 1
      renoise.song():insert_instrument_at(next_instrument)
      renoise.song().selected_instrument_index = next_instrument

      pakettiPreferencesDefaultInstrumentLoader()

      local selected_instrument = renoise.song().selected_instrument
      selected_instrument.name = "Pitchbend Instrument"
      selected_instrument.macros_visible = true
      selected_instrument.sample_modulation_sets[1].name = "Pitchbend"

      if #selected_instrument.samples == 0 then
        selected_instrument:insert_sample_at(1)
      end
      renoise.song().selected_sample_index = 1

      local filename_only = filename:match("^.+[/\\](.+)$")
      local instrument_slot_hex = string.format("%02X", next_instrument - 1)

      if selected_instrument.samples[1].sample_buffer:load_from(filename) then
        renoise.app():show_status("Sample " .. filename_only .. " loaded successfully.")
        local current_sample = selected_instrument.samples[1]
        current_sample.name = string.format("%s_%s", instrument_slot_hex, filename_only)
        selected_instrument.name = string.format("%s_%s", instrument_slot_hex, filename_only)

        current_sample.interpolation_mode = preferences.pakettiLoaderInterpolation.value
        current_sample.oversample_enabled = preferences.pakettiLoaderOverSampling.value
        current_sample.autofade = preferences.pakettiLoaderAutoFade.value
        current_sample.autoseek = preferences.pakettiLoaderAutoseek.value
        current_sample.loop_mode = preferences.pakettiLoaderLoopMode.value
        current_sample.oneshot = preferences.pakettiLoaderOneshot.value
        current_sample.new_note_action = preferences.pakettiLoaderNNA.value
        current_sample.loop_release = preferences.pakettiLoaderLoopExit.value

        renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR

        G01()
if normalize then normalize_selected_sample() end

        loadnative("Audio/Effects/Native/*Instr. Macros")
        local macro_device = renoise.song().selected_track:device(2)
        macro_device.display_name = string.format("%s_%s", instrument_slot_hex, filename_only)
        renoise.song().selected_track.devices[2].is_maximized = false
      else
        renoise.app():show_status("Failed to load the sample " .. filename_only)
      end
    end
  else
    renoise.app():show_status("No file selected.")
  end
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:Paketti PitchBend Multiple Sample Loader", invoke=function() pitchBendMultipleSampleLoader() end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Paketti PitchBend Multiple Sample Loader", invoke=function() pitchBendMultipleSampleLoader() end}
renoise.tool():add_menu_entry{name="Disk Browser Files:Paketti..:Paketti PitchBend Multiple Sample Loader", invoke=function() pitchBendMultipleSampleLoader() end}
renoise.tool():add_keybinding{name="Global:Paketti:Paketti PitchBend Multiple Sample Loader", invoke=function() pitchBendMultipleSampleLoader() end}
renoise.tool():add_keybinding{name="Global:Paketti:Paketti PitchBend Multiple Sample Loader (Normalize)", invoke=function() pitchBendMultipleSampleLoader(true) end}
renoise.tool():add_midi_mapping{name="Paketti:Midi Paketti PitchBend Multiple Sample Loader", invoke=function(message) if message:is_trigger() then pitchBendMultipleSampleLoader() end end}


-----------
function noteOnToNoteOff(noteoffPitch)
  -- Ensure there are samples in the selected instrument
  if #renoise.song().instruments[renoise.song().selected_instrument_index].samples == 0 then
    return
  end

  local instrument = renoise.song().instruments[renoise.song().selected_instrument_index]

  -- Check if there are slice markers in any sample
  for _, sample in ipairs(instrument.samples) do
    if #sample.slice_markers > 0 then
      renoise.app():show_status("Operation not performed: Instrument contains sliced samples.")
      return
    end
  end

  -- Clear the note-off layer
  for i = #instrument.samples, 1, -1 do
    if instrument.samples[i].sample_mapping.layer == 2 then
      instrument:delete_sample_at(i)
    end
  end

  -- Iterate over each sample in the note-on layer
  for i = 1, #instrument.samples do
    local note_on_sample = instrument.samples[i]

    -- Determine the mute group for the note-on sample
    local mute_group = note_on_sample.mute_group
    if mute_group == 0 then -- No mute group set
      mute_group = 15 -- Set to Group F (group index is 15)
      note_on_sample.mute_group = mute_group
    end

    -- Insert new sample at the end for the note-off layer
    local new_sample_index = #instrument.samples + 1
    instrument:insert_sample_at(new_sample_index)
    renoise.song().selected_sample_index = new_sample_index

    local note_off_sample = instrument.samples[new_sample_index]

    -- Copy properties from note-on sample to note-off sample
    note_off_sample:copy_from(note_on_sample)
    note_off_sample.sample_mapping.layer = 2 -- Set layer to note-off
    note_off_sample.mute_group = mute_group -- Ensure same mute group

    -- Transpose the note-off sample
    note_off_sample.transpose = noteoffPitch
    note_off_sample.name = note_on_sample.name
  end

  -- Reset selection to the first note-on sample
  renoise.song().selected_sample_index = 1
end

-- Add menu entries for various transpositions
renoise.tool():add_menu_entry{name="--Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer +24", invoke=function() noteOnToNoteOff(24) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer +12", invoke=function() noteOnToNoteOff(12) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer", invoke=function() noteOnToNoteOff(0) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer -12", invoke=function() noteOnToNoteOff(-12) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer -24", invoke=function() noteOnToNoteOff(-24) end}

renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer +24", invoke=function() noteOnToNoteOff(24) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer +12", invoke=function() noteOnToNoteOff(12) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer", invoke=function() noteOnToNoteOff(0) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer -12", invoke=function() noteOnToNoteOff(-12) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer -24", invoke=function() noteOnToNoteOff(-24) end}

renoise.tool():add_menu_entry{name="--Sample Navigator:Paketti..:Copy Sample in Note-On to Note-Off Layer +24", invoke=function() noteOnToNoteOff(24) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Copy Sample in Note-On to Note-Off Layer +12", invoke=function() noteOnToNoteOff(12) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Copy Sample in Note-On to Note-Off Layer", invoke=function() noteOnToNoteOff(0) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Copy Sample in Note-On to Note-Off Layer -12", invoke=function() noteOnToNoteOff(-12) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Copy Sample in Note-On to Note-Off Layer -24", invoke=function() noteOnToNoteOff(-24) end}


------------
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Selected Sample:Autofade True, Interpolation Sinc, Oversample True",invoke=function() 
  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].autofade=true
  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].interpolation_mode=4
  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].oversample_enabled=true
end}
-----------
-- TODO you might wanna do something about this
function selectedSampleInit()
renoise.song().instruments[renoise.song().selected_instrument_index].macros_visible=true
renoise.song().instruments[renoise.song().selected_instrument_index].macros[1].name="PitchCtrl"
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].autofade=true
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].interpolation_mode=4
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].oversample_enabled=true
end

renoise.tool():add_keybinding{name="Global:Paketti:Init Selected Sample (Autofade,Interpolation,Oversample)", invoke=function() 
selectedSampleInit() end}
---------
function addSampleSlot(amount)
for i=1,amount do
renoise.song().instruments[renoise.song().selected_instrument_index]:insert_sample_at(i)
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Add Sample Slot to Instrument", invoke=function() addSampleSlot(1) end}
renoise.tool():add_keybinding{name="Global:Paketti:Add 84 Sample Slots to Instrument", invoke=function() addSampleSlot(84) end}
--renoise.tool():add_menu_entry{name="Sample List:Paketti..:Add 84 Sample Slots to Instrument", invoke=function() addSampleSlot(84) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Add 84 Sample Slots to Instrument", invoke=function() addSampleSlot(84) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Add 84 Sample Slots to Instrument", invoke=function() addSampleSlot(84) end}

-------------------------------------------------------------------------------------------------------------------------------
function oneshotcontinue()
  local s=renoise.song()
  local sli=s.selected_instrument_index
  local ssi=s.selected_sample_index

  if s.instruments[sli].samples[ssi].oneshot
then s.instruments[sli].samples[ssi].oneshot=false
     s.instruments[sli].samples[ssi].new_note_action=1
else s.instruments[sli].samples[ssi].oneshot=true
     s.instruments[sli].samples[ssi].new_note_action=3 end end

renoise.tool():add_keybinding{name="Global:Paketti:Set Sample to One-Shot + NNA Continue",invoke=function() oneshotcontinue() end}
----------------
function LoopState(number)
renoise.song().selected_sample.loop_mode=number
end

renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 1 Off",invoke=function() LoopState(1) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 2 Forward",invoke=function() LoopState(2) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 3 Reverse",invoke=function() LoopState(3) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Set Loop Mode to 4 PingPong",invoke=function() LoopState(4) end}
------------------

function slicerough(changer)
local G01CurrentState = preferences._0G01_Loader.value
    if preferences._0G01_Loader.value == true or preferences._0G01_Loader.value == false 
    then preferences._0G01_Loader.value = false
    end

manage_sample_count_observer(preferences._0G01_Loader.value)

    local s = renoise.song()
    local currInst = s.selected_instrument_index

    -- Check if the instrument has samples
    if #s.instruments[currInst].samples == 0 then
        renoise.app():show_status("No samples available in the selected instrument.")
        return
    end

    s.selected_sample_index = 1
    local currSamp = s.selected_sample_index
    
    local beatsync_lines={
      [2]=64,
      [4]=32,
      [8]=16,
      [16]=8,
      [32]=4,
      [64]=2,
      [128]=1}
local beatsynclines = nil
local dontsync = nil
if s.instruments[currInst].samples[1].beat_sync_enabled then
beatsynclines = s.instruments[currInst].samples[1].beat_sync_lines
else
  dontsync=true
  beatsynclines = 0
    -- Determine the appropriate beatsync lines from the table or use a default value
 --   renoise.app():show_status("Please set Beatsync Lines Value before Wipe&Slice, for accurate slicing.")
--   beatsynclines = beatsync_lines[changer] or 64
--return
end
    local currentTranspose = s.selected_sample.transpose

    -- Clear existing slice markers from the first sample
    for i = #s.instruments[currInst].samples[1].slice_markers, 1, -1 do
        s.instruments[currInst].samples[1]:delete_slice_marker(s.instruments[currInst].samples[1].slice_markers[i])
    end

    -- Insert new slice markers
    local tw = s.selected_sample.sample_buffer.number_of_frames / changer
    s.instruments[currInst].samples[currSamp]:insert_slice_marker(1)
    for i = 1, changer - 1 do
        s.instruments[currInst].samples[currSamp]:insert_slice_marker(tw * i)
    end

-- Apply settings to all samples created by the slicing
-- Apply settings to all samples created by the slicing
for i, sample in ipairs(s.instruments[currInst].samples) do
    sample.new_note_action = preferences.WipeSlices.WipeSlicesNNA.value
    sample.oneshot = preferences.WipeSlices.WipeSlicesOneShot.value
    sample.autoseek = preferences.WipeSlices.WipeSlicesAutoseek.value
    sample.mute_group = preferences.WipeSlices.WipeSlicesMuteGroup.value

    if dontsync then 
        sample.beat_sync_enabled = false
    else
        sample.beat_sync_mode = preferences.WipeSlices.WipeSlicesBeatSyncMode.value

        -- Only set beat_sync_lines if beatsynclines is valid
        if beatsynclines / changer < 1 then 
            sample.beat_sync_lines = beatsynclines
        else 
            sample.beat_sync_lines = beatsynclines / changer
        end

        -- Enable beat sync for this sample since dontsync is false
        sample.beat_sync_enabled = true
    end

    sample.loop_mode = preferences.WipeSlices.WipeSlicesLoopMode.value
    sample.loop_release = preferences.WipeSlices.WipeSlicesLoopRelease.value
    sample.transpose = currentTranspose
    sample.autofade = true
    sample.interpolation_mode = 4
    sample.oversample_enabled = true
end

    -- Ensure beat sync is enabled for the original sample
--    s.instruments[currInst].samples[1].beat_sync_lines = 128

if dontsync ~= true then 
    s.instruments[currInst].samples[1].beat_sync_lines = beatsynclines
    s.instruments[currInst].samples[1].beat_sync_enabled = true
else end
    -- Show status with sample name and number of slices
    local sample_name = renoise.song().selected_instrument.samples[1].name
    local num_slices = #s.instruments[currInst].samples[currSamp].slice_markers
    renoise.app():show_status(sample_name .. " now has " .. num_slices .. " slices.")
    
preferences._0G01_Loader.value=G01CurrentState 
manage_sample_count_observer(preferences._0G01_Loader.value)
end

function wipeslices()
    -- Retrieve the currently selected instrument index
    local s = renoise.song()
    local currInst = s.selected_instrument_index

    -- Check if there is a valid instrument selected
    if currInst == nil or currInst == 0 then
        renoise.app():show_status("No instrument selected.")
        return
    end

    -- Check if there are any samples in the selected instrument
    if #s.instruments[currInst].samples == 0 then
        renoise.app():show_status("No samples available in the selected instrument.")
        return
    end

    -- Ensure we iterate over all samples in the selected instrument
    local instrument = s.instruments[currInst]
    for i = 1, #instrument.samples do
        local sample = instrument.samples[i]

        -- Check if the sample is valid
        if sample then
            local slice_markers = sample.slice_markers
            local number = #slice_markers

            -- Delete each slice marker if there are any
            if number > 0 then
                for j = number, 1, -1 do
                    sample:delete_slice_marker(slice_markers[j])
                end
            end

            -- Set loop mode to Off and disable beat sync for the sample
            sample.loop_mode = renoise.Sample.LOOP_MODE_OFF
            sample.beat_sync_enabled = false
        end
    end

    -- Confirm slices have been wiped
    renoise.app():show_status(instrument.name .. " now has 0 slices.")
end

renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Slice (2)",invoke=function() slicerough(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Slice (4)",invoke=function() slicerough(4) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Slice (8)",invoke=function() slicerough(8) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Slice (16)",invoke=function() slicerough(16) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Slice (32)",invoke=function() slicerough(32) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Slice (64)",invoke=function() slicerough(64) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Slice (128)",invoke=function() slicerough(128) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe Slices",invoke=function() wipeslices() end}

renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Slice..:Wipe&Slice (2)",invoke=function() slicerough(2) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Slice..:Wipe&Slice (4)",invoke=function() slicerough(4) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Slice..:Wipe&Slice (8)",invoke=function() slicerough(8) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Slice..:Wipe&Slice (16)",invoke=function() slicerough(16) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Slice..:Wipe&Slice (32)",invoke=function() slicerough(32) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Slice..:Wipe&Slice (64)",invoke=function() slicerough(64) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Slice..:Wipe&Slice (128)",invoke=function() slicerough(128) end}
renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Wipe&Slice..:Wipe Slices",invoke=function() wipeslices() end}

renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Slice (2)",invoke=function() slicerough(2) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Slice (4)",invoke=function() slicerough(4) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Slice (8)",invoke=function() slicerough(8) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Slice (16)",invoke=function() slicerough(16) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Slice (32)",invoke=function() slicerough(32) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Slice (64)",invoke=function() slicerough(64) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Slice (128)",invoke=function() slicerough(128) end}
renoise.tool():add_menu_entry{name="--Sample Navigator:Paketti..:Wipe&Slice..:Wipe Slices",invoke=function() wipeslices() end}

renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Slice (2)",invoke=function() slicerough(2) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Slice (4)",invoke=function() slicerough(4) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Slice (8)",invoke=function() slicerough(8) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Slice (16)",invoke=function() slicerough(16) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Slice (32)",invoke=function() slicerough(32) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Slice (64)",invoke=function() slicerough(64) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Slice (128)",invoke=function() slicerough(128) end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Wipe&Slice..:Wipe Slices",invoke=function() wipeslices() end}







renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Double BeatSync Line",invoke=function() doubleBeatSyncLines() end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Halve BeatSync Line",invoke=function() halveBeatSyncLines() end}
--------------
function DSPFXChain()
renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS end

renoise.tool():add_keybinding{name="Global:Paketti:Show DSP FX Chain",invoke=function() DSPFXChain() end}
---
function pakettiSaveSample(format)
if renoise.song().selected_sample == nil then return else

local filename = renoise.app():prompt_for_filename_to_write(format, "Paketti Save Selected Sample in ." .. format .. " Format")
if filename == "" then return else 
renoise.song().selected_sample.sample_buffer:save_as(filename, format)
renoise.app():show_status("Saved sample as " .. format .. " in " .. filename)

end 
end
end
renoise.tool():add_keybinding{name="Global:Paketti:Paketti Save Selected Sample .WAV",invoke=function() pakettiSaveSample("WAV") end}
renoise.tool():add_keybinding{name="Global:Paketti:Paketti Save Selected Sample .FLAC",invoke=function() pakettiSaveSample("FLAC") end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Paketti Save Selected Sample .WAV",invoke=function() pakettiSaveSample("WAV") end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Paketti Save Selected Sample .FLAC",invoke=function() pakettiSaveSample("FLAC") end}
renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Paketti Save Selected Sample .WAV",invoke=function() pakettiSaveSample("WAV") end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Paketti Save Selected Sample .FLAC",invoke=function() pakettiSaveSample("FLAC") end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Paketti Save Selected Sample Range .WAV",invoke=function() pakettiSaveSampleRange("WAV") end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Paketti Save Selected Sample Range .FLAC",invoke=function() pakettiSaveSampleRange("FLAC") end}


renoise.tool():add_menu_entry{name="--Sample Navigator:Paketti..:Paketti Save Selected Sample .WAV",invoke=function() pakettiSaveSample("WAV") end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Paketti Save Selected Sample .FLAC",invoke=function() pakettiSaveSample("FLAC") end}



renoise.tool():add_midi_mapping{name="Paketti:Midi Paketti Save Selected Sample .WAV", invoke=function(message) if message:is_trigger() then pakettiSaveSample("WAV") end end}
renoise.tool():add_midi_mapping{name="Paketti:Midi Paketti Save Selected Sample .FLAC", invoke=function(message) if message:is_trigger() then pakettiSaveSample("FLAC") end end}
------------
-- Define global variables to store the temporary filename and names
tmpvariable=nil
instrument_name=nil
sample_name=nil

-- Function to wipe the song while retaining the current sample
function WipeRetain()
  local s=renoise.song()
  local selected_sample=s.selected_sample
  local selected_instrument=s.selected_instrument
  if selected_sample and selected_instrument and #selected_instrument.samples>0 then
    local sample_buffer=selected_sample.sample_buffer
    if sample_buffer.has_sample_data then
      tmpvariable=os.tmpname()..".wav"
      instrument_name=selected_instrument.name
      local slice_markers=selected_sample.slice_markers

      -- Check if there are slices
      if slice_markers and #slice_markers>0 then
        -- Determine slice number and get the start and end positions
        local slice_number=selected_sample.slice_number
        local start_pos=slice_number>1 and slice_markers[slice_number-1] or 0
        local end_pos=slice_number<=#slice_markers and slice_markers[slice_number] or sample_buffer.number_of_frames

        -- Extract and save slice data
        sample_name=instrument_name.." - Slice"..slice_number
        local slice_buffer=sample_buffer:create_sample_data(1,sample_buffer.sample_rate,end_pos-start_pos+1)
        sample_buffer:copy_to(slice_buffer,0,start_pos,end_pos-start_pos+1)
        slice_buffer:save_as(tmpvariable,"wav")
      else
        -- No slices, save the entire sample
        sample_name=selected_sample.name
        sample_buffer:save_as(tmpvariable,"wav")
      end

      -- Add notifier and create a new song
      if not renoise.tool().app_new_document_observable:has_notifier(WipeRetainFinish) then
        renoise.tool().app_new_document_observable:add_notifier(WipeRetainFinish)
      end
      renoise.app():new_song()
    else
      renoise.app():show_status("Instrument/Selection has no Sample data")
    end
  else
    renoise.app():show_status("Instrument/Selection has no Sample data")
  end
end

-- Function to finish the process of wiping the song and retaining the sample
function WipeRetainFinish()
  local s=renoise.song()
  pakettiPreferencesDefaultInstrumentLoader()
  
  local instrument=s.instruments[1]
  instrument.name=instrument_name
  
  local sample=instrument:insert_sample_at(1)
  sample.name=sample_name
  sample.sample_buffer:load_from(tmpvariable)
  
  renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
  os.remove(tmpvariable)
  renoise.tool().app_new_document_observable:remove_notifier(WipeRetainFinish)
end

-- Add a keybinding and menu entries to invoke the WipeRetain function
renoise.tool():add_keybinding{name="Global:Paketti:Wipe Song Retain Sample",invoke=function() WipeRetain() end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Wipe Song Retain Sample",invoke=function() WipeRetain() end}
renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Wipe Song Retain Sample",invoke=function() WipeRetain() end}
renoise.tool():add_menu_entry{name="--Sample Navigator:Paketti..:Wipe Song Retain Sample",invoke=function() WipeRetain() end}

--------
-- Define render state (initialized when starting to render)
render_context = {
    source_track = 0,
    target_track = 0,
    target_instrument = 0,
    temp_file_path = ""
}

-- Function to initiate rendering
function start_rendering()
    local render_priority = "high"
    local selected_track = renoise.song().selected_track

    for _, device in ipairs(selected_track.devices) do
        if device.name == "#Line Input" then
            render_priority = "realtime"
            break
        end
    end

    -- Set up rendering options
    local render_options = {
        sample_rate = preferences.renderSampleRate.value,
        bit_depth = preferences.renderBitDepth.value,
        interpolation = "precise",
        priority = render_priority,
        start_pos = renoise.SongPos(renoise.song().selected_sequence_index, 1),
        end_pos = renoise.SongPos(renoise.song().selected_sequence_index, renoise.song().patterns[renoise.song().selected_pattern_index].number_of_lines),
    }

    -- Set render context
    render_context.source_track = renoise.song().selected_track_index
    render_context.target_track = render_context.source_track + 1
    render_context.target_instrument = renoise.song().selected_instrument_index + 1
    render_context.temp_file_path = os.tmpname() .. ".wav"

    -- Start rendering with the correct function call
    local success, error_message = renoise.song():render(render_options, render_context.temp_file_path, rendering_done_callback)
    if not success then
        print("Rendering failed: " .. error_message)
    else
        -- Start a timer to monitor rendering progress
        renoise.tool():add_timer(monitor_rendering, 500)
    end
end

-- Callback function that gets called when rendering is complete
function rendering_done_callback()
    local song = renoise.song()
    local renderTrack = render_context.source_track
    local renderedTrack = renderTrack + 1
    local renderedInstrument = render_context.target_instrument

    -- Remove the monitoring timer
    renoise.tool():remove_timer(monitor_rendering)

    -- Un-Solo Selected Track
    song.tracks[renderTrack]:solo()

    -- Turn All Render Track Note Columns to "Off"
    for i = 1, song.tracks[renderTrack].max_note_columns do
        song.tracks[renderTrack]:set_column_is_muted(i, true)
    end

if preferences.renderBypass.value == true then 

for i = 2, #renoise.song().selected_track.devices do
 renoise.song().selected_track.devices[i].is_active=false
end else end

    -- Collapse Render Track
    song.tracks[renderTrack].collapsed = true
    -- Change Selected Track to Rendered Track
    renoise.song().selected_track_index = renoise.song().selected_track_index + 1
    pakettiPreferencesDefaultInstrumentLoader()
    -- Add *Instr. Macros to Rendered Track
    --song:insert_instrument_at(renderedInstrument)
    local new_instrument = song:instrument(renoise.song().selected_instrument_index)

    -- Load Sample into New Instrument Sample Buffer
    new_instrument.samples[1].sample_buffer:load_from(render_context.temp_file_path)
    os.remove(render_context.temp_file_path)

    -- Set the selected_instrument_index to the newly created instrument
    song.selected_instrument_index = renderedInstrument - 1

    -- Insert New Track Next to Render Track
    song:insert_track_at(renderedTrack)
    local renderName = song.tracks[renderTrack].name
    song.selected_pattern.tracks[renderedTrack].lines[1].note_columns[1].note_string = "C-4"
    song.selected_pattern.tracks[renderedTrack].lines[1].note_columns[1].instrument_value = renoise.song().selected_instrument_index - 1
    --    song.selected_pattern.tracks[renderedTrack].lines[1].effect_columns[1].number_string = "0G"
    --    song.selected_pattern.tracks[renderedTrack].lines[1].effect_columns[1].amount_value = 01 
    -- Add Instr* Macros to selected Track
    loadnative("Audio/Effects/Native/*Instr. Macros")
    renoise.song().selected_track.devices[2].is_maximized = false

    -- Rename Sample Slot to Render Track
    new_instrument.samples[1].name = renderName .. " (Rendered)"

    -- Select New Track
    print(renderedTrack .. " this was the track but is it really the track?")
    song.selected_track_index = renderedTrack

    -- Rename New Track using Render Track Name
    song.tracks[renderedTrack].name = renderName .. " (Rendered)"
    new_instrument.name = renderName .. " (Rendered)"
    new_instrument.samples[1].autofade = true
    --    new_instrument.samples[1].autoseek = true
if renoise.song().transport.edit_mode then
renoise.song().transport.edit_mode = false
renoise.song().transport.edit_mode = true
else
renoise.song().transport.edit_mode = true
renoise.song().transport.edit_mode = false
end

end

-- Function to monitor rendering progress
function monitor_rendering()
    if renoise.song().rendering then
        local progress = renoise.song().rendering_progress
        print("Rendering in progress: " .. (progress * 100) .. "% complete")
    else
        -- Remove the monitoring timer once rendering is complete or if it wasn't started
        renoise.tool():remove_timer(monitor_rendering)
        print("Rendering not in progress or already completed.")
    end
end

-- Function to handle rendering for a group track
function render_group_track()
    local song = renoise.song()
    local group_track_index = song.selected_track_index
    local group_track = song:track(group_track_index)
    local start_track_index = group_track_index + 1
    local end_track_index = start_track_index + group_track.visible_note_columns - 1

    for i = start_track_index, end_track_index do
        song:track(i):solo()
    end

    -- Set rendering options and start rendering
    start_rendering()
end

function pakettiCleanRenderSelection()
    local song = renoise.song()
    local renderTrack = song.selected_track_index
    local renderedTrack = renderTrack + 1
    local renderedInstrument = song.selected_instrument_index + 1

    -- Print the initial selected_instrument_index
    print("Initial selected_instrument_index: " .. song.selected_instrument_index)

    -- Create New Instrument
    song:insert_instrument_at(renderedInstrument)

    -- Select New Instrument
    song.selected_instrument_index = renderedInstrument

    -- Print the selected_instrument_index after creating new instrument
    print("selected_instrument_index after creating new instrument: " .. song.selected_instrument_index)

    -- Check if the selected track is a group track
    if song:track(renderTrack).type == renoise.Track.TRACK_TYPE_GROUP then
        -- Render the group track
        render_group_track()
    else
        -- Solo Selected Track
        song.tracks[renderTrack]:solo()

        -- Render Selected Track
        start_rendering()
    end
end

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Clean Render Selected Track/Group", invoke = function() pakettiCleanRenderSelection() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Clean Render Selected Track/Group", invoke = function() pakettiCleanRenderSelection() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Clean Render Selected Track/Group", invoke = function() pakettiCleanRenderSelection() end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Clean Render Selected Track/Group", invoke = function() pakettiCleanRenderSelection() end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Clean Render Selected Track/Group", invoke = function() pakettiCleanRenderSelection() end}
renoise.tool():add_keybinding{name="Mixer:Paketti:Clean Render Selected Track/Group", invoke = function() pakettiCleanRenderSelection() end}
------
-- Define render state (initialized when starting to render)
render_context = {
    source_track = 0,
    target_track = 0,
    target_instrument = 0,
    temp_file_path = ""
}

-- Function to initiate rendering
function start_renderingLPB()
    local render_priority = "high"
    local selected_track = renoise.song().selected_track

    for _, device in ipairs(selected_track.devices) do
        if device.name == "#Line Input" then
            render_priority = "realtime"
            break
        end
    end

    -- Set up rendering options
    local render_options = {
        sample_rate = preferences.renderSampleRate.value,
        bit_depth = preferences.renderBitDepth.value,
        interpolation = "precise",
        priority = render_priority,
        start_pos = renoise.SongPos(renoise.song().selected_sequence_index, 1),
        end_pos = renoise.SongPos(renoise.song().selected_sequence_index, renoise.song().patterns[renoise.song().selected_pattern_index].number_of_lines),
    }

    -- Set render context
    render_context.source_track = renoise.song().selected_track_index
    render_context.target_track = render_context.source_track + 1
    render_context.target_instrument = renoise.song().selected_instrument_index + 1
    render_context.temp_file_path = os.tmpname() .. ".wav"

    -- Start rendering with the correct function call
    local success, error_message = renoise.song():render(render_options, render_context.temp_file_path, rendering_done_callbackLPB)
    if not success then
        print("Rendering failed: " .. error_message)
    else
        -- Start a timer to monitor rendering progress
        renoise.tool():add_timer(monitor_renderingLPB, 500)
    end
end

-- Callback function that gets called when rendering is complete
function rendering_done_callbackLPB()
    local song = renoise.song()
    local renderTrack = render_context.source_track
    local renderedTrack = renderTrack + 1
    local renderedInstrument = render_context.target_instrument

    -- Remove the monitoring timer
    renoise.tool():remove_timer(monitor_renderingLPB)

    -- Un-Solo Selected Track
    song.tracks[renderTrack]:solo()

    -- Turn All Render Track Note Columns to "Off"
    for i = 1, song.tracks[renderTrack].max_note_columns do
        song.tracks[renderTrack]:set_column_is_muted(i, true)
    end

    -- Collapse Render Track
    song.tracks[renderTrack].collapsed = true
    -- Change Selected Track to Rendered Track
    renoise.song().selected_track_index = renoise.song().selected_track_index + 1
    pakettiPreferencesDefaultInstrumentLoader()
    -- Add *Instr. Macros to Rendered Track
    --song:insert_instrument_at(renderedInstrument)
    local new_instrument = song:instrument(renoise.song().selected_instrument_index)

    -- Load Sample into New Instrument Sample Buffer
    new_instrument.samples[1].sample_buffer:load_from(render_context.temp_file_path)
    os.remove(render_context.temp_file_path)

    -- Set the selected_instrument_index to the newly created instrument
    song.selected_instrument_index = renderedInstrument - 1

    -- Insert New Track Next to Render Track
    song:insert_track_at(renderedTrack)
    local renderName = song.tracks[renderTrack].name

local number=nil
local numbertwo=nil
local rs=renoise.song()
write_bpm()
clonePTN()
local nol=nil
      nol=renoise.song().selected_pattern.number_of_lines+renoise.song().selected_pattern.number_of_lines
      renoise.song().selected_pattern.number_of_lines=nol

number=renoise.song().transport.lpb*2
if number == 1 then number = 2 end
if number > 128 then number=128 
renoise.song().transport.lpb=number
  write_bpm()
  Deselect_All()
  MarkTrackMarkPattern()
  MarkTrackMarkPattern()
  ExpandSelection()
  Deselect_All()
  return end
renoise.song().transport.lpb=number
  write_bpm()
  Deselect_All()
  MarkTrackMarkPattern()
  MarkTrackMarkPattern()
  ExpandSelection()
  Deselect_All()

    song.selected_pattern.tracks[renderedTrack].lines[1].note_columns[1].note_string = "C-4"
    song.selected_pattern.tracks[renderedTrack].lines[1].note_columns[1].instrument_value = renoise.song().selected_instrument_index - 1
    --    song.selected_pattern.tracks[renderedTrack].lines[1].effect_columns[1].number_string = "0G"
    --    song.selected_pattern.tracks[renderedTrack].lines[1].effect_columns[1].amount_value = 01 
    -- Add Instr* Macros to selected Track
    loadnative("Audio/Effects/Native/*Instr. Macros")
    renoise.song().selected_track.devices[2].is_maximized = false

    -- Rename Sample Slot to Render Track
    new_instrument.samples[1].name = renderName .. " (Rendered)"

    -- Select New Track
    print(renderedTrack .. " this was the track but is it really the track?")
    song.selected_track_index = renderedTrack

    -- Rename New Track using Render Track Name
    song.tracks[renderedTrack].name = renderName .. " (Rendered)"
    new_instrument.name = renderName .. " (Rendered)"
    new_instrument.samples[1].autofade = true
    --    new_instrument.samples[1].autoseek = true
if renoise.song().transport.edit_mode then
renoise.song().transport.edit_mode = false
renoise.song().transport.edit_mode = true
else
renoise.song().transport.edit_mode = true
renoise.song().transport.edit_mode = false
end

end

-- Function to monitor rendering progress
function monitor_renderingLPB()
    if renoise.song().rendering then
        local progress = renoise.song().rendering_progress
        print("Rendering in progress: " .. (progress * 100) .. "% complete")
    else
        -- Remove the monitoring timer once rendering is complete or if it wasn't started
        renoise.tool():remove_timer(monitor_renderingLPB)
        print("Rendering not in progress or already completed.")
    end
end

-- Function to handle rendering for a group track
function render_group_trackLPB()
    local song = renoise.song()
    local group_track_index = song.selected_track_index
    local group_track = song:track(group_track_index)
    local start_track_index = group_track_index + 1
    local end_track_index = start_track_index + group_track.visible_note_columns - 1

    for i = start_track_index, end_track_index do
        song:track(i):solo()
    end

    -- Set rendering options and start rendering
    start_renderingLPB()
end

function pakettiCleanRenderSelectionLPB()
    local song = renoise.song()
    local renderTrack = song.selected_track_index
    local renderedTrack = renderTrack + 1
    local renderedInstrument = song.selected_instrument_index + 1

    -- Print the initial selected_instrument_index
    print("Initial selected_instrument_index: " .. song.selected_instrument_index)

    -- Create New Instrument
    song:insert_instrument_at(renderedInstrument)

    -- Select New Instrument
    song.selected_instrument_index = renderedInstrument

    -- Print the selected_instrument_index after creating new instrument
    print("selected_instrument_index after creating new instrument: " .. song.selected_instrument_index)

    -- Check if the selected track is a group track
    if song:track(renderTrack).type == renoise.Track.TRACK_TYPE_GROUP then
        -- Render the group track
        render_group_trackLPB()
    else
        -- Solo Selected Track
        song.tracks[renderTrack]:solo()

        -- Render Selected Track
        start_renderingLPB()
    end
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Clean Render Selected Track/Group LPB*2", invoke = function() pakettiCleanRenderSelectionLPB() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Clean Render Selected Track/Group LPB*2", invoke = function() pakettiCleanRenderSelectionLPB() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Clean Render Selected Track/Group LPB*2", invoke = function() pakettiCleanRenderSelectionLPB() end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Clean Render Selected Track/Group LPB*2", invoke = function() pakettiCleanRenderSelectionLPB() end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Clean Render Selected Track/Group LPB*2", invoke = function() pakettiCleanRenderSelectionLPB() end}
renoise.tool():add_keybinding{name="Mixer:Paketti:Clean Render Selected Track/Group LPB*2", invoke = function() pakettiCleanRenderSelectionLPB() end}
------
-- Function to adjust a slice marker based on MIDI input
function adjustSlice(slice_index, midivalue)
    local song = renoise.song()
    local sample = song.selected_sample

    -- Ensure there is a selected sample and enough slice markers
    if not sample or #sample.slice_markers < slice_index then
        return
    end

    local slice_markers = sample.slice_markers
    local min_pos, max_pos

    -- Calculate the bounds for the slice marker movement
    if slice_index == 1 then
        min_pos = 1
        max_pos = (slice_markers[slice_index + 1] or sample.sample_buffer.number_of_frames) - 1
    elseif slice_index == #slice_markers then
        min_pos = slice_markers[slice_index - 1] + 1
        max_pos = sample.sample_buffer.number_of_frames - 1
    else
        min_pos = slice_markers[slice_index - 1] + 1
        max_pos = slice_markers[slice_index + 1] - 1
    end

    -- Scale MIDI input (0-127) to the range between min_pos and max_pos
    local new_pos = min_pos + math.floor((max_pos - min_pos) * (midivalue / 127))

    -- Move the slice marker
    sample:move_slice_marker(slice_markers[slice_index], new_pos)
end

-- Create MIDI mappings for up to 16 slice markers
for i = 1, 9 do
    renoise.tool():add_midi_mapping{name="Paketti:Midi Change Slice 0" .. i,
        invoke = function(message)
            if message:is_abs_value() then
                adjustSlice(i, message.int_value)
            end
        end
    }
end

for i = 10, 32 do
    renoise.tool():add_midi_mapping{name="Paketti:Midi Change Slice " .. i,
        invoke = function(message)
            if message:is_abs_value() then
                adjustSlice(i, message.int_value)
            end
        end
    }
end

renoise.tool():add_midi_mapping{name="Paketti:Midi Select Padded Slice (Next)",invoke=function(message) if message:is_trigger() then  selectNextSliceInOriginalSample() end end}

renoise.tool():add_midi_mapping{name="Paketti:Midi Select Padded Slice (Previous)",invoke=function(message) if message:is_trigger() then  selectPreviousSliceInOriginalSample() end end}
-------------------
-- Function to select the next slice
function selectNextSliceInOriginalSample()
  local instrument = renoise.song().selected_instrument
  
  -- Check if the selected sample exists
  local selected_sample_index = renoise.song().selected_sample_index
  if not instrument.samples[selected_sample_index] then
    renoise.app():show_status("No sample selected or invalid sample index.")
    return
  end

  local sample = instrument.samples[selected_sample_index]

  -- Ensure the sample buffer exists and has sample data
  if not sample.sample_buffer or not sample.sample_buffer.has_sample_data then
    renoise.app():show_status("Selected sample has no data.")
    return
  end

  local sliceMarkers = sample.slice_markers
  local sampleLength = sample.sample_buffer.number_of_frames

  if #sliceMarkers < 2 or not sample.sample_buffer.has_sample_data then
    renoise.app():show_status("Not enough slice markers or sample data is unavailable.")
    return
  end

  local currentSliceIndex = preferences.WipeSlices.sliceCounter.value
  local nextSliceIndex = currentSliceIndex + 1
  if nextSliceIndex > #sliceMarkers then
    nextSliceIndex = 1
  end

  local thisSlice = sliceMarkers[currentSliceIndex] or 0
  local nextSlice = sliceMarkers[nextSliceIndex] or sampleLength

  local thisSlicePadding = (currentSliceIndex == 1 and thisSlice < 1000) and thisSlice or math.max(thisSlice - 1000, 1)
  local nextSlicePadding = (nextSliceIndex == 1) and math.min(nextSlice + sampleLength, sampleLength) or math.min(nextSlice + 1354, sampleLength)

  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
  sample.sample_buffer.display_range = {thisSlicePadding, nextSlicePadding}
  sample.sample_buffer.display_length = nextSlicePadding - thisSlicePadding

  renoise.app():show_status(string.format("Slice Info - Current index: %d, Next index: %d, Slice Start: %d, Slice End: %d", currentSliceIndex, nextSliceIndex, thisSlicePadding, nextSlicePadding))
  
  preferences.WipeSlices.sliceCounter.value = nextSliceIndex
end

-- Function to select the previous slice with proper handling of slice wrapping
function selectPreviousSliceInOriginalSample()
  local instrument = renoise.song().selected_instrument
  
  -- Check if the selected sample exists
  local selected_sample_index = renoise.song().selected_sample_index
  if not instrument.samples[selected_sample_index] then
    renoise.app():show_status("No sample selected or invalid sample index.")
    return
  end

  local sample = instrument.samples[selected_sample_index]

  -- Ensure the sample buffer exists and has sample data
  if not sample.sample_buffer or not sample.sample_buffer.has_sample_data then
    renoise.app():show_status("Selected sample has no data.")
    return
  end

  local sliceMarkers = sample.slice_markers
  local sampleLength = sample.sample_buffer.number_of_frames
  
  if #sliceMarkers < 2 or not sample.sample_buffer.has_sample_data then
    renoise.app():show_status("Not enough slice markers or sample data unavailable.")
    return
  end
  
  local currentSliceIndex = preferences.WipeSlices.sliceCounter.value
  local previousSliceIndex = currentSliceIndex - 1
  
  if previousSliceIndex < 1 then
    previousSliceIndex = #sliceMarkers  -- Wrap to the last slice
  end

  local previousSlice = sliceMarkers[previousSliceIndex] or 0
  local nextSliceIndex = previousSliceIndex == #sliceMarkers and 1 or previousSliceIndex + 1
  local nextSlice = sliceMarkers[nextSliceIndex] or sampleLength

  -- Calculate the padding for display
  local previousSlicePadding = math.max(previousSlice - 1000, 1)
  local nextSlicePadding = math.min(nextSlice + 1354, sampleLength)

  -- Adjust for wraparound display issue when navigating from first to last slice
  if previousSliceIndex == #sliceMarkers and currentSliceIndex == 1 then
    nextSlicePadding = sampleLength
  end

  -- Set display parameters in the sample editor
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
  sample.sample_buffer.display_range = {previousSlicePadding, nextSlicePadding}
  sample.sample_buffer.display_length = nextSlicePadding - previousSlicePadding

  -- Show status and update slice counter
  renoise.app():show_status(string.format("Slice Info - Previous index: %d, Current index: %d, Slice Start: %d, Slice End: %d", previousSliceIndex, nextSliceIndex, previousSlicePadding, nextSlicePadding))
  
  preferences.WipeSlices.sliceCounter.value = previousSliceIndex
end

-- Function to reset the slice counter
function resetSliceCounter()
  preferences.WipeSlices.sliceCounter.value = 1
  renoise.app():show_status("Slice counter reset to 1. Will start from the first slice.")
  selectNextSliceInOriginalSample()
end

renoise.tool():add_keybinding{name="Sample Editor:Paketti:Select Padded Slice (Next)", invoke=selectNextSliceInOriginalSample}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Select Padded Slice (Previous)", invoke=function() selectPreviousSliceInOriginalSample() end}
renoise.tool():add_keybinding{name="Global:Paketti:Reset Slice Counter", invoke=resetSliceCounter}

-- Function to select and display a padded slice from the current slice
function selectPaddedSliceFromCurrentSlice()
  local instrument = renoise.song().selected_instrument

  -- Check if the selected sample exists
  local selected_sample_index = renoise.song().selected_sample_index
  if not instrument.samples[selected_sample_index] then
    renoise.app():show_status("No sample selected or invalid sample index.")
    return
  end

  -- If not on the original sample, determine the slice index
  local currentSliceIndex = selected_sample_index - 1
  if selected_sample_index ~= 1 then
    -- Debug info
    print(string.format("Currently in slice index: %d", currentSliceIndex))

    -- Set the selected sample index to 1 (the original sample)
    renoise.song().selected_sample_index = 1
  else
    currentSliceIndex = preferences.WipeSlices.sliceCounter.value
  end

  -- Get the original sample
  local sample = instrument.samples[1]
  local sliceMarkers = sample.slice_markers
  local sampleLength = sample.sample_buffer.number_of_frames

  if #sliceMarkers < 2 then
    renoise.app():show_status("Not enough slice markers.")
    return
  end

  -- Ensure the slice index is within valid range
  if currentSliceIndex > #sliceMarkers then
    currentSliceIndex = 1
  end

  -- Set the slice display with padding
  local thisSlice = sliceMarkers[currentSliceIndex] or 0
  local nextSlice = sliceMarkers[currentSliceIndex + 1] or sampleLength

  local thisSlicePadding = math.max(thisSlice - 1354, 1)
  local nextSlicePadding = math.min(nextSlice + 1354, sampleLength)

  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
  sample.sample_buffer.display_range = {thisSlicePadding, nextSlicePadding}
  sample.sample_buffer.display_length = nextSlicePadding - thisSlicePadding

  -- Debug info
  print(string.format("Slice Info - Current index: %d, Slice Start: %d, Slice End: %d", currentSliceIndex, thisSlicePadding, nextSlicePadding))
  renoise.app():show_status(string.format("Slice Info - Current index: %d, Slice Start: %d, Slice End: %d", currentSliceIndex, thisSlicePadding, nextSlicePadding))

  preferences.sliceCounter.value = currentSliceIndex
end

-- Function to reset the slice counter
function resetSliceCounter()
  preferences.sliceCounter.value = 1
  renoise.app():show_status("Slice counter reset to 1. Will start from the first slice.")
  selectNextSliceInOriginalSample()
end

renoise.tool():add_keybinding{name="Sample Editor:Paketti:Select Padded Slice from Current Slice", invoke=selectPaddedSliceFromCurrentSlice}

-------------
-- Define the loop modes array
local loop_modes = {
  renoise.Sample.LOOP_MODE_OFF,
  renoise.Sample.LOOP_MODE_FORWARD,
  renoise.Sample.LOOP_MODE_REVERSE,
  renoise.Sample.LOOP_MODE_PING_PONG
}

-- Function to cycle loop mode for a single sample
function Global_Paketti_cycle_loop_mode(forwards)
  local sample = renoise.song().selected_sample
  if not sample then 
    renoise.app():show_status("No sample selected.")
    return 
  end
  
  local current_mode = sample.loop_mode
  local current_index
  
  -- Find the current mode index
  for i, mode in ipairs(loop_modes) do
    if mode == current_mode then
      current_index = i
      break
    end
  end
  
  -- Determine the new mode index
  if forwards then
    current_index = current_index % #loop_modes + 1
  else
    current_index = (current_index - 2) % #loop_modes + 1
  end
  
  -- Set the new loop mode
  sample.loop_mode = loop_modes[current_index]
end

-- Function to cycle loop mode for all samples in an instrument
function Global_Paketti_cycle_loop_mode_all_samples(forwards)
  local instrument = renoise.song().selected_instrument
  if not instrument or #instrument.samples == 0 then 
    renoise.app():show_status("No samples in the selected instrument.")
    return 
  end
  
  for _, sample in ipairs(instrument.samples) do
    local current_mode = sample.loop_mode
    local current_index
    
    -- Find the current mode index
    for i, mode in ipairs(loop_modes) do
      if mode == current_mode then
        current_index = i
        break
      end
    end
    
    -- Determine the new mode index
    if forwards then
      current_index = current_index % #loop_modes + 1
    else
      current_index = (current_index - 2) % #loop_modes + 1
    end
    
    -- Set the new loop mode
    sample.loop_mode = loop_modes[current_index]
  end
end

-- Add key binding for cycling loop mode forwards for a single sample
renoise.tool():add_keybinding{name="Global:Paketti:Sample Loop Cycler (Forwards)",
  invoke=function() Global_Paketti_cycle_loop_mode(true) end}

-- Add key binding for cycling loop mode backwards for a single sample
renoise.tool():add_keybinding{name="Global:Paketti:Sample Loop Cycler (Backwards)",
  invoke=function() Global_Paketti_cycle_loop_mode(false) end}

-- Add key binding for cycling loop mode forwards for all samples in an instrument
renoise.tool():add_keybinding{name="Global:Paketti:All Samples Loop Cycler (Forwards)",
  invoke=function() Global_Paketti_cycle_loop_mode_all_samples(true) end}

-- Add key binding for cycling loop mode backwards for all samples in an instrument
renoise.tool():add_keybinding{name="Global:Paketti:All Samples Loop Cycler (Backwards)",
  invoke=function() Global_Paketti_cycle_loop_mode_all_samples(false) end}
-------------
-- Function to reverse the sample buffer
function PakettiReverseSampleBuffer(sample_buffer)
  local num_frames = sample_buffer.number_of_frames
  local num_channels = sample_buffer.number_of_channels

  local temp_buffer = {}
  for frame = 1, num_frames do
    temp_buffer[frame] = {}
    for channel = 1, num_channels do
      temp_buffer[frame][channel] = sample_buffer:sample_data(channel, num_frames - frame + 1)
    end
  end

  for frame = 1, num_frames do
    for channel = 1, num_channels do
      sample_buffer:set_sample_data(channel, frame, temp_buffer[frame][channel])
    end
  end
end

-- Function to copy sample settings
function CopySampleSettings(from_sample, to_sample)
  to_sample.volume = from_sample.volume
  to_sample.panning = from_sample.panning
  to_sample.transpose = from_sample.transpose
  to_sample.fine_tune = from_sample.fine_tune
  to_sample.beat_sync_enabled = from_sample.beat_sync_enabled
  to_sample.beat_sync_lines = from_sample.beat_sync_lines
  to_sample.beat_sync_mode = from_sample.beat_sync_mode
  to_sample.oneshot = from_sample.oneshot
  to_sample.loop_release = from_sample.loop_release

  -- Check if loop points are valid before setting them
  if from_sample.sample_buffer.has_sample_data and from_sample.loop_mode ~= renoise.Sample.LOOP_MODE_OFF then
    to_sample.loop_mode = from_sample.loop_mode
    if from_sample.loop_start > 0 and from_sample.loop_end > from_sample.loop_start then
      to_sample.loop_start = from_sample.loop_start
      to_sample.loop_end = from_sample.loop_end
    end
  else
    to_sample.loop_mode = renoise.Sample.LOOP_MODE_OFF
  end

  to_sample.mute_group = from_sample.mute_group
  to_sample.new_note_action = from_sample.new_note_action
  to_sample.autoseek = from_sample.autoseek
  to_sample.autofade = from_sample.autofade
  to_sample.oversample_enabled = from_sample.oversample_enabled
  to_sample.interpolation_mode = from_sample.interpolation_mode
  to_sample.name = from_sample.name
end

--[[function CopySampleSettings(from_sample, to_sample)
  to_sample.volume = from_sample.volume
  to_sample.panning = from_sample.panning
  to_sample.transpose = from_sample.transpose
  to_sample.fine_tune = from_sample.fine_tune
  to_sample.beat_sync_enabled = from_sample.beat_sync_enabled
  to_sample.beat_sync_lines = from_sample.beat_sync_lines
  to_sample.beat_sync_mode = from_sample.beat_sync_mode
  to_sample.oneshot = from_sample.oneshot
  to_sample.loop_release = from_sample.loop_release
  to_sample.loop_mode = from_sample.loop_mode
  to_sample.loop_start = from_sample.loop_start
  to_sample.loop_end = from_sample.loop_end
  to_sample.mute_group = from_sample.mute_group
  to_sample.new_note_action = from_sample.new_note_action
  to_sample.autoseek = from_sample.autoseek
  to_sample.autofade = from_sample.autofade
  to_sample.oversample_enabled = from_sample.oversample_enabled
  to_sample.interpolation_mode = from_sample.interpolation_mode
  to_sample.name = from_sample.name
end ]]--

-- Function to copy slice settings (excluding loop start and loop end)
function CopySliceSettings(from_sample, to_sample)
  to_sample.volume = from_sample.volume
  to_sample.panning = from_sample.panning
  to_sample.transpose = from_sample.transpose
  to_sample.fine_tune = from_sample.fine_tune
  to_sample.beat_sync_enabled = from_sample.beat_sync_enabled
  to_sample.beat_sync_lines = from_sample.beat_sync_lines
  to_sample.beat_sync_mode = from_sample.beat_sync_mode
  to_sample.oneshot = from_sample.oneshot
  to_sample.loop_release = from_sample.loop_release
  to_sample.loop_mode = from_sample.loop_mode
  to_sample.mute_group = from_sample.mute_group
  to_sample.new_note_action = from_sample.new_note_action
  to_sample.autoseek = from_sample.autoseek
  to_sample.autofade = from_sample.autofade
  to_sample.oversample_enabled = from_sample.oversample_enabled
  to_sample.interpolation_mode = from_sample.interpolation_mode
  to_sample.name = from_sample.name
end

-- Function to duplicate instrument and reverse its samples
function PakettiDuplicateAndReverseInstrument()
  local song = renoise.song()
  local current_index = song.selected_instrument_index
  local current_instrument = song.selected_instrument

  -- Insert a new instrument at the next index
  song:insert_instrument_at(current_index + 1)
  
  -- Select the newly inserted instrument
  song.selected_instrument_index = current_index + 1

  -- Load the default instrument into the new slot
  pakettiPreferencesDefaultInstrumentLoader()

  local new_instrument = song:instrument(current_index + 1)
  local num_samples = #current_instrument.samples

  if num_samples == 1 then
    local sample = current_instrument.samples[1]
    local sample_buffer = sample.sample_buffer
    if #sample.slice_markers == 0 and sample_buffer.has_sample_data then
      local new_sample = new_instrument:insert_sample_at(1)
      new_sample:copy_from(sample)
      new_sample.sample_buffer:prepare_sample_data_changes()
      PakettiReverseSampleBuffer(new_sample.sample_buffer)
      new_sample.sample_buffer:finalize_sample_data_changes()
      CopySampleSettings(sample, new_sample)
    end
  elseif num_samples > 1 then
    local first_sample = current_instrument.samples[1]
    if #first_sample.slice_markers > 0 then
      -- Handle slices by copying the raw sample data and settings of the first sample
      local sample = current_instrument.samples[1]
      local sample_buffer = sample.sample_buffer
      if sample_buffer.has_sample_data then
        local new_sample = new_instrument:insert_sample_at(1)
        
        -- Copy raw sample data
        new_sample.sample_buffer:create_sample_data(sample_buffer.sample_rate, sample_buffer.bit_depth, sample_buffer.number_of_channels, sample_buffer.number_of_frames)
        for channel = 1, sample_buffer.number_of_channels do
          for frame = 1, sample_buffer.number_of_frames do
            new_sample.sample_buffer:set_sample_data(channel, frame, sample_buffer:sample_data(channel, frame))
          end
        end

        new_sample.sample_buffer:prepare_sample_data_changes()
        PakettiReverseSampleBuffer(new_sample.sample_buffer)
        new_sample.sample_buffer:finalize_sample_data_changes()
        new_sample.slice_markers = sample.slice_markers
        CopySampleSettings(sample, new_sample)
        
        -- Copy settings for each slice
        for i, _ in ipairs(sample.slice_markers) do
          CopySliceSettings(current_instrument.samples[i + 1], new_instrument.samples[i + 1])
        end
      end
    else
      -- Handle multiple samples
      for sample_index, sample in ipairs(current_instrument.samples) do
        local sample_buffer = sample.sample_buffer
        if sample_buffer.has_sample_data then
          local new_sample = new_instrument:insert_sample_at(sample_index)
          new_sample:copy_from(sample)
          local new_sample_buffer = new_sample.sample_buffer
          new_sample_buffer:prepare_sample_data_changes()
          PakettiReverseSampleBuffer(new_sample_buffer)
          new_sample_buffer:finalize_sample_data_changes()
          CopySampleSettings(sample, new_sample)
        end
      end
    end
  end

  -- Copy sample names
  for i, sample in ipairs(current_instrument.samples) do
    new_instrument.samples[i].name = sample.name
  end

  song.selected_instrument_index = current_index + 1
  renoise.song().selected_instrument.name = renoise.song().instruments[current_index].name .. " (Reversed)"
end

-- Add keybindings and menu entries to trigger the functions
renoise.tool():add_keybinding{name="Global:Paketti:Duplicate and Reverse Instrument", invoke=PakettiDuplicateAndReverseInstrument}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:Duplicate and Reverse Instrument", invoke=PakettiDuplicateAndReverseInstrument}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Duplicate and Reverse Instrument", invoke=PakettiDuplicateAndReverseInstrument}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Duplicate and Reverse Instrument", invoke=PakettiDuplicateAndReverseInstrument}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Duplicate and Reverse Instrument", invoke=PakettiDuplicateAndReverseInstrument}
renoise.tool():add_midi_mapping{name="Paketti:Duplicate and Reverse Instrument [Trigger]", invoke=function(message) if message:is_trigger() then PakettiDuplicateAndReverseInstrument() end end}

-----
local function pakettiSampleBufferHalfSelector(half)
  local song = renoise.song()
  local instrument = song.selected_instrument
  if not instrument then
    renoise.app():show_status("No instrument selected.")
    return
  end

  local sample = song.selected_sample
  if not sample then
    renoise.app():show_status("No sample selected.")
    return
  end

  local sample_buffer = sample.sample_buffer
  if not sample_buffer.has_sample_data then
    renoise.app():show_status("Sample slot exists but has no content.")
    return
  end

  local sample_length = sample_buffer.number_of_frames
  if sample_length <= 1 then
    renoise.app():show_status("Sample length is too short.")
    return
  end

  local halfway = math.floor(sample_length / 2)
  if half == 1 then
    sample_buffer.selection_start = 1
    sample_buffer.selection_end = halfway
    renoise.app():show_status("First half of sample selected.")
  elseif half == 2 then
    sample_buffer.selection_start = halfway
    sample_buffer.selection_end = sample_length - 1
    renoise.app():show_status("Second half of sample selected.")
  else
    renoise.app():show_status("Invalid half specified.")
  end
end

renoise.tool():add_keybinding{name="Sample Editor:Paketti:Select First Half of Sample Buffer",invoke=function()pakettiSampleBufferHalfSelector(1)end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Select Second Half of Sample Buffer",invoke=function()pakettiSampleBufferHalfSelector(2)end}
-------
function pakettiSaveSampleRange(format)
  local song = renoise.song()
  local original_instrument_index = song.selected_instrument_index
  local selected_sample = song.selected_sample
  if not selected_sample or not selected_sample.sample_buffer.has_sample_data then
    renoise.app():show_status("No valid sample selected")
    return
  end
  
  -- Get the selection range
  local selection_start, selection_end = selected_sample.sample_buffer.selection_range[1], selected_sample.sample_buffer.selection_range[2]
  if selection_start == selection_end then
    renoise.app():show_status("No selection range is defined")
    return
  end

  -- Create a new instrument and sample
  local new_instrument = song:insert_instrument_at(#song.instruments + 1)
  local new_sample = new_instrument:insert_sample_at(1)

  -- Copy selection to the new sample buffer
  local sample_buffer = selected_sample.sample_buffer
  new_sample.sample_buffer:create_sample_data(
    sample_buffer.sample_rate, 
    sample_buffer.bit_depth, 
    sample_buffer.number_of_channels, 
    selection_end - selection_start + 1
  )
  new_sample.sample_buffer:prepare_sample_data_changes()
  
  -- Copy sample data
  for c = 1, sample_buffer.number_of_channels do
    for f = selection_start, selection_end do
      new_sample.sample_buffer:set_sample_data(c, f - selection_start + 1, sample_buffer:sample_data(c, f))
    end
  end
  new_sample.sample_buffer:finalize_sample_data_changes()

  -- Prompt user to save the file
  local filename = renoise.app():prompt_for_filename_to_write(format, "Paketti Save Selected Sample Range in ." .. format .. " Format")
  
  -- Handle cancel operation
  if filename == "" then
    song:delete_instrument_at(#song.instruments)
    song.selected_instrument_index = original_instrument_index
    renoise.app():show_status("Save operation cancelled")
    return
  end
  
  -- Save the sample and clean up
  new_sample.sample_buffer:save_as(filename, format)
  renoise.app():show_status("Saved sample range as ." .. format .. " in " .. filename)
  
  -- Clean up: delete the instrument and reselect original instrument
  song:delete_instrument_at(#song.instruments)
  song.selected_instrument_index = original_instrument_index
end

renoise.tool():add_keybinding{name="Global:Paketti:Paketti Save Selected Sample Range .WAV",invoke=function() pakettiSaveSampleRange("wav") end}
renoise.tool():add_keybinding{name="Global:Paketti:Paketti Save Selected Sample Range .FLAC",invoke=function() pakettiSaveSampleRange("flac") end}
renoise.tool():add_midi_mapping{name="Paketti:Save Selected Sample Range .WAV",invoke=function(message) if message:is_trigger() then pakettiSaveSampleRange("wav") end end}
renoise.tool():add_midi_mapping{name="Paketti:Save Selected Sample Range .FLAC",invoke=function(message) if message:is_trigger() then pakettiSaveSampleRange("flac") end end}


---
function pakettiMinimizeToLoopEnd()
  local song = renoise.song()
  local original_instrument_index = song.selected_instrument_index
  local selected_sample = song.selected_sample
  if not selected_sample or not selected_sample.sample_buffer.has_sample_data then
    renoise.app():show_status("No valid sample selected")
    return
  end

  local loop_end = selected_sample.loop_end
  local sample_buffer = selected_sample.sample_buffer
  
  if loop_end >= sample_buffer.number_of_frames then
    renoise.app():show_status("Nothing to minimize")
    return
  end

  -- Save the range up to loop_end to a temporary file
  local temp_file_path = os.tmpname() .. ".wav"
  local selection_start, selection_end = 1, loop_end

  -- Create a new instrument and sample
  local new_instrument = song:insert_instrument_at(#song.instruments + 1)
  local new_sample = new_instrument:insert_sample_at(1)

  -- Copy selection to the new sample buffer
  new_sample.sample_buffer:create_sample_data(
    sample_buffer.sample_rate, 
    sample_buffer.bit_depth, 
    sample_buffer.number_of_channels, 
    selection_end - selection_start + 1
  )
  new_sample.sample_buffer:prepare_sample_data_changes()

  -- Copy sample data
  for c = 1, sample_buffer.number_of_channels do
    for f = selection_start, selection_end do
      new_sample.sample_buffer:set_sample_data(c, f - selection_start + 1, sample_buffer:sample_data(c, f))
    end
  end
  new_sample.sample_buffer:finalize_sample_data_changes()

  -- Save the truncated sample to the temporary file
  new_sample.sample_buffer:save_as(temp_file_path, "wav")
  
  -- Load the truncated sample back into the original sample slot
  selected_sample.sample_buffer:load_from(temp_file_path)
  
  -- Clean up: delete the temporary instrument and reselect the original instrument
  song:delete_instrument_at(#song.instruments)
  song.selected_instrument_index = original_instrument_index
  
  -- Remove the temporary file
  os.remove(temp_file_path)
  
  renoise.app():show_status("Sample minimized to loop end.")
end

renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:FT2 Minimize Selected Sample",invoke=pakettiMinimizeToLoopEnd}
renoise.tool():add_keybinding{name="Global:Paketti..:FT2 Minimize Selected Sample",invoke=pakettiMinimizeToLoopEnd}
--------
-- Invert Left Channel
function PakettiSampleInvertLeftChannel()
  local song=renoise.song()
  local sample=song.selected_sample
  if not sample or not sample.sample_buffer or sample.sample_buffer.number_of_channels < 2 then
    renoise.app():show_status("No stereo sample available")
    return
  end
  local buffer=sample.sample_buffer
  buffer:prepare_sample_data_changes()
  for f=1,buffer.number_of_frames do
    buffer:set_sample_data(1,f,-buffer:sample_data(1,f))
  end
  buffer:finalize_sample_data_changes()
  renoise.app():show_status("Left channel inverted")
end

-- Invert Right Channel
function PakettiSampleInvertRightChannel()
  local song=renoise.song()
  local sample=song.selected_sample
  if not sample or not sample.sample_buffer or sample.sample_buffer.number_of_channels < 2 then
    renoise.app():show_status("No stereo sample available")
    return
  end
  local buffer=sample.sample_buffer
  buffer:prepare_sample_data_changes()
  for f=1,buffer.number_of_frames do
    buffer:set_sample_data(2,f,-buffer:sample_data(2,f))
  end
  buffer:finalize_sample_data_changes()
  renoise.app():show_status("Right channel inverted")
end

-- Invert Entire Sample
function PakettiSampleInvertEntireSample()
  local song=renoise.song()
  local sample=song.selected_sample
  if not sample or not sample.sample_buffer then
    renoise.app():show_status("No sample available")
    return
  end
  local buffer=sample.sample_buffer
  buffer:prepare_sample_data_changes()
  for ch=1,buffer.number_of_channels do
    for f=1,buffer.number_of_frames do
      buffer:set_sample_data(ch,f,-buffer:sample_data(ch,f))
    end
  end
  buffer:finalize_sample_data_changes()
  renoise.app():show_status("Sample inverted")
end

-- Menu Entries and Keybindings
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Invert Left Channel of Selected Sample",invoke=PakettiSampleInvertLeftChannel}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Invert Right Channel of Selected Sample",invoke=PakettiSampleInvertRightChannel}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Invert Sample",invoke=PakettiSampleInvertEntireSample}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Invert Left Channel of Selected Sample",invoke=PakettiSampleInvertLeftChannel}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Invert Right Channel of Selected Sample",invoke=PakettiSampleInvertRightChannel}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Invert Sample",invoke=PakettiSampleInvertEntireSample}
-------
----
local previous_value = nil
local rotation_amount = 5  -- You can set this to any desired default value

-- Function to rotate sample buffer content based on knob movement
function rotate_sample_buffer(midi_message, rotation_amount)
if renoise.song().selected_sample.sample_buffer.number_of_frames > 64000 then
renoise.app():show_status("This sample is far too large to be rotated, would cause a significant performance hit and crash Renoise - aborted")
return
end

  local song = renoise.song()
  local sample = song.selected_sample
  local buffer = sample.sample_buffer

  if buffer.has_sample_data then
    local value = midi_message.int_value
    local change = 0
    if previous_value then
      change = value - previous_value
    end
    previous_value = value

    -- No change detected, return
    if change == 0 then
      return
    end

    -- Determine the direction of rotation
    local direction = 0
    if change > 0 then
      direction = 1  -- Rotate forward
    elseif change < 0 then
      direction = -1 -- Rotate backward
    end

    -- Rotate the sample buffer
    buffer:prepare_sample_data_changes()
    local frames = buffer.number_of_frames
    for c = 1, buffer.number_of_channels do
      local temp_data = {}
      for i = 1, frames do
        temp_data[i] = buffer:sample_data(c, i)
      end
      for i = 1, frames do
        local new_pos = (i + direction * rotation_amount - 1 + frames) % frames + 1
        buffer:set_sample_data(c, new_pos, temp_data[i])
      end
    end
    buffer:finalize_sample_data_changes()

    local status_direction = direction > 0 and "forward" or "backward"
    renoise.app():show_status("Sample buffer rotated " .. status_direction .. " by " .. rotation_amount .. " frames.")
  else
    renoise.app():show_status("No sample data to rotate.")
  end
end

-- Add MIDI mapping for rotating the sample buffer
renoise.tool():add_midi_mapping{
  name = "Paketti:Rotate Sample Buffer Left/Right Fine x[Knob]",
  invoke = function(midi_message)
    rotate_sample_buffer(midi_message, rotation_amount)
  end
}



local coarse_rotation_amount = 1000  -- Set Coarse rotation amount to 1000
local previous_value_coarse = nil

-- Function to rotate sample buffer content based on coarse knob movement
function rotate_sample_buffer_coarse(midi_message, rotation_amount)

if renoise.song().selected_sample.sample_buffer.number_of_frames > 64000 then
renoise.app():show_status("This sample is far too large to be rotated, would cause a significant performance hit and crash Renoise - aborted")
return
end
  local song = renoise.song()
  local sample = song.selected_sample
  local buffer = sample.sample_buffer

  if buffer.has_sample_data then
    local value = midi_message.int_value
    local change = 0
    if previous_value_coarse then
      change = value - previous_value_coarse
    end
    previous_value_coarse = value

    -- No change detected, return
    if change == 0 then
      return
    end

    -- Determine the direction of rotation
    local direction = 0
    if change > 0 then
      direction = 1  -- Rotate forward
    elseif change < 0 then
      direction = -1 -- Rotate backward
    end

    -- Rotate the sample buffer
    buffer:prepare_sample_data_changes()
    local frames = buffer.number_of_frames
    for c = 1, buffer.number_of_channels do
      local temp_data = {}
      for i = 1, frames do
        temp_data[i] = buffer:sample_data(c, i)
      end
      for i = 1, frames do
        local new_pos = (i + direction * rotation_amount - 1 + frames) % frames + 1
        buffer:set_sample_data(c, new_pos, temp_data[i])
      end
    end
    buffer:finalize_sample_data_changes()

    local status_direction = direction > 0 and "forward" or "backward"
    renoise.app():show_status("Sample buffer rotated " .. status_direction .. " by " .. rotation_amount .. " frames.")
  else
    renoise.app():show_status("No sample data to rotate.")
  end
end

-- Add MIDI mapping for coarse rotation
renoise.tool():add_midi_mapping{
  name = "Paketti:Rotate Sample Buffer Left/Right Coarse x[Knob]",
  invoke = function(midi_message)
    rotate_sample_buffer_coarse(midi_message, coarse_rotation_amount)
  end
}


-- Function to rotate sample buffer content forward or backward by a specified amount
function rotate_sample_buffer_fixed(rotation_amount)
if renoise.song().selected_sample.sample_buffer.number_of_frames > 64000 then
renoise.app():show_status("This sample is far too large to be rotated, would cause a significant performance hit and crash Renoise - aborted")
return
end

  local song = renoise.song()
  local sample = song.selected_sample
  local buffer = sample.sample_buffer

  if buffer.has_sample_data then
    buffer:prepare_sample_data_changes()
    local frames = buffer.number_of_frames
    for c = 1, buffer.number_of_channels do
      local temp_data = {}
      for i = 1, frames do
        temp_data[i] = buffer:sample_data(c, i)
      end
      for i = 1, frames do
        local new_pos = (i + rotation_amount - 1 + frames) % frames + 1
        buffer:set_sample_data(c, new_pos, temp_data[i])
      end
    end
    buffer:finalize_sample_data_changes()

    local status_direction = rotation_amount > 0 and "forward" or "backward"
    renoise.app():show_status("Sample buffer rotated " .. status_direction .. " by " .. math.abs(rotation_amount) .. " frames.")
  else
    renoise.app():show_status("No sample data to rotate.")
  end
end

-- Add keybindings for rotating the sample buffer by fixed amounts
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Rotate Sample Buffer Right 10", invoke=function() rotate_sample_buffer_fixed(10) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Rotate Sample Buffer Left 10", invoke=function() rotate_sample_buffer_fixed(-10) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Rotate Sample Buffer Right 100", invoke=function() rotate_sample_buffer_fixed(100) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Rotate Sample Buffer Left 100", invoke=function() rotate_sample_buffer_fixed(-100) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Rotate Sample Buffer Right 1000", invoke=function() rotate_sample_buffer_fixed(1000) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Rotate Sample Buffer Left 1000", invoke=function() rotate_sample_buffer_fixed(-1000) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Rotate Sample Buffer Right 10000", invoke=function() rotate_sample_buffer_fixed(10000) end}
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Rotate Sample Buffer Left 10000", invoke=function() rotate_sample_buffer_fixed(-10000) end}


---------
function filterTypeRandom()

if renoise.song().selected_instrument ~= nil then
if renoise.song().selected_sample ~= nil then
if renoise.song().selected_instrument.sample_modulation_sets ~= nil then
local randomized=math.random(2, 22)
renoise.song().instruments[renoise.song().selected_instrument_index].sample_modulation_sets[1].filter_type=renoise.song().instruments[renoise.song().selected_instrument_index].sample_modulation_sets[1].available_filter_types[randomized]
end end
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Randomize Selected Instrument Modulation Filter Type", invoke=function()
filterTypeRandom() end}
--------------
-- Define render state (initialized when starting to render)
render_context = {
    source_track = 0,
    target_track = 0,
    target_instrument = 0,
    temp_file_path = ""
}

-- Function to initiate rendering
function CleanRenderAndSaveStart(format)
    local render_priority = "high"
    local selected_track = renoise.song().selected_track

    for _, device in ipairs(selected_track.devices) do
        if device.name == "#Line Input" then
            render_priority = "realtime"
            break
        end
    end

    -- Set up rendering options
    local render_options = {
        sample_rate = preferences.renderSampleRate.value,
        bit_depth = preferences.renderBitDepth.value,
        interpolation = "precise",
        priority = render_priority,
        start_pos = renoise.SongPos(renoise.song().selected_sequence_index, 1),
        end_pos = renoise.SongPos(renoise.song().selected_sequence_index, renoise.song().patterns[renoise.song().selected_pattern_index].number_of_lines),
    }

    -- Set render context
    render_context.source_track = renoise.song().selected_track_index
    render_context.target_track = render_context.source_track + 1
    render_context.target_instrument = renoise.song().selected_instrument_index + 1
    render_context.temp_file_path = os.tmpname() .. ".wav"

    -- Start rendering with the correct function call
    local success, error_message = renoise.song():render(render_options, render_context.temp_file_path, CleanRenderAndSaveDoneCallback)
    if not success then
        print("Rendering failed: " .. error_message)
    else
        -- Start a timer to monitor rendering progress
        renoise.tool():add_timer(CleanRenderAndSaveMonitor, 500)
    end
end

-- Callback function that gets called when rendering is complete
function CleanRenderAndSaveDoneCallback()
    local song = renoise.song()
    local sourceTrackName = song.tracks[render_context.source_track].name

    -- Remove the monitoring timer
    renoise.tool():remove_timer(CleanRenderAndSaveMonitor)

    -- Un-solo the source track
    song.tracks[render_context.source_track].solo_state = false

    -- Create a new instrument below the currently selected instrument
    local renderedInstrument = song.selected_instrument_index + 1
    song:insert_instrument_at(renderedInstrument)

    -- Select the newly created instrument
    song.selected_instrument_index = renderedInstrument

    -- Ensure the new instrument has at least one sample slot
    local new_instrument = song:instrument(renderedInstrument)
    if #new_instrument.samples == 0 then
        new_instrument:insert_sample_at(1)
    end

    -- Load the rendered sample into the first Sample Buffer
    new_instrument.samples[1].sample_buffer:load_from(render_context.temp_file_path)

    -- Clean up the temporary file
    os.remove(render_context.temp_file_path)

    -- Ensure the correct sample is selected
    song.selected_sample_index = 1

    -- Name the new instrument and the sample inside it
    new_instrument.name = sourceTrackName .. " (Rendered)"
    new_instrument.samples[1].name = sourceTrackName .. " (Rendered)"

    -- Save the rendered sample using the specified format
    CleanRenderAndSaveSample(render_context.temp_file_path:match("%.%w+$"):sub(2)) -- Extract format from file extension
end



-- Function to monitor rendering progress
function CleanRenderAndSaveMonitor()
    if renoise.song().rendering then
        local progress = renoise.song().rendering_progress
        print("Rendering in progress: " .. (progress * 100) .. "% complete")
    else
        -- Remove the monitoring timer once rendering is complete or if it wasn't started
        renoise.tool():remove_timer(CleanRenderAndSaveMonitor)
        print("Rendering not in progress or already completed.")
    end
end

-- Function to handle rendering for a group track
function CleanRenderAndSaveGroupTrack(format)
    local song = renoise.song()
    local group_track_index = song.selected_track_index
    local group_track = song:track(group_track_index)
    local start_track_index = group_track_index + 1
    local end_track_index = start_track_index + group_track.visible_note_columns - 1

    for i = start_track_index, end_track_index do
        song:track(i):solo()
    end

    -- Set rendering options and start rendering
    CleanRenderAndSaveStart(format)
end

-- Function to clean render and save the selection
function CleanRenderAndSaveSelection(format)
    local song = renoise.song()
    local renderTrack = song.selected_track_index

    -- Check if the selected track is a group track
    if song:track(renderTrack).type == renoise.Track.TRACK_TYPE_GROUP then
        -- Render the group track
        CleanRenderAndSaveGroupTrack(format)
    else
        -- Solo Selected Track
        song.tracks[renderTrack]:solo()

        -- Render Selected Track
        CleanRenderAndSaveStart(format)
    end
end

-- Function to save the rendered sample in the specified format
function CleanRenderAndSaveSample(format)
    if renoise.song().selected_sample == nil then return end

    local filename = renoise.app():prompt_for_filename_to_write(format, "CleanRenderAndSave: Save Selected Sample in ." .. format .. " Format")
    if filename == "" then return end

    renoise.song().selected_sample.sample_buffer:save_as(filename, format)
    renoise.app():show_status("Saved sample as " .. format .. " in " .. filename)
end

-- Menu entries and keybindings
renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Clean Render and Save Selected Track/Group as .WAV", invoke=function() CleanRenderAndSaveSelection("WAV") end}
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Clean Render and Save Selected Track/Group as .FLAC", invoke=function() CleanRenderAndSaveSelection("FLAC") end}
renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Clean Render and Save Selected Track/Group as .WAV", invoke=function() CleanRenderAndSaveSelection("WAV") end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Clean Render and Save Selected Track/Group as .FLAC", invoke=function() CleanRenderAndSaveSelection("FLAC") end}
renoise.tool():add_keybinding{name="Global:Paketti:Clean Render&Save Selected Track/Group (.WAV)", invoke=function() CleanRenderAndSaveSelection("WAV") end}
renoise.tool():add_keybinding{name="Global:Paketti:Clean Render&Save Selected Track/Group (.FLAC)", invoke=function() CleanRenderAndSaveSelection("FLAC") end}
---------
function PakettiInjectDefaultXRNI()
  local song = renoise.song()
  local selected_instrument_index = song.selected_instrument_index
  local original_instrument = song.selected_instrument

  -- Debug: Log initial status
  print("Starting PakettiInjectDefaultXRNI...")
  print("Selected Instrument Index: " .. selected_instrument_index)
  print("Original Instrument Name: " .. (original_instrument and original_instrument.name or "None"))

  if not original_instrument or #original_instrument.samples == 0 then
    renoise.app():show_status("No instrument or samples selected.")
    print("No instrument or no samples found. Exiting.")
    return
  end

  -- Insert a new instrument below the current one
  local new_instrument_index = selected_instrument_index + 1
  song:insert_instrument_at(new_instrument_index)
  song.selected_instrument_index = new_instrument_index
  local new_instrument = song.selected_instrument

  -- Load the default XRNI into the new instrument slot
  pakettiPreferencesDefaultInstrumentLoader()

  -- Re-assign new_instrument after loading XRNI
  new_instrument = renoise.song().selected_instrument

  -- Copy the samples and their settings from the original instrument to the new instrument
  for i = 1, #original_instrument.samples do
    local from_sample = original_instrument.samples[i]
    print("Copying sample #" .. i .. " from instrument index " .. selected_instrument_index .. " with name: " .. from_sample.name)
    
    -- Check if the sample has slice markers
    if #from_sample.slice_markers > 0 then
      print("Sample #" .. i .. " is a sliced sample. Copying slices.")
      
      -- Copy only raw sample data
      local to_sample = new_instrument:sample(i)
      local from_buffer = from_sample.sample_buffer
      local to_sample_buffer = to_sample.sample_buffer
      
      to_sample_buffer:create_sample_data(
        from_buffer.sample_rate,
        from_buffer.bit_depth,
        from_buffer.number_of_channels,
        from_buffer.number_of_frames
      )
      
      to_sample_buffer:prepare_sample_data_changes()

      for channel = 1, from_buffer.number_of_channels do
        for frame = 1, from_buffer.number_of_frames do
          local sample_value = from_buffer:sample_data(channel, frame)
          to_sample_buffer:set_sample_data(channel, frame, sample_value)
        end
      end

      to_sample_buffer:finalize_sample_data_changes()

      -- Copy slice markers
      to_sample:clear_slice_markers()
      for _, slice_marker in ipairs(from_sample.slice_markers) do
        to_sample:insert_slice_marker(slice_marker)
      end

      print("Slices copied for sample #" .. i)
    else
      -- Copy sample properties for non-sliced samples
      new_instrument:insert_sample_at(i)
      local to_sample = new_instrument.samples[i]
      to_sample:copy_from(from_sample)
      print("Sample properties copied from sample #" .. i .. " of instrument index " .. selected_instrument_index)
    end
  end

  -- Rename the new instrument
  new_instrument.name = original_instrument.name .. " (Pakettified)"
  print("New Instrument renamed to: " .. new_instrument.name)

  -- Apply modulation and filter settings if needed
  if preferences.pakettiPitchbendLoaderEnvelope.value then
    new_instrument.sample_modulation_sets[1].devices[2].is_active = true
    print("Pitchbend Loader Envelope activated.")
  end

  if preferences.pakettiLoaderFilterType.value then
    new_instrument.sample_modulation_sets[1].filter_type = preferences.pakettiLoaderFilterType.value
    print("Loader Filter Type set to preference.")
  end

  -- Return focus to the Instrument Sample Editor
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
  print("Focus returned to Instrument Sample Editor.")
  print("PakettiInjectDefaultXRNI completed successfully.")
  new_instrument.sample_modulation_sets[1].name = "Pitchbend"

end

-- Add keybinding and menu entry to invoke the PakettiInjectDefaultXRNI function
renoise.tool():add_keybinding{name="Global:Paketti:Pakettify Current Instrument", invoke=function() PakettiInjectDefaultXRNI() end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Pakettify Current Instrument", invoke=function() PakettiInjectDefaultXRNI() end}

local isPitchStepSomewhere

function PakettiShowPitchStepper()
if renoise.song().selected_instrument.samples[1] ~= nil then
  if renoise.song().selected_instrument.sample_modulation_sets[1].devices[1] ~= nil and renoise.song().selected_instrument.sample_modulation_sets[1].devices[1].name == "Pitch Stepper"
  then 
    if renoise.song().selected_instrument.sample_modulation_sets[1].devices[1].external_editor_visible==true
    then renoise.song().selected_instrument.sample_modulation_sets[1].devices[1].external_editor_visible=false
    else renoise.song().selected_instrument.sample_modulation_sets[1].devices[1].external_editor_visible=true
    isPitchStepSomewhere = renoise.song().selected_track_index
    end
  else
  renoise.app():show_status("This Instrument is not a Paketti PitchBend Loaded Instrument, doing nothing.")
  return
  end
else
renoise.app():show_status("No valid Instrument/Sample selected, doing nothing.")
--renoise.song().instruments[isPitchStepSomewhere].sample_modulation_sets[1].devices[1].external_editor_visible=false
 return
end  

end
renoise.tool():add_keybinding{name="Global:Paketti:Show/Hide PitchStep on Selected Instrument",invoke=function() PakettiShowPitchStepper() end}

-------------------
function BeatSyncFromSelection()
  local song=renoise.song()

  if song.selection_in_pattern then
    local startLine=song.selection_in_pattern.start_line
    local endLine=song.selection_in_pattern.end_line

    -- Calculate how long the selection is
    local selectionLength=math.abs(endLine-startLine)+1

    -- Set beat sync lines based on the selection length
    song.selected_sample.beat_sync_lines=selectionLength
    song.selected_sample.beat_sync_enabled=true

    -- Provide feedback in the status bar
    renoise.app():show_status("Beat sync lines set to: "..selectionLength)
  else
    renoise.app():show_status("No pattern selection available.")
  end
end


renoise.tool():add_keybinding{name="Global:Paketti:Smart BeatSync from Selection",invoke=function()
BeatSyncFromSelection() end}

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
        command = 'exec "' .. app_path .. '" "' .. temp_file_path .. '"'
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
        spacing=10,
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

    renoise.tool():add_midi_mapping{
        name="Global:Paketti:Send Selected Sample to AppSelection" .. i,
        invoke=function(message)
            if message:is_trigger() then
                saveSelectedSampleToTempAndOpen(preferences.AppSelection["AppSelection"..i].value)
            end
        end
    }
end

for i=1, 3 do
    renoise.tool():add_keybinding{name="Global:Paketti:Save Sample to Smart/Backup Folder " .. i, invoke=function() saveSampleToSmartFolder(i) end }
    renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Save Sample to Smart/Backup Folder " .. i, invoke=function() saveSampleToSmartFolder(i) end }
    renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Save Sample to Smart/Backup Folder " .. i, invoke=function() saveSampleToSmartFolder(i) end }
    renoise.tool():add_midi_mapping{name="Global:Paketti:Save Sample to Smart/Backup Folder " .. i, invoke=function(message)
            if message:is_trigger() then saveSampleToSmartFolder(i) end end}
end

for i=1, 3 do
    renoise.tool():add_keybinding{name="Global:Paketti:Save All Samples to Smart/Backup Folder " .. i, invoke=function() saveSamplesToSmartFolder(i) end}
    renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Save All Samples to Smart/Backup Folder " .. i, invoke=function() saveSamplesToSmartFolder(i) end }
    renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Save All Samples to Smart/Backup Folder " .. i, invoke=function() saveSamplesToSmartFolder(i) end }
    renoise.tool():add_midi_mapping{ name="Global:Paketti:Save All Samples to Smart/Backup Folder " .. i, invoke=function(message)
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
  renoise.app():load_instrument("Presets/12st_Pitchbend_Drumkit_C0.xrni")

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
  sample.oversample_enabled=true
  sample.autofade = true
  sample.loop_mode = preferences.pakettiLoaderLoopMode.value
  sample.new_note_action = 1
  
  
  -- Iterate over the rest of the selected files and insert them sequentially
  for i = 2, num_samples_to_load do
    selected_sample_filename = selected_sample_filenames[i]

  sample.interpolation_mode=preferences.pakettiLoaderInterpolation.value
  sample.oversample_enabled=true
  sample.autofade = true
  sample.loop_mode = preferences.pakettiLoaderLoopMode.value
  sample.new_note_action = 1


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


-- Function to create a new instrument from the selected sample buffer range
function create_new_instrument_from_selection()
  local song = renoise.song()
  local selected_sample = song.selected_sample
  local selected_instrument_index = song.selected_instrument_index
  local selected_instrument = song.selected_instrument

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
    renoise.song().instruments[renoise.song().selected_instrument_index].samples[1].interpolation_mode = preferences.pakettiLoaderInterpolation.value
    renoise.song().instruments[renoise.song().selected_instrument_index].samples[1].oversample_enabled = preferences.pakettiLoaderOverSampling.value
    renoise.song().instruments[renoise.song().selected_instrument_index].samples[1].autofade = preferences.pakettiLoaderAutoFade.value
    print("Selected the new instrument and sample.")
  else
    song.selected_instrument_index = selected_instrument_index
    print("Stayed in the current sample editor view of the instrument you chopped out of.")
  end

  renoise.app():show_status("New instrument created from selection with " .. loop_mode_message .. ".")
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
function pitchBendMultipleSampleLoader()
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
        current_sample.oversample_enabled = true
        current_sample.autofade = true
        current_sample.loop_mode = preferences.pakettiLoaderLoopMode.value
        current_sample.new_note_action = 1

        renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR

        G01()

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
renoise.tool():add_midi_mapping{name="Global:Paketti:Midi PakettiPitchBend Multiple Sample Loader", invoke=function(message)
  if message.int_value > 1 then pitchBendMultipleSampleLoader() end end}


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
    
    -- Lookup table for beatsync lines based on the value of changer
    local beatsync_lines = {
        [2] = 64,
        [4] = 32,
        [8] = 16,
        [16] = 8,
        [32] = 4,
        [64] = 2,
        [128] = 1
    }

    -- Determine the appropriate beatsync lines from the table or use a default value
    local beatsynclines = beatsync_lines[changer] or 64
    local currentTranspose = s.selected_sample.transpose

    -- Assuming that preferences are defined somewhere globally accessible in your script
local prefs = {
    loop_mode = preferences.WipeSlices.WipeSlicesLoopMode,
    loop_release = preferences.WipeSlices.WipeSlicesLoopRelease,  -- Use the correct preference key
    new_note_action = preferences.WipeSlices.WipeSlicesNNA,
    oneshot = preferences.WipeSlices.WipeSlicesOneShot,
    autofade = true,
    autoseek = preferences.WipeSlices.WipeSlicesAutoseek,
    transpose = currentTranspose,
    mute_group = preferences.WipeSlices.WipeSlicesMuteGroup,
    interpolation_mode = 4,  -- High Quality Interpolation
    beat_sync_mode = preferences.WipeSlices.WipeSlicesBeatSyncMode,
    oversample_enabled = true
}


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
for i, sample in ipairs(s.instruments[currInst].samples) do
    sample.new_note_action = preferences.WipeSlices.WipeSlicesNNA.value
    sample.oneshot = prefs.oneshot.value
    sample.autofade = prefs.autofade
    sample.autoseek = prefs.autoseek.value
    sample.transpose = prefs.transpose
    sample.mute_group = prefs.mute_group.value
    sample.interpolation_mode = prefs.interpolation_mode
    sample.beat_sync_mode = prefs.beat_sync_mode.value
    sample.oversample_enabled = prefs.oversample_enabled
    sample.loop_mode = prefs.loop_mode.value
    sample.beat_sync_enabled = true
    sample.beat_sync_lines = beatsynclines
    sample.loop_release = preferences.WipeSlices.WipeSlicesLoopRelease.value
end

    -- Ensure beat sync is enabled for the original sample
    s.instruments[currInst].samples[1].beat_sync_lines = 128
    s.instruments[currInst].samples[1].beat_sync_enabled = true
    
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



renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (2)",invoke=function() slicerough(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (4)",invoke=function() slicerough(4) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (8)",invoke=function() slicerough(8) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (16)",invoke=function() slicerough(16) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (32)",invoke=function() slicerough(32) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (64)",invoke=function() slicerough(64) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (128)",invoke=function() slicerough(128) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe Slices",invoke=function() wipeslices() end}

renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Wipe Slices",invoke=function() wipeslices() end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (2)",invoke=function() slicerough(2) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (4)",invoke=function() slicerough(4) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (8)",invoke=function() slicerough(8) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (16)",invoke=function() slicerough(16) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (32)",invoke=function() slicerough(32) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (64)",invoke=function() slicerough(64) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (128)",invoke=function() slicerough(128) end}

renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe Slices",invoke=function() wipeslices() end}
renoise.tool():add_menu_entry{name="--Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Create Slices (2)",invoke=function() slicerough(2) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Create Slices (4)",invoke=function() slicerough(4) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Create Slices (8)",invoke=function() slicerough(8) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Create Slices (16)",invoke=function() slicerough(16) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Create Slices (32)",invoke=function() slicerough(32) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Create Slices (64)",invoke=function() slicerough(64) end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Wipe&Slice..:Wipe&Create Slices (128)",invoke=function() slicerough(128) end}


renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe Slices",invoke=function() wipeslices() end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Wipe&Slice..:Wipe&Create Slices (2)",invoke=function() slicerough(2) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Create Slices (4)",invoke=function() slicerough(4) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Create Slices (8)",invoke=function() slicerough(8) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Create Slices (16)",invoke=function() slicerough(16) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Create Slices (32)",invoke=function() slicerough(32) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Create Slices (64)",invoke=function() slicerough(64) end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Wipe&Slice..:Wipe&Create Slices (128)",invoke=function() slicerough(128) end}







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
end 
end
end
renoise.tool():add_keybinding{name="Global:Paketti:Paketti Save Selected Sample .WAV",invoke=function() pakettiSaveSample("wav") end}
renoise.tool():add_keybinding{name="Global:Paketti:Paketti Save Selected Sample .FLAC",invoke=function() pakettiSaveSample("flac") end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Paketti Save Selected Sample .WAV",invoke=function() pakettiSaveSample("wav") end}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Paketti Save Selected Sample .FLAC",invoke=function() pakettiSaveSample("flac") end}
renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Paketti Save Selected Sample .WAV",invoke=function() pakettiSaveSample("wav") end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Paketti Save Selected Sample .FLAC",invoke=function() pakettiSaveSample("flac") end}
renoise.tool():add_menu_entry{name="--Sample Navigator:Paketti..:Paketti Save Selected Sample .WAV",invoke=function() pakettiSaveSample("wav") end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Paketti Save Selected Sample .FLAC",invoke=function() pakettiSaveSample("flac") end}



renoise.tool():add_midi_mapping{name="Global:Paketti:Midi Paketti Save Selected Sample .WAV", invoke=function(message)
  if message.int_value > 1 then pakettiSaveSample("wav") end end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Midi Paketti Save Selected Sample .FLAC", invoke=function(message)
  if message.int_value > 1 then pakettiSaveSample("flac") end end}





------------
-- Define a global variable to store the temporary filename
tmpvariable = nil

-- Function to wipe the song while retaining the current sample
function WipeRetain()
  -- Get the current song
  local s = renoise.song()

  -- Check if the selected instrument has samples and a sample buffer
  if s.selected_instrument and #s.selected_instrument.samples > 0 then
    local sample = s.selected_instrument.samples[1]
    if sample.sample_buffer.has_sample_data then
      -- Create a temporary filename
      tmpvariable = os.tmpname() .. ".wav"  -- Ensure the file has a .wav extension

      -- Save the selected sample buffer to the temporary file
      sample.sample_buffer:save_as(tmpvariable, "wav")

      -- Check if the notifier is already added, if not, add it
      if not renoise.tool().app_new_document_observable:has_notifier(WipeRetainFinish) then
        renoise.tool().app_new_document_observable:add_notifier(WipeRetainFinish)
      end

      -- Create a new song
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
  -- Get the current song
  local s = renoise.song()

  -- Ensure there is at least one instrument and one sample slot
  local instrument = s:insert_instrument_at(1)
  local sample = instrument:insert_sample_at(1)

  -- Load the sample buffer from the temporary file
  sample.sample_buffer:load_from(tmpvariable)

  -- Set the active middle frame to the instrument sample editor
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR

  -- Show the status message
  renoise.app():show_status("Sample retained from temporary file: " .. tmpvariable)

  -- Remove the temporary file
  os.remove(tmpvariable)

  -- Remove the notifier
  renoise.tool().app_new_document_observable:remove_notifier(WipeRetainFinish)
end

-- Add a keybinding to invoke the WipeRetain function
renoise.tool():add_keybinding{name="Global:Paketti:Wipe Song Retain Sample", invoke=function() WipeRetain() end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Wipe Song Retain Sample", invoke=function() WipeRetain() end}

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

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Clean Render Selected Track or Group", invoke = function() pakettiCleanRenderSelection() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Clean Render Selected Track or Group", invoke = function() pakettiCleanRenderSelection() end}
renoise.tool():add_menu_entry{name="Mixer:Paketti..:Clean Render Selected Track or Group", invoke = function() pakettiCleanRenderSelection() end}
renoise.tool():add_menu_entry{name="--Instrument Box:Paketti..:Clean Render Selected Track or Group", invoke = function() pakettiCleanRenderSelection() end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:Clean Render Selected Track or Group", invoke = function() pakettiCleanRenderSelection() end}
renoise.tool():add_keybinding{name="Mixer:Paketti..:Clean Render Selected Track or Group", invoke = function() pakettiCleanRenderSelection() end}

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
    renoise.tool():add_midi_mapping{
        name = "Global:Paketti:Midi Change Slice 0" .. i,
        invoke = function(message)
            if message:is_abs_value() then
                adjustSlice(i, message.int_value)
            end
        end
    }
end

for i = 10, 32 do
    renoise.tool():add_midi_mapping{
        name = "Global:Paketti:Midi Change Slice " .. i,
        invoke = function(message)
            if message:is_abs_value() then
                adjustSlice(i, message.int_value)
            end
        end
    }
end

renoise.tool():add_midi_mapping{name="Global:Paketti:Midi Select Padded Slice (Next)",invoke=function(message)
  if message.int_value == 127 then selectNextSliceInOriginalSample() end end}

renoise.tool():add_midi_mapping{name="Global:Paketti:Midi Select Padded Slice (Previous)",invoke=function(message)
  if message.int_value == 127 then selectPreviousSliceInOriginalSample() end end}


-------------
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


function PakettiReverseSampleBuffer(sample_buffer)
  local num_frames = sample_buffer.number_of_frames
  local num_channels = sample_buffer.number_of_channels

  -- Create a temporary buffer to store reversed data
  local temp_buffer = {}
  for frame = 1, num_frames do
    temp_buffer[frame] = {}
    for channel = 1, num_channels do
      temp_buffer[frame][channel] = sample_buffer:sample_data(channel, num_frames - frame + 1)
    end
  end

  -- Copy the reversed data back to the original sample buffer
  for frame = 1, num_frames do
    for channel = 1, num_channels do
      sample_buffer:set_sample_data(channel, frame, temp_buffer[frame][channel])
    end
  end
end

-- Main function to duplicate instrument and reverse its sample
function PakettiDuplicateAndReverseInstrument()
  local song = renoise.song()
  local current_index = song.selected_instrument_index
  local current_instrument = song.selected_instrument
  local new_instrument = song:insert_instrument_at(current_index + 1)

  -- Copy all properties from the current instrument to the new one
  new_instrument:copy_from(current_instrument)

  -- Iterate through each sample in the new instrument and reverse its sample buffer
  for _, sample in ipairs(new_instrument.samples) do
    local sample_buffer = sample.sample_buffer
    if sample_buffer.has_sample_data then
      sample_buffer:prepare_sample_data_changes()
      PakettiReverseSampleBuffer(sample_buffer)
      sample_buffer:finalize_sample_data_changes()
    end
  end

  -- Select the new instrument
  song.selected_instrument_index = current_index + 1
  renoise.song().selected_instrument.name = renoise.song().instruments[current_index].name .. " (Reversed)"
end

-- Add a keybinding to trigger the function
renoise.tool():add_keybinding{name="Global:Paketti:Duplicate and Reverse Instrument",invoke=PakettiDuplicateAndReverseInstrument}

-- Add a menu entry to trigger the function
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:Duplicate and Reverse Instrument",invoke=PakettiDuplicateAndReverseInstrument}

-- Add a MIDI mapping to trigger the function
renoise.tool():add_midi_mapping{name="Tools:Paketti:Duplicate and Reverse Instrument [Trigger]",invoke=PakettiDuplicateAndReverseInstrument}


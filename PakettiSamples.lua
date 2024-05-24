-- Function to load a pitchbend instrument
function pitchedInstrument(st)
  renoise.app():load_instrument("Presets/" .. st .. "st_Pitchbend.xrni")
  local selected_instrument = renoise.song().selected_instrument
  selected_instrument.name = st .. "st_Pitchbend Instrument"
  selected_instrument.macros_visible = true
  selected_instrument.sample_modulation_sets[1].name = st .. "st_Pitchbend"
end

-- Function to create a new instrument from the selected sample buffer range
function create_new_instrument_from_selection()
  local song = renoise.song()
  local selected_sample = song.selected_sample
  local selected_instrument_index = song.selected_instrument_index
  local selected_instrument = song.selected_instrument

  -- Check if there's a valid sample buffer
  if not selected_sample.sample_buffer.has_sample_data then
    renoise.app():show_error("No sample buffer data found in the selected sample.")
    return
  end

  local sample_buffer = selected_sample.sample_buffer

  -- Check if there's a valid selection range
  if sample_buffer.selection_range == nil or #sample_buffer.selection_range < 2 then
    renoise.app():show_error("No valid selection range found.")
    return
  end

  local selection_start = sample_buffer.selection_range[1]
  local selection_end = sample_buffer.selection_range[2]
  local selection_length = selection_end - selection_start

  -- Retrieve properties of the selected sample
  local bit_depth = sample_buffer.bit_depth
  local sample_rate = sample_buffer.sample_rate
  local num_channels = sample_buffer.number_of_channels

  -- Insert a new instrument right below the current instrument
  local new_instrument_index = selected_instrument_index + 1
  song:insert_instrument_at(new_instrument_index)
  song.selected_instrument_index = new_instrument_index

  -- Load the pitchbend instrument into the new instrument slot
  pitchedInstrument("12")

  -- Get the newly loaded instrument
  local new_instrument = song:instrument(new_instrument_index)
  local new_sample = new_instrument:insert_sample_at(1)
  
  -- Create sample data and prepare to make changes
  new_sample.sample_buffer:create_sample_data(sample_rate, bit_depth, num_channels, selection_length)
  local new_sample_buffer = new_sample.sample_buffer
  new_sample_buffer:prepare_sample_data_changes()

  -- Copy the selection range to the new sample buffer
  for channel = 1, num_channels do
    for i = 1, selection_length do
      new_sample_buffer:set_sample_data(channel, i, sample_buffer:sample_data(channel, selection_start + i - 1))
    end
  end

  -- Finalize sample data changes
  new_sample_buffer:finalize_sample_data_changes()

  -- Set the loop mode to "Forward" (value 2)
  new_sample.loop_mode = renoise.Sample.LOOP_MODE_FORWARD

  -- Set the names for the new instrument and sample
  new_instrument.name = selected_instrument.name .. " (Cut&Loop)"
  new_sample.name = selected_sample.name .. " (Cut&Loop)"

  -- Select the new instrument and sample
  song.selected_instrument_index = new_instrument_index
  song.selected_sample_index = 1

  renoise.app():show_status("New instrument created from selection with loop mode set to 'Forward'.")
end

-- Add keybinding for the function
renoise.tool():add_keybinding{name="Global:Paketti:Create New Instrument & Loop from Selection", invoke=create_new_instrument_from_selection}

-- Add keybinding for the function
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Create New Instrument & Loop from Selection", invoke=create_new_instrument_from_selection}


-- Add menu entry for the function
renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Create New Instrument & Loop from Selection", invoke=create_new_instrument_from_selection}





function pitchBendDrumkitLoader()
  -- Prompt the user to select multiple sample files to load
  local selected_sample_filenames = renoise.app():prompt_for_multiple_filenames_to_read({"*.wav", "*.aif", "*.flac", "*.mp3", "*.aiff"}, "Paketti PitchBend Drumkit Sample Loader")
  renoise.app():load_instrument("Presets/12st_Pitchbend_Drumkit_C0.xrni") -- Ensure this function exists and is correct

  -- Check if files are selected
  if #selected_sample_filenames > 0 then
    local current_instrument_index = renoise.song().selected_instrument_index
    local current_instrument = renoise.song().instruments[current_instrument_index]
    
    -- Limit the number of samples to 120
    local max_samples = 119
    local num_samples_to_load = math.min(#selected_sample_filenames, max_samples)

    -- Iterate over each selected file
    for i = 1, num_samples_to_load do
      local selected_sample_filename = selected_sample_filenames[i]

      -- Insert a new sample slot
      current_instrument:insert_sample_at(#current_instrument.samples + 1)
      local sample_index = #current_instrument.samples
      local sample = current_instrument.samples[sample_index]
      local sample_buffer = sample.sample_buffer
      local samplefilename = selected_sample_filename:match("^.+[/\\](.+)$")

      -- Set names for the instrument and sample
      renoise.song().selected_instrument.name = ("12st_" .. samplefilename)
      sample.name = ("12st_" .. samplefilename)

      -- Load the sample file into the sample buffer
      if sample_buffer:load_from(selected_sample_filename) then
        renoise.app():show_status("Sample " .. selected_sample_filename .. " loaded successfully.")
      else
        renoise.app():show_status("Failed to load the sample.")
      end

      -- Set additional sample properties
      sample.oversample_enabled = true
      sample.autofade = true
      sample.interpolation_mode = renoise.Sample.INTERPOLATE_CUBIC
    end

    -- Check if there are more samples than the limit
    if #selected_sample_filenames > max_samples then
      local not_loaded_count = #selected_sample_filenames - max_samples
      renoise.app():show_status("Maximum Drumkit Zones is 120 - was not able to load " .. not_loaded_count .. " samples.")
    end

    -- Additional actions after loading samples
    loadnative("Audio/Effects/Native/*Instr. Macros")
    renoise.song().selected_track.devices[2].is_maximized = false
    on_sample_count_change()
    -- showAutomation()
  else
    renoise.app():show_status("No files selected.")
  end
end

renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:Paketti PitchBend Drumkit Sample Loader", invoke=function() pitchBendDrumkitLoader() end}
renoise.tool():add_keybinding{name="Global:Paketti:Paketti PitchBend Drumkit Sample Loader", invoke=function() pitchBendDrumkitLoader() end}

-------------
function pitchBendMultipleSampleLoader()
  local selected_sample_filenames = renoise.app():prompt_for_multiple_filenames_to_read({"*.wav", "*.aif", "*.flac", "*.mp3", "*.aiff"}, "Paketti PitchBend Multiple Sample Loader")
  
  if #selected_sample_filenames > 0 then
    -- Print all selected filenames
    rprint(selected_sample_filenames)
    ---local filenames_str = ""
        -- Concatenate all filenames into a single string
    ---for index, filename in ipairs(selected_sample_filenames) do
    ---  filenames_str = filenames_str .. filename .. "\n" -- Adds each filename on a new line
    ---end

    -- Show the concatenated filenames in a message box
    ---renoise.app():show_message("Selected Files:\n" .. filenames_str)
    
    -- Iterate over each selected filename
    for index, filename in ipairs(selected_sample_filenames) do
      -- Insert a new instrument at the next index
      local next_instrument = renoise.song().selected_instrument_index + 1
      renoise.song():insert_instrument_at(next_instrument)
      renoise.song().selected_instrument_index = renoise.song().selected_instrument_index + 1
      -- Adjust pitch here if necessary
      if #renoise.song().instruments[renoise.song().selected_instrument_index].samples == 0 then
        renoise.song().instruments[renoise.song().selected_instrument_index]:insert_sample_at(1)
      end
        renoise.song().selected_sample_index=1
      
      -- Extract just the file name from each path
      local filename_only = filename:match("^.+[/\\](.+)$")
      
      -- Assume the new instrument is now the selected one due to insertion at selected index + 1
      local current_instrument_index = renoise.song().selected_instrument_index
      local current_sample = renoise.song().instruments[current_instrument_index].samples[1]
      
          renoise.song().selected_instrument.name=("12st_" .. filename_only)
      
      if renoise.song().selected_sample.sample_buffer:load_from(filename) then
        renoise.app():show_status("Sample " .. filename_only .. " loaded successfully.")
        current_sample.name = "12st_" .. filename_only -- Set the sample name
        
        -- Set sample properties
        current_sample.oversample_enabled = true
        current_sample.autofade = true
        loadnative("Audio/Effects/Native/*Instr. Macros")
        renoise.song().selected_track.devices[2].is_maximized=false
        --current_sample.autoseek = true
        current_sample.interpolation_mode = 4
--        showAutomation()
        -- Focus on the sample editor
       renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
       G01()
      else
        renoise.app():show_status("Failed to load the sample " .. filename_only)
      end
    end
  else
    renoise.app():show_status("No file selected.")
  end
end


renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Instruments:Paketti PitchBend Multiple Sample Loader",invoke=function() pitchBendMultipleSampleLoader() end}
renoise.tool():add_menu_entry{name="Disk Browser Files:Paketti..:Paketti PitchBend Multiple Sample Loader",invoke=function() pitchBendMultipleSampleLoader() end}
renoise.tool():add_keybinding{name="Global:Paketti:Paketti PitchBend Multiple Sample Loader",invoke=function() pitchBendMultipleSampleLoader() end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Midi PakettiPitchBend Multiple Sample Loader", invoke=function(message)
  if message.int_value > 1 then pitchBendMultipleSampleLoader() end end}
-----------


function noteOnToNoteOff(noteoffPitch)
-- // TODO: need to clear note-off-layer
-- // TODO: need to be able to copy the whole sample-space from note-on layer to note-off layer.

  if #renoise.song().instruments[renoise.song().selected_instrument_index].samples == 0 then
    return
  end

renoise.song().instruments[renoise.song().selected_instrument_index]:insert_sample_at(2)
renoise.song().selected_sample_index = 2
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index]:copy_from(renoise.song().instruments[renoise.song().selected_instrument_index].samples[1])
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].sample_mapping.layer=2
renoise.song().instruments[renoise.song().selected_instrument_index].sample_mappings[2][1].sample.transpose=noteoffPitch
renoise.song().instruments[renoise.song().selected_instrument_index].sample_mappings[2][1].sample.name = renoise.song().instruments[renoise.song().selected_instrument_index].sample_mappings[1][1].sample.name

renoise.song().selected_sample_index=1
end

renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer +24",invoke=function() noteOnToNoteOff(24) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer +12",invoke=function() noteOnToNoteOff(12) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer",invoke=function() noteOnToNoteOff(0) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer -12",invoke=function() noteOnToNoteOff(-12) end}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Copy Sample in Note-On to Note-Off Layer -24",invoke=function() noteOnToNoteOff(-24) end}

renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer +24",invoke=function() noteOnToNoteOff(24) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer +12",invoke=function() noteOnToNoteOff(12) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer",invoke=function() noteOnToNoteOff(0) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer -12",invoke=function() noteOnToNoteOff(-12) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Copy Sample in Note-On to Note-Off Layer -24",invoke=function() noteOnToNoteOff(-24) end}





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
    local s = renoise.song()
    s.selected_sample_index = 1
    local currInst = s.selected_instrument_index
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
    local beatsynclines = beatsync_lines[changer] or 64  -- Default to 32 if no match found
    local currentTranspose = renoise.song().selected_sample.transpose
    
    -- Assuming that preferences are defined somewhere globally accessible in your script
    local prefs = {
        loop_mode = preferences.WipeSlicesLoopMode.value,
        new_note_action = preferences.WipeSlicesNNA.value,
        oneshot = preferences.WipeSlicesOneShot.value,
        autofade = true,
        autoseek = preferences.WipeSlicesAutoseek.value,
        transpose = currentTranspose,
        mute_group = preferences.WipeSlicesMuteGroup.value,
        interpolation_mode = 4,  -- High Quality Interpolation
        beat_sync_mode = preferences.WipeSlicesBeatSyncMode.value,
        oversample_enabled = true
    }

    -- Clear existing slice markers from the first sample
    for i = #s.instruments[currInst].samples[1].slice_markers, 1, -1 do
        s.instruments[currInst].samples[1]:delete_slice_marker(s.instruments[currInst].samples[1].slice_markers[i])
    end
    
    -- Insert new slice markers
    local tw = s.selected_sample.sample_buffer.number_of_frames / changer
     s.instruments[currInst].samples[currSamp]:insert_slice_marker(1) 
    for i = 1, changer -1 do
        s.instruments[currInst].samples[currSamp]:insert_slice_marker(tw * i)
    end
    
    -- Apply settings to all samples created by the slicing
    for i, sample in ipairs(s.instruments[currInst].samples) do
        sample.loop_mode = prefs.loop_mode
        sample.new_note_action = prefs.new_note_action
        sample.oneshot = prefs.oneshot
        sample.autofade = prefs.autofade
        sample.autoseek = prefs.autoseek
        sample.transpose = prefs.transpose
        sample.mute_group = prefs.mute_group
        sample.interpolation_mode = prefs.interpolation_mode
        sample.beat_sync_mode = prefs.beat_sync_mode
        sample.oversample_enabled = prefs.oversample_enabled
        sample.beat_sync_enabled = true
       -- if preferences.WipeSlicesBeatSyncGlobal.value == true then
        sample.beat_sync_lines = beatsynclines
       -- print ("hello")
       -- else return end
    end
    
    -- Ensure beat sync is enabled for the original sample
  --  if preferences.WipeSlicesBeatSyncGlobal.value == true then 
    
    renoise.song().instruments[currInst].samples[1].beat_sync_lines = 128
    renoise.song().instruments[currInst].samples[1].beat_sync_enabled = true
 --   else return
 --   end
end

--
--Wipe all slices
function wipeslices()
local currInst=renoise.song().selected_instrument_index
local currSamp=renoise.song().selected_sample_index
local number=(table.count(renoise.song().instruments[currInst].samples[1].slice_markers))

  for i=1,number do renoise.song().instruments[currInst].samples[1]:delete_slice_marker((renoise.song().instruments[currInst].samples[1].slice_markers[1]))
  end
  renoise.song().selected_sample.loop_mode=1
renoise.song().selected_sample.beat_sync_enabled=false
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

renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Double BeatSync Line",invoke=function() doubleBeatSyncLines() end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Halve BeatSync Line",invoke=function() halveBeatSyncLines() end}
--------------
function DSPFXChain()
renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS end

renoise.tool():add_keybinding{name="Global:Paketti:Show DSP FX Chain",invoke=function() DSPFXChain() end}
---


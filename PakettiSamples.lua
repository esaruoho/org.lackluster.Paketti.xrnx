function pitchBendSampleLoader()
 
  local selected_sample_filename = renoise.app():prompt_for_filename_to_read({"*.wav", "*.aif", "*.flac", "*.mp3", "*.aiff"}, "Paketti PitchBend Single Sample Loader")
  if selected_sample_filename ~= "" then
    -- print("File selected: " .. selected_sample_filename)
    
    local current_instrument_index = renoise.song().selected_instrument_index
      pitchedInstrument(12)
      if #renoise.song().instruments[renoise.song().selected_instrument_index].samples == 0 then
        renoise.song().instruments[renoise.song().selected_instrument_index]:insert_sample_at(1)
      end
      
    local sample_buffer = renoise.song().instruments[current_instrument_index].samples[1].sample_buffer
    local samplefilename = selected_sample_filename:match("^.+[/\\](.+)$")
    
    renoise.song().selected_instrument.name=("12st_" .. samplefilename)
    renoise.song().instruments[renoise.song().selected_instrument_index].samples[1].name=("12st_" .. samplefilename)  
    
    if sample_buffer:load_from(selected_sample_filename) then
      renoise.app():show_status("Sample " .. selected_sample_filename .. " loaded successfully.")
    else
      renoise.app():show_status("Failed to load the sample.")
      
    end
  else
    renoise.app():show_status("No file selected.")
    return
  end
        renoise.song().selected_sample.oversample_enabled=true
        renoise.song().selected_sample.autofade=true
        renoise.song().selected_sample.autoseek=true
        renoise.song().selected_sample.interpolation_mode = 4
        renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
end

renoise.tool():add_menu_entry{name="--Main Menu:Tools:Paketti..:Instruments:Paketti PitchBend Single Sample Loader",invoke=function() pitchBendSampleLoader() end}
renoise.tool():add_keybinding{name="Global:Paketti:Paketti PitchBend Single Sample Loader", invoke=function() pitchBendSampleLoader() end}

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
      pitchedInstrument(12) -- Ensure this function exists and is correct
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
        current_sample.autoseek = true
        current_sample.interpolation_mode = 4

        -- Focus on the sample editor
        renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
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

renoise.tool():add_keybinding{name="Global:Paketti:Paketti PitchBend Multiple Sample Loader", invoke=function() pitchBendMultipleSampleLoader() end}


renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Sample Preferences - Autofade True, Interpolation 4, Oversample True",invoke=function() 
  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].autofade=true
  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].interpolation_mode=4
  renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].oversample_enabled=true

end}


function selectedSampleInit()
renoise.song().instruments[renoise.song().selected_instrument_index].macros_visible=true
renoise.song().instruments[renoise.song().selected_instrument_index].macros[1].name="PitchCtrl"
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].autofade=true
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].interpolation_mode=4
renoise.song().instruments[renoise.song().selected_instrument_index].samples[renoise.song().selected_sample_index].oversample_enabled=true
end

renoise.tool():add_keybinding{name="Global:Paketti:Init Selected Sample (Autofade,Interpolation,Oversample)", invoke=function() 
selectedSampleInit() end}


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
    
    
    -- Assuming that preferences are defined somewhere globally accessible in your script
    local prefs = {
        loop_mode = preferences.WipeSlicesLoopMode.value,
        new_note_action = preferences.WipeSlicesNNA.value,
        oneshot = preferences.WipeSlicesOneShot.value,
        autofade = true,
        autoseek = preferences.WipeSlicesAutoseek.value,
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

renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (004) x[Toggle]",invoke=function() slicerough(4) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (008) x[Toggle]",invoke=function() slicerough(8) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (016) x[Toggle]",invoke=function() slicerough(16) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (032) x[Toggle]",invoke=function() slicerough(32) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (064) x[Toggle]",invoke=function() slicerough(64) end}
renoise.tool():add_midi_mapping{name="Global:Paketti:Wipe&Create Slices (128) x[Toggle]",invoke=function() slicerough(128) end}

renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (2)",invoke=function() slicerough(2) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (4)",invoke=function() slicerough(4) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (8)",invoke=function() slicerough(8) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (16)",invoke=function() slicerough(16) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (32)",invoke=function() slicerough(32) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (64)",invoke=function() slicerough(64) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe&Create Slices (128)",invoke=function() slicerough(128) end}
renoise.tool():add_keybinding{name="Global:Paketti:Wipe Slices",invoke=function() wipeslices() end}

renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (2)",invoke=function() slicerough(2) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (4)",invoke=function() slicerough(4) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (8)",invoke=function() slicerough(8) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (16)",invoke=function() slicerough(16) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (32)",invoke=function() slicerough(32) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (64)",invoke=function() slicerough(64) end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Wipe&Create Slices (128)",invoke=function() slicerough(128) end}

renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Double BeatSync Line",invoke=function() doubleBeatSyncLines() end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Halve BeatSync Line",invoke=function() halveBeatSyncLines() end}


renoise.tool():add_menu_entry{name="--Sample Editor:Paketti..:Wipe Slices",invoke=function() wipeslices() end}
--------------

function DSPFXChain()
renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS end

renoise.tool():add_keybinding{name="Global:Paketti:Show DSP FX Chain",invoke=function() DSPFXChain() end}

---


local vb = renoise.ViewBuilder()
  local buffer = nil
  local current_name = nil
  local current_rate = nil
  local current_length = nil
  local current_bit_depth = nil
  local destination_rate = nil
  local destination_bit_depth = nil

local pitch_shift_amount = 0
local dialog = nil
local content = nil
local slider_value=vb:text{text="1"} -- initial text showing the slider value

  local sample_name_text=vb:text{id="sample_name_text",text="Name: No valid sample selected"}
  local details_text=vb:text{id="details_text",text="Details: No valid sample selected"}
  
-- Utility function to copy sample settings
local function copy_sample_settings(from_sample, to_sample)
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

-- Function to limit the sample to avoid clipping
local function limit_sample(buffer)
  local max_value = 0
  for c = 1, buffer.number_of_channels do
    for f = 1, buffer.number_of_frames do
      local value = math.abs(buffer:sample_data(c, f))
      if value > max_value then max_value = value end
    end
  end

  if max_value > 0 then
    local normalization_factor = 1 / max_value
    buffer:prepare_sample_data_changes()
    for c = 1, buffer.number_of_channels do
      for f = 1, buffer.number_of_frames do
        local normalized_value = buffer:sample_data(c, f) * normalization_factor
        buffer:set_sample_data(c, f, normalized_value)
      end
    end
    buffer:finalize_sample_data_changes()
  end
end


-- Function to create an audio diff sample
local function create_audio_diff_sample()
  local song = renoise.song()
  local sample = song.selected_sample
  local duplicate = duplicate_sample()
  if not duplicate then return end

  local buffer1 = sample.sample_buffer
  local buffer2 = duplicate.sample_buffer
  if not buffer1.has_sample_data or not buffer2.has_sample_data then 
    renoise.app():show_status("The Sample Buffer has no data.") 
    return 
  end

  buffer1:prepare_sample_data_changes()

  for c = 1, buffer1.number_of_channels do
    for f = 1, buffer1.number_of_frames do
      local diff_value = buffer1:sample_data(c, f) - buffer2:sample_data(c, f)
      buffer1:set_sample_data(c, f, diff_value)
    end
  end

  buffer1:finalize_sample_data_changes()

  -- Copy sample settings and name
  copy_sample_settings(sample, duplicate)

  -- Limit the output to avoid clipping
  limit_sample(buffer1)

  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
  renoise.app():show_status("Audio Diff applied.")
end


-- Function to duplicate a sample
local function duplicate_sample()
  local song = renoise.song()
  local instrument = song.selected_instrument
  if not instrument then renoise.app():show_status("There is no Instrument selected.") return nil end
  local sample = song.selected_sample
  if not sample then renoise.app():show_status("There is no Sample selected.") return nil end

  -- Create a duplicate of the selected sample
  local duplicate = instrument:insert_sample_at(#instrument.samples + 1)
  duplicate:copy_from(sample)

  return duplicate
end


-- Ensure focus returns to the middle frame after each button press
local function set_middle_frame_focus()
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
end


-- Function to mix and process samples with various operations
local function mix_and_process_samples(operation, mod_function)
  local song = renoise.song()
  local sample = song.selected_sample
  local duplicate = duplicate_sample()
  if not duplicate then return end

  local buffer1 = sample.sample_buffer
  local buffer2 = duplicate.sample_buffer
  if not buffer1.has_sample_data or not buffer2.has_sample_data then 
    renoise.app():show_status("The Sample Buffer has no data.") 
    return 
  end

  buffer1:prepare_sample_data_changes()

  for c = 1, buffer1.number_of_channels do
    for f = 1, buffer1.number_of_frames do
      local original_value = buffer1:sample_data(c, f)
      local processed_value = buffer2:sample_data(c, f)
      
      -- Apply operation with possible modulation
      local new_value = 0
      if operation == "diff" then
        new_value = original_value - processed_value
      elseif operation == "modulate" then
        new_value = original_value * (mod_function and mod_function(processed_value) or processed_value)
      elseif operation == "sum" then
        new_value = original_value + processed_value
      end

      buffer1:set_sample_data(c, f, new_value)
    end
  end

  buffer1:finalize_sample_data_changes()

  -- Limit the output to avoid clipping
  limit_sample(buffer1)

  -- Copy sample settings and name
  copy_sample_settings(sample, duplicate)

  -- Mute the duplicate sample
  duplicate.volume = 0.0
  
  -- Return to the original sample
  song.selected_sample_index = 1
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR

  renoise.app():show_status("Sample " .. operation .. " applied and mixed.")
end


-- Function to perform phase inversion (subtraction) on a sample
local function phase_invert_sample()
  local song = renoise.song()
  local sample = song.selected_sample
  local duplicate = duplicate_sample()
  if not duplicate then return end

  local buffer1 = sample.sample_buffer
  local buffer2 = duplicate.sample_buffer
  if not buffer1.has_sample_data or not buffer2.has_sample_data then 
    renoise.app():show_status("The Sample Buffer has no data.") 
    return 
  end

  buffer1:prepare_sample_data_changes()

  for c = 1, buffer1.number_of_channels do
    for f = 1, buffer1.number_of_frames do
      local original_value = buffer1:sample_data(c, f)
      local duplicate_value = buffer2:sample_data(c, f)
      buffer1:set_sample_data(c, f, original_value - duplicate_value) -- Direct subtraction
    end
  end

  buffer1:finalize_sample_data_changes()

  -- Copy sample settings and name
  copy_sample_settings(sample, duplicate)

  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR

  renoise.app():show_status("Phase Inversion (Subtraction) applied.")
end

-- Function to handle Phase Inversion and Audio Diff
local function phase_invert_and_diff_sample()
  phase_invert_sample()
  create_audio_diff_sample()
end

-- Function to perform inversion of right channel and summing to mono
local function invert_right_sum_mono()
  local song = renoise.song()
  local sample = song.selected_sample
  local buffer = sample.sample_buffer

  if buffer.number_of_channels ~= 2 then
    renoise.app():show_status("The sample needs to be stereo")
    return
  end

  local sample_rate = buffer.sample_rate
  local bit_depth = buffer.bit_depth
  local num_frames = buffer.number_of_frames

  -- Create a new mono sample
  local instrument = song.selected_instrument
  local mono_sample = instrument:insert_sample_at(#instrument.samples + 1)
  mono_sample.sample_buffer:create_sample_data(sample_rate, bit_depth, 1, num_frames)
  local mono_buffer = mono_sample.sample_buffer

  mono_buffer:prepare_sample_data_changes()

  for f = 1, num_frames do
    local left = buffer:sample_data(1, f)
    local right = buffer:sample_data(2, f) * -1 -- Invert Right Channel
    local sum = left + right
    mono_buffer:set_sample_data(1, f, sum)
  end

  mono_buffer:finalize_sample_data_changes()

  -- Copy sample settings and name
  copy_sample_settings(sample, mono_sample)
  mono_sample.name = sample.name .. " (InvertRight&Mono)"

  -- Delete the original stereo sample
  local original_index = song.selected_sample_index
  instrument:delete_sample_at(original_index)

  -- Set the new mono sample as the selected sample
  song.selected_sample_index = #instrument.samples
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR

  renoise.app():show_status("Invert Right, Sum Mono applied.")
end

-- Function to perform pitch shifting and subtraction
local function pitch_shift_sample(shift_amount)
  if shift_amount == 0 then
    renoise.app():show_status("Set pitch valuebox to something other than 0, otherwise nothing happens.")
    return
  end

  local song = renoise.song()
  local duplicate = duplicate_sample()
  if not duplicate then return end

  local buffer = duplicate.sample_buffer
  if not buffer.has_sample_data then renoise.app():show_status("The Sample Buffer has no data.") return end

  buffer:prepare_sample_data_changes()
  local num_frames = buffer.number_of_frames
  local new_buffer = {}
  for c = 1, buffer.number_of_channels do
    new_buffer[c] = {}
    for f = 1, num_frames do
      local pos = f + shift_amount
      if pos < 1 or pos > num_frames then new_buffer[c][f] = 0 else new_buffer[c][f] = buffer:sample_data(c, math.floor(pos)) end
    end
  end
  for c = 1, buffer.number_of_channels do 
    for f = 1, num_frames do 
      buffer:set_sample_data(c, f, new_buffer[c][f]) 
    end 
  end
  buffer:finalize_sample_data_changes()

  -- Copy sample settings and name
  copy_sample_settings(song.selected_sample, duplicate)

  mix_and_process_samples("diff")
end

-- Function to handle Pitch Shift and Audio Diff
local function pitch_shift_and_diff_sample()
  if pitch_shift_amount == 0 then
    renoise.app():show_status("Set pitch valuebox to something other than 0, otherwise nothing happens.")
    return
  end

  pitch_shift_sample(pitch_shift_amount)
  create_audio_diff_sample()
end

-- Function to perform modulation
local function modulate_samples()
  mix_and_process_samples("modulate")
end

-- Function to handle Modulation and Audio Diff
local function modulate_and_diff_sample()
  modulate_samples()
  create_audio_diff_sample()
end

-- Function to create an audio diff sample
local function create_audio_diff_sample()
  local song = renoise.song()
  local sample = song.selected_sample
  local duplicate = duplicate_sample()
  if not duplicate then return end

  local buffer1 = sample.sample_buffer
  local buffer2 = duplicate.sample_buffer
  if not buffer1.has_sample_data or not buffer2.has_sample_data then 
    renoise.app():show_status("The Sample Buffer has no data.") 
    return 
  end

  buffer1:prepare_sample_data_changes()

  for c = 1, buffer1.number_of_channels do
    for f = 1, buffer1.number_of_frames do
      local diff_value = buffer1:sample_data(c, f) - buffer2:sample_data(c, f)
      buffer1:set_sample_data(c, f, diff_value)
    end
  end

  buffer1:finalize_sample_data_changes()

  -- Copy sample settings and name
  copy_sample_settings(sample, duplicate)

  -- Limit the output to avoid clipping
  limit_sample(buffer1)

  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
  renoise.app():show_status("Audio Diff applied.")
end


-- Function to render the sample at a new sample rate without changing its sound
local function RenderSampleAtNewRate(target_sample_rate, target_bit_depth)
  local song = renoise.song()
  local instrument = song.selected_instrument
  local sample_index = song.selected_sample_index
  local sample = instrument:sample(sample_index)
  local buffer = sample.sample_buffer

  if buffer.has_sample_data then
    local original_sample_rate = buffer.sample_rate
    local original_frame_count = buffer.number_of_frames
    local ratio = target_sample_rate / original_sample_rate
    local new_frame_count = math.floor(original_frame_count * ratio)
    
    -- Create a new sample with the target rate and bit depth
    local new_sample = instrument:insert_sample_at(sample_index + 1)
    copy_sample_settings(sample, new_sample)
    
    new_sample.sample_buffer:create_sample_data(target_sample_rate, target_bit_depth, buffer.number_of_channels, new_frame_count)
    local new_sample_buffer = new_sample.sample_buffer
    
    new_sample_buffer:prepare_sample_data_changes()
    
    -- Render the original sample into the new sample buffer, adjusting frame count
    for c=1, buffer.number_of_channels do
      for i=1, new_frame_count do
        local original_index = math.floor(i / ratio)
        original_index = math.max(1, math.min(original_frame_count, original_index))
        new_sample_buffer:set_sample_data(c, i, buffer:sample_data(c, original_index))
      end
    end
    
    new_sample_buffer:finalize_sample_data_changes()
    
    -- Delete the original sample and select the new one
    instrument:delete_sample_at(sample_index)
    song.selected_sample_index = #instrument.samples -- Select the new sample

    renoise.app():show_status("Sample resampled to " .. target_sample_rate .. " Hz and " .. target_bit_depth .. " bit.")
  else
    renoise.app():show_status("Sample buffer is either not loaded or is not at the correct sample rate.")
  end
end

-- Function to destructively resample the selected sample to a specified sample rate
local function DestructiveResample(target_sample_rate, target_bit_depth)
  local song = renoise.song()
  local instrument = song.selected_instrument
  local sample_index = song.selected_sample_index
  local sample = instrument:sample(sample_index)
  local buffer = sample.sample_buffer
  
  if buffer.has_sample_data then
    local original_sample_rate = buffer.sample_rate
    local original_frame_count = buffer.number_of_frames
    local ratio = target_sample_rate / original_sample_rate
    local new_frame_count = math.floor(original_frame_count * ratio)
    
    -- Pre-calculate all required information before deleting the sample
    local original_sample_data = {}
    for c=1, buffer.number_of_channels do
      original_sample_data[c] = {}
      for i=1, new_frame_count do
        local original_index = math.floor(i / ratio)
        original_index = math.max(1, math.min(original_frame_count, original_index))
        original_sample_data[c][i] = buffer:sample_data(c, original_index)
      end
    end

    local new_sample = instrument:insert_sample_at(sample_index + 1)
    copy_sample_settings(sample, new_sample)
    
    -- Create the new sample buffer with the selected rate and bit depth
    new_sample.sample_buffer:create_sample_data(target_sample_rate, target_bit_depth, buffer.number_of_channels, new_frame_count)
    local new_sample_buffer = new_sample.sample_buffer
    
    new_sample_buffer:prepare_sample_data_changes()

    -- Apply the precalculated sample data to the new buffer
    for c=1, buffer.number_of_channels do
      for i=1, new_frame_count do
        new_sample_buffer:set_sample_data(c, i, original_sample_data[c][i])
      end
    end

    -- Finalize changes and delete the original sample
    new_sample_buffer:finalize_sample_data_changes()
    instrument:delete_sample_at(sample_index)
    song.selected_sample_index = #instrument.samples -- Select the new sample

    renoise.app():show_status("Sample processed with " .. target_sample_rate .. " Hz and " .. target_bit_depth .. " bit.")
  else
    renoise.app():show_status("Sample buffer is either not loaded or is not at the correct sample rate.")
  end
end



-- Function to create combined dialog content with full resampling functionality
local function create_combined_dialog_content()
  local vb = renoise.ViewBuilder()  -- Create a fresh ViewBuilder instance every time the dialog is opened
  local sample = renoise.song().selected_sample

  if not sample or not sample.sample_buffer.has_sample_data then
    renoise.app():show_status("Please select a sample with data.")
    return
  end

    
  local buffer = sample.sample_buffer
  local current_name = sample.name
  local current_rate = buffer.sample_rate
  local current_length = buffer.number_of_frames
  local current_bit_depth = buffer.bit_depth
  local destination_rate = current_rate
  local destination_bit_depth = current_bit_depth
  local threshold_label=vb:text{text=string.format("%.3f%%", preferences.PakettiStripSilenceThreshold.value*100),width=60}
  local begthreshold_label=vb:text{text=string.format("%.3f%%", preferences.PakettiMoveSilenceThreshold.value*100),width=60}



  
  -- Create the dialog content
  local dialog_content = vb:column { width=375,
    margin = 5,vb:column{style="group",margin=5,width=365,
    vb:row {
      vb:text {text = "Silence Threshold:"},
      vb:slider {
        min = 0,
        max = 1,
        value = preferences.PakettiStripSilenceThreshold.value,
        width = 200,
        notifier = function(value)
          threshold_label.text = string.format("%.3f%%", value * 100)
          preferences.PakettiStripSilenceThreshold.value = value
        end
      },
      threshold_label
    },
    vb:button {
      text = "Strip Silence using Threshold",
      notifier = function()
        if preferences.PakettiStripSilenceThreshold.value == 1 then
          local choice = renoise.app():show_prompt("Warning", "Are you sure you want to remove this sample?", {"Yes", "Cancel"})
          if choice == "Yes" then
            local song = renoise.song()
            local sample_index = song.selected_sample_index
            local instrument = song.selected_instrument
            if instrument and sample_index > 0 and instrument:sample(sample_index) then
              instrument:delete_sample_at(sample_index)
              renoise.app():show_status("Sample removed.")
            end
          end
        else
          PakettiStripSilence()
          renoise.app():show_status("Removed Silence from beginning + end of sample at threshold " .. (preferences.PakettiStripSilenceThreshold.value * 100) .. "%")
        end
        renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
      end
    },
        vb:row {
      vb:text {text = "Silence Threshold:"},
      vb:slider {
        min = 0,
        max = 1,
        value = preferences.PakettiMoveSilenceThreshold.value,
        width = 200,
        notifier = function(value)
          begthreshold_label.text = string.format("%.3f%%", value * 100)
          preferences.PakettiMoveSilenceThreshold.value = value
        end
      },
      begthreshold_label
    },
    vb:button {
      text = "Move Beginning Silence to End",
      notifier = function()
        PakettiMoveSilence()
        renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
      end
    },
    vb:button{ text="15 Frame Fade In & Fade Out",
    notifier=function() 
    apply_fade_in_out() 
        renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
      end
    }},

    vb:column{style="group",margin=5,width=365,
    vb:row{vb:button{text="Recursive DC Offset", notifier= function() remove_dc_offset_recursive() end}},
  vb:row{
    vb:button{
      text = "Run Recursive DC Offset x times",
      notifier = function()
        local count = tonumber(vb.views.slider_value.text)
        for i = 1, count do
          remove_dc_offset_recursive()
        end
        renoise.app():show_status("Ran DC Offset " .. count .. " times")
      end
    }
  },
  vb:row{
    vb:slider{
      min = 1,
      max = 500,
      value = 1,
      width = 200,
      notifier = function(value)
        vb.views.slider_value.text = tostring(math.floor(value))
      end
    },
    vb:text{
      id = "slider_value",
      text = "1",
      width=40, -- initial value
    }
  },

    vb:row{vb:button{text="Run Recursive DC Offset 1-50 times (randomized)", notifier= function() remove_dc_offset_recursive_1to50() end}},
    vb:row{vb:button{text="Max Amp DC Offset Kick Generator", notifier= function() pakettiMaxAmplitudeDCOffsetKickCreator() 
    renoise.song().selected_sample.name="Max Amp DC Offset Kick"
    renoise.song().selected_instrument.name="Max Amp DC Offset Kick"
               update_sample_details(sample_name_text, details_text)

    end}},
    
  },  
vb:column{style="group",margin=5,width=365,
vb:row{vb:button{text="Invert Left Channel", notifier=function() PakettiSampleInvertLeftChannel() end},
vb:button{text="Invert Right Channel", notifier=function() PakettiSampleInvertRightChannel()end},
vb:button{text="Invert Sample", notifier=function() PakettiSampleInvertEntireSample() end},
}},
vb:column{style="group",margin=5,width=365,
vb:row{vb:button{text="Mono->Stereo", notifier=function() convert_mono_to_stereo() end},
vb:button{text="Mono->Stereo (Blank L)", notifier=function() mono_to_blank(0,1) end},
vb:button{text="Mono->Stereo (Blank R)", notifier=function() mono_to_blank(1,0) end},
}},
vb:column{style="group",margin=5,width=365,
vb:row{vb:button{text="Normalize Sample",notifier=function() normalize_selected_sample() end},
}},




    
vb:column{style="group",margin=5,width=365,

      -- Phase Inversion Buttons
      vb:row{vb:button {text = "Phase Inversion", notifier = function() phase_invert_sample() set_middle_frame_focus() end},
        vb:button {text = "Phase Inversion & Audio Diff", notifier = function() phase_invert_and_diff_sample() set_middle_frame_focus() end},},

      vb:row {vb:button {text = "Invert Right, Sum Mono", notifier = function() invert_right_sum_mono() set_middle_frame_focus() end},},

      -- Pitch Shift Buttons
      vb:row {
        vb:valuebox {min = -100, max = 100, value = pitch_shift_amount, notifier = function(value) pitch_shift_amount = value end},
        vb:button {text = "Pitch Shift", notifier = function() pitch_shift_sample(pitch_shift_amount) set_middle_frame_focus() end},
        vb:button {text = "Pitch Shift & Audio Diff", notifier = function() pitch_shift_and_diff_sample() set_middle_frame_focus() end},
      },

      vb:row {vb:button {text = "Clip Bottom of Waveform", notifier = function() modulate_samples() set_middle_frame_focus() end},
        vb:button {text = "Modulate & Audio Diff", notifier = function() modulate_and_diff_sample() set_middle_frame_focus() end},},

      -- Audio Diff Button
      vb:row {vb:button {text = "Audio Diff", notifier = function() create_audio_diff_sample() set_middle_frame_focus() end},}},
    
    -- Resampling Section
    vb:column{style="group", margin=5,
    vb:text{text="Resample", style="strong", font="bold"},
        sample_name_text,
        details_text, 
    vb:space{height=10}, 
    vb:slider{
      id="rate_slider",
      min=225,
      max=192000,
      value=current_rate,
      width=354,
      notifier=function(value)
        destination_rate=math.floor(value)
        vb.views.rate_label.text="Destination Sample Rate: "..destination_rate.."Hz" end},
    
    vb:text{id="rate_label",text="Destination Sample Rate: "..current_rate.."Hz"},
    vb:row{width="100%",
    vb:button{
      text="Halve Sample Rate",
      notifier=function()
        destination_rate=math.max(225,math.floor(vb.views.rate_slider.value/2))
        vb.views.rate_slider.value=destination_rate
      end,},
    vb:button{
      text="Double Sample Rate",
      notifier=function()
        destination_rate=math.min(192000,math.floor(vb.views.rate_slider.value*2))
        vb.views.rate_slider.value=destination_rate
      end,},
    vb:button{
      text="Resample to 44.1 kHz",
      notifier=function()
        destination_rate=44100
        vb.views.rate_slider.value=destination_rate
        RenderSampleAtNewRate(destination_rate, vb.views.bitdepth_switch.value*8)
      end}},
    vb:row{vb:text{text="Bit Depth:"},
      vb:switch{
        width=300,
        id="bitdepth_switch",
        items={"8bit","16bit","24bit","32bit"},
        value=(current_bit_depth/8),
        notifier=function(idx) destination_bit_depth=idx*8 end,},},
    vb:space{height=5},
    vb:button{
      text="Process",
      notifier=function()
        local song=renoise.song()
        local instrument=song.selected_instrument
        local sample_index=song.selected_sample_index
        local sample=instrument:sample(sample_index)
        local buffer=sample.sample_buffer
  
        if destination_rate==buffer.sample_rate and destination_bit_depth==buffer.bit_depth then
          renoise.app():show_status("Sample rate and bit depth are already set to the selected values.")
        elseif destination_rate>=buffer.sample_rate then
          RenderSampleAtNewRate(destination_rate,destination_bit_depth)
        else
          DestructiveResample(destination_rate,destination_bit_depth)
        end
        update_sample_details(sample_name_text,details_text)
      end}},
  
        vb:button{text="Close",
        notifier=function()
        PakettiAudioProcessingToolsDialogClose()
 update_sample_details(sample_name_text, details_text) 
        end}
        
        },
 update_sample_details(sample_name_text, details_text)
   update_sample_details(details_text, sample_name_text)
  return dialog_content
end

local function update_dialog_on_selection_change()
--  if dialog and dialog.visible then
    -- Access the UI elements directly from vb.views and pass them to update_sample_details
--    if vb.views.sample_name_text and vb.views.details_text then




  local song = renoise.song()
  if song then
    local instrument = song.selected_instrument
    if instrument then
      local sample_index = song.selected_sample_index

      if sample_index > 0 and sample_index <= #instrument.samples then
        local sample = instrument:sample(sample_index)
        if sample then
          local buffer = sample.sample_buffer
          if buffer and buffer.has_sample_data then
            -- Update the UI elements with valid sample data
            details_text.text = string.format("Details: %dHz, %dbit, %d frames", 
              buffer.sample_rate, buffer.bit_depth, buffer.number_of_frames)
            sample_name_text.text = "Name: " .. sample.name

            renoise.app():show_status("Sample details and name updated.")
            return  -- Exit after successful update
          end
        end
      end
    end
  end

  -- Fallback if no valid sample is available
  details_text.text = "Details: No valid sample selected"
  sample_name_text.text = "Name: No valid sample selected"



      update_sample_details(details_text, sample_name_text)
--    else
--      print("details_text or sample_name_text view is not initialized!")
--    end
--  end
end

-- Function to show or hide the combined dialog
function PakettiAudioProcessingToolsDialogShow()  
  if renoise.song().selected_instrument_observable:has_notifier(update_dialog_on_selection_change) then
    renoise.song().selected_instrument_observable:remove_notifier(update_dialog_on_selection_change)
  end
  if renoise.song().selected_sample_observable:has_notifier(update_dialog_on_selection_change) then
    renoise.song().selected_sample_observable:remove_notifier(update_dialog_on_selection_change)
  end

  -- Add the observers
  renoise.song().selected_instrument_observable:add_notifier(update_dialog_on_selection_change)
  renoise.song().selected_sample_observable:add_notifier(update_dialog_on_selection_change)

  -- Close the dialog if it's already open
  if dialog and dialog.visible then
    dialog:close()
    dialog = nil
  if renoise.song().selected_instrument_observable:has_notifier(update_dialog_on_selection_change) then
    renoise.song().selected_instrument_observable:remove_notifier(update_dialog_on_selection_change)
  end
  if renoise.song().selected_sample_observable:has_notifier(update_dialog_on_selection_change) then
    renoise.song().selected_sample_observable:remove_notifier(update_dialog_on_selection_change)
  end


    return
  end

  -- Create the dialog content
  local content = create_combined_dialog_content()
  if content then
    -- Show the dialog with the created content and key handler
    dialog = renoise.app():show_custom_dialog("Paketti Audio Processing Tools", content, my_AudioProckeyhandler_func)
  else
    renoise.app():show_status("A sample must be selected.")
    
  end
renoise.app().window.active_middle_frame=renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
end

function PakettiAudioProcessingToolsDialogClose()
  -- Remove the observers
  if renoise.song().selected_instrument_observable:has_notifier(update_dialog_on_selection_change) then
    renoise.song().selected_instrument_observable:remove_notifier(update_dialog_on_selection_change)
  end
  if renoise.song().selected_sample_observable:has_notifier(update_dialog_on_selection_change) then
    renoise.song().selected_sample_observable:remove_notifier(update_dialog_on_selection_change)
  end

  if dialog and dialog.visible then
    dialog:close()
  end
end

-- Keyhandler function for dialog
function my_AudioProckeyhandler_func(dialog, key)
local closer = preferences.pakettiDialogClose.value
  if key.modifiers == "" and key.name == closer then
    dialog:close()
    dialog = nil
    return nil
else
    return key
  end
end

-- Ensure focus returns to the middle frame after each button press
local function set_middle_frame_focus()
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
end

-- Keybindings for various operations
renoise.tool():add_keybinding {name = "Sample Editor:Paketti:Phase Inversion", invoke = function() phase_invert_sample() end}
renoise.tool():add_keybinding {name = "Sample Editor:Paketti:Phase Inversion & Audio Diff", invoke = function() phase_invert_and_diff_sample() end}
renoise.tool():add_keybinding {name = "Sample Editor:Paketti:Pitch Shift", invoke = function() pitch_shift_sample(20) end}
renoise.tool():add_keybinding {name = "Sample Editor:Paketti:Pitch Shift & Audio Diff", invoke = function() pitch_shift_and_diff_sample() end}
renoise.tool():add_keybinding {name = "Sample Editor:Paketti:Clip bottom of waveform", invoke = function() modulate_samples() end}
renoise.tool():add_keybinding {name = "Sample Editor:Paketti:Modulate & Audio Diff", invoke = function() modulate_and_diff_sample() end}
renoise.tool():add_keybinding {name = "Sample Editor:Paketti:Invert Right, Sum Mono", invoke = function() invert_right_sum_mono() end}
renoise.tool():add_keybinding {name = "Sample Editor:Paketti:Audio Diff", invoke = function() create_audio_diff_sample() end}
renoise.tool():add_keybinding {name = "Global:Paketti:Paketti Audio Processing Tools Dialog...", invoke = function() PakettiAudioProcessingToolsDialogShow() end}

function update_sample_details(details_text, sample_name_text)
  -- If UI elements are not properly initialized, exit early
 -- if not details_text or not sample_name_text then
 --   print("UI elements are not initialized yet.")
 --   return
 -- end

  local song = renoise.song()
  if song then
    local instrument = song.selected_instrument
    if instrument then
      local sample_index = song.selected_sample_index

      if sample_index > 0 and sample_index <= #instrument.samples then
        local sample = instrument:sample(sample_index)
        if sample then
          local buffer = sample.sample_buffer
          if buffer and buffer.has_sample_data then
            -- Update the UI elements with valid sample data
            details_text.text = string.format("Details: %dHz, %dbit, %d frames", 
              buffer.sample_rate, buffer.bit_depth, buffer.number_of_frames)
            sample_name_text.text = "Name: " .. sample.name

            renoise.app():show_status("Sample details and name updated.")
            return  -- Exit after successful update
          end
        end
      end
    end
  end

  -- Fallback if no valid sample is available
  details_text.text = "Details: No valid sample selected"
  sample_name_text.text = "Name: No valid sample selected"
end

function PakettiStripSilence()
  local song = renoise.song()
  local sample_index = song.selected_sample_index
  local instrument = song.selected_instrument
  local threshold = renoise.tool().preferences.PakettiStripSilenceThreshold.value
  
  if not instrument or sample_index == 0 or not instrument:sample(sample_index) then
    renoise.app():show_status("No valid instrument/sample/sample buffer.")
    return
  end

  local sample = instrument:sample(sample_index)
  local buffer = sample.sample_buffer
  if not buffer.has_sample_data then
    renoise.app():show_status("Sample buffer is empty.")
    return
  end

  buffer:prepare_sample_data_changes()
  local num_channels = buffer.number_of_channels
  local num_frames = buffer.number_of_frames
  local start_frame, end_frame = 1, num_frames

  -- Find start frame
  for frame = 1, num_frames do
    local is_silent = true
    for channel = 1, num_channels do
      if math.abs(buffer:sample_data(channel, frame)) > threshold then
        is_silent = false
        break
      end
    end
    if not is_silent then
      start_frame = frame
      break
    end
  end

  -- Find end frame
  for frame = num_frames, 1, -1 do
    local is_silent = true
    for channel = 1, num_channels do
      if math.abs(buffer:sample_data(channel, frame)) > threshold then
        is_silent = false
        break
      end
    end
    if not is_silent then
      end_frame = frame
      break
    end
  end

  local new_num_frames = end_frame - start_frame + 1
  if new_num_frames < 1 then
    renoise.app():show_status("No non-silent data found.")
    buffer:finalize_sample_data_changes()
    return
  end

  -- Create a new sample buffer with the trimmed data
  local new_sample = instrument:insert_sample_at(sample_index + 1)
  local new_buffer = new_sample.sample_buffer
  new_buffer:create_sample_data(buffer.sample_rate, buffer.bit_depth, num_channels, new_num_frames)
  new_buffer:prepare_sample_data_changes()

  for frame = 1, new_num_frames do
    for channel = 1, num_channels do
      new_buffer:set_sample_data(channel, frame, buffer:sample_data(channel, start_frame + frame - 1))
    end
  end

  new_buffer:finalize_sample_data_changes()
  buffer:prepare_sample_data_changes()
  buffer:finalize_sample_data_changes()

  -- Copy properties from the old sample to the new sample
  new_sample.name = sample.name
  new_sample.volume = sample.volume
  new_sample.panning = sample.panning
  new_sample.transpose = sample.transpose
  new_sample.fine_tune = sample.fine_tune
  new_sample.beat_sync_enabled = sample.beat_sync_enabled
  new_sample.beat_sync_lines = sample.beat_sync_lines
  new_sample.beat_sync_mode = sample.beat_sync_mode
  new_sample.oneshot = sample.oneshot
  new_sample.loop_release = sample.loop_release
  new_sample.loop_mode = sample.loop_mode
  new_sample.mute_group = sample.mute_group
  new_sample.new_note_action = sample.new_note_action
  new_sample.autoseek = sample.autoseek
  new_sample.autofade = sample.autofade
  new_sample.oversample_enabled = sample.oversample_enabled
  new_sample.interpolation_mode = sample.interpolation_mode

  if sample.loop_start < new_buffer.number_of_frames then
    new_sample.loop_start = sample.loop_start
  end
  if sample.loop_end < new_buffer.number_of_frames then
    new_sample.loop_end = sample.loop_end
  end

  -- Delete the old sample
  instrument:delete_sample_at(sample_index)
  song.selected_sample_index = sample_index

  renoise.app():show_status("Removed Silence from beginning + end of sample at threshold " .. (threshold * 100) .. "%")
end

function PakettiMoveSilence()
  local song = renoise.song()
  local sample_index = song.selected_sample_index
  local instrument = song.selected_instrument
  local threshold = renoise.tool().preferences.PakettiMoveSilenceThreshold.value
  
  if not instrument or sample_index == 0 or not instrument:sample(sample_index) then
    renoise.app():show_status("No valid instrument/sample/sample buffer.")
    return
  end

  local sample = instrument:sample(sample_index)
  local buffer = sample.sample_buffer
  if not buffer.has_sample_data then
    renoise.app():show_status("Sample buffer is empty.")
    return
  end

  buffer:prepare_sample_data_changes()
  local num_channels = buffer.number_of_channels
  local num_frames = buffer.number_of_frames
  local start_frame = 1

  -- Find start frame (end of initial silence)
  for frame = 1, num_frames do
    local is_silent = true
    for channel = 1, num_channels do
      if math.abs(buffer:sample_data(channel, frame)) > threshold then
        is_silent = false
        break
      end
    end
    if not is_silent then
      start_frame = frame
      break
    end
  end

  if start_frame == 1 then
    renoise.app():show_status("No initial silence found.")
    return
  end

  -- Move initial silence to the end
  local new_num_frames = num_frames - start_frame + 1 + start_frame - 1
  local new_sample = instrument:insert_sample_at(sample_index + 1)
  local new_buffer = new_sample.sample_buffer
  new_buffer:create_sample_data(buffer.sample_rate, buffer.bit_depth, num_channels, new_num_frames)
  new_buffer:prepare_sample_data_changes()

  -- Copy non-silent part to the beginning
  for frame = 1, num_frames - start_frame + 1 do
    for channel = 1, num_channels do
      new_buffer:set_sample_data(channel, frame, buffer:sample_data(channel, start_frame + frame - 1))
    end
  end

  -- Copy silent part to the end
  for frame = num_frames - start_frame + 2, new_num_frames do
    for channel = 1, num_channels do
      new_buffer:set_sample_data(channel, frame, 0)
    end
  end

  new_buffer:finalize_sample_data_changes()

  -- Copy properties from the old sample to the new sample
  new_sample.name = sample.name
  new_sample.volume = sample.volume
  new_sample.panning = sample.panning
  new_sample.transpose = sample.transpose
  new_sample.fine_tune = sample.fine_tune
  new_sample.beat_sync_enabled = sample.beat_sync_enabled
  new_sample.beat_sync_lines = sample.beat_sync_lines
  new_sample.beat_sync_mode = sample.beat_sync_mode
  new_sample.oneshot = sample.oneshot
  new_sample.loop_release = sample.loop_release
  new_sample.loop_mode = sample.loop_mode
  new_sample.mute_group = sample.mute_group
  new_sample.new_note_action = sample.new_note_action
  new_sample.autoseek = sample.autoseek
  new_sample.autofade = sample.autofade
  new_sample.oversample_enabled = sample.oversample_enabled
  new_sample.interpolation_mode = sample.interpolation_mode

  if sample.loop_start < new_buffer.number_of_frames then
    new_sample.loop_start = sample.loop_start
  end
  if sample.loop_end < new_buffer.number_of_frames then
    new_sample.loop_end = sample.loop_end
  end

  -- Delete the old sample
  instrument:delete_sample_at(sample_index)
  song.selected_sample_index = sample_index

  renoise.app():show_status("Moved beginning silence to the end of the sample.")
end


renoise.tool():add_keybinding{name="Global:Paketti:Strip Silence",invoke=function() PakettiStripSilence() end}
renoise.tool():add_midi_mapping{name="Paketti:Strip Silence",invoke=function() PakettiStripSilence() end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Strip Silence",invoke=function() PakettiStripSilence() end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Strip Silence",invoke=function() PakettiStripSilence() end}
renoise.tool():add_keybinding{name="Global:Paketti:Move Beginning Silence to End",invoke=function() PakettiMoveSilence() end}
renoise.tool():add_midi_mapping{name="Paketti:Move Beginning Silence to End",invoke=function(message) if message:is_trigger() then  PakettiMoveSilence() end end}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Move Beginning Silence to End",invoke=function() PakettiMoveSilence() end}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Move Beginning Silence to End",invoke=function() PakettiMoveSilence() end}

function apply_fade_in_out()
  local instrument=renoise.song().selected_instrument
  if not instrument or #instrument.samples==0 then return end

  local sample=instrument.samples[renoise.song().selected_sample_index]
  local buffer=sample.sample_buffer
  if not buffer or not buffer.has_sample_data then return end
renoise.song().selected_sample.sample_buffer:prepare_sample_data_changes()
  local frames=buffer.number_of_frames
  if frames<=30 then return end

  -- Apply Fade-In
  for i=1,15 do
    local fade_in_factor=i/15
    for ch=1,buffer.number_of_channels do
      local sample_value=buffer:sample_data(ch,i)
      buffer:set_sample_data(ch,i,sample_value*fade_in_factor)
    end
  end

  -- Apply Fade-Out
  for i=frames-14,frames do
    local fade_out_factor=(frames-i+1)/15
    for ch=1,buffer.number_of_channels do
      local sample_value=buffer:sample_data(ch,i)
      buffer:set_sample_data(ch,i,sample_value*fade_out_factor)
    end
  end
renoise.song().selected_sample.sample_buffer:finalize_sample_data_changes()
  renoise.app():show_status("15-frame fade-in and fade-out applied")
end

renoise.tool():add_keybinding {name="Sample Editor:Paketti:15 Frame Fade In & Fade Out",invoke=function() apply_fade_in_out() end}
renoise.tool():add_menu_entry {name="Sample Editor:Paketti..:15 Frame Fade In & Fade Out",invoke=function() apply_fade_in_out() end}

---
-- Function to create max amplitude DC offset kick
function pakettiMaxAmplitudeDCOffsetKickCreator()
  -- Insert a new instrument after the currently selected one
  local selected_index = renoise.song().selected_instrument_index
  local new_instrument_index = selected_index + 1
  
  renoise.song():insert_instrument_at(new_instrument_index)
  renoise.song().selected_instrument_index = new_instrument_index

  -- Insert a sample into the newly created instrument
  local sample = renoise.song().instruments[new_instrument_index]:insert_sample_at(1)
  sample.sample_buffer:create_sample_data(44100, 16, 1, 16800)

  -- Access the sample buffer
  local buffer = sample.sample_buffer

  -- Make sure the sample buffer is loaded and ready
  if buffer.has_sample_data then
    -- Fill the buffer with maximum amplitude values
    for frame = 1, buffer.number_of_frames do
      buffer:set_sample_data(1, frame, 32767 / 32768) -- Max normalized value for 16-bit
    end

    -- Run recursive DC offset removal simulation (example)
    local iterations = math.random(1, 50)
    for i = 1, iterations do
      remove_dc_offset_recursive()
    end
  end
    renoise.song().selected_sample.name="Max Amp DC Offset Kick"
    renoise.song().selected_instrument.name="Max Amp DC Offset Kick"
renoise.app().window.active_middle_frame=5
  
  renoise.app():show_status("Max Amp DC Offset Kick Generated!")
end

-- Adding keybinding and menu entry on single lines
renoise.tool():add_keybinding { name="Global:Paketti:Max Amp DC Offset Kick Generator", invoke=function() pakettiMaxAmplitudeDCOffsetKickCreator() end }
renoise.tool():add_menu_entry { name="Sample Editor:Paketti..:Max Amp DC Offset Kick Generator", invoke=function() pakettiMaxAmplitudeDCOffsetKickCreator() end }

-- Function to apply the recursive DC offset correction algorithm
function remove_dc_offset_recursive()
  local sample_buffer = renoise.song().selected_sample.sample_buffer

  if not sample_buffer.has_sample_data then
    renoise.app():show_status("No sample data found.")
    return
  end

  -- Calculate the R value
  local samplerate = sample_buffer.sample_rate
  local R

  -- Choose an R value based on the desired cutoff frequency
  -- (-3dB @ 40Hz) 
  R = 1 - (250 / samplerate)
  -- Alternative values for lower cutoff frequencies:
  -- (-3dB @ 30Hz): R = 1 - (190 / samplerate)
  -- (-3dB @ 20Hz):   R = 1 - (126 / samplerate)

  local new_data = {}

  for ch = 1, sample_buffer.number_of_channels do
    new_data[1] = sample_buffer:sample_data(ch, 1)

    for i = 2, sample_buffer.number_of_frames do
      local current_value = sample_buffer:sample_data(ch, i)
      local previous_value = sample_buffer:sample_data(ch, i - 1)
      new_data[i] = current_value - previous_value + R * new_data[i - 1]
    end

    sample_buffer:prepare_sample_data_changes()

    for i = 1, sample_buffer.number_of_frames do
      sample_buffer:set_sample_data(ch, i, new_data[i])
    end

    sample_buffer:finalize_sample_data_changes()
  end

  renoise.app():show_status("Recursive DC Offset correction applied successfully.")
end

renoise.tool():add_keybinding {name = "Sample Editor:Process:Recursive Remove DC Offset", invoke = function() remove_dc_offset_recursive() end}

function remove_dc_offset_recursive_1to50()
local iterations = math.random(1, 50)
for i = 1, iterations do
  remove_dc_offset_recursive()
end
  renoise.app():show_status("Ran Recursive DC Offset " .. iterations .. " times.")
end

renoise.tool():add_keybinding{name="Sample Editor:Process:Recursive Remove DC Offset Random Times",invoke=function() remove_dc_offset_recursive_1to50() end}
---------------

function Paketti_Diagonal_Line_to_Sample()
  local selected_instrument_index = renoise.song().selected_instrument_index
  local new_instrument_index = math.max(1, selected_instrument_index - 1)
  renoise.song():insert_instrument_at(new_instrument_index)
  renoise.song().selected_instrument_index = new_instrument_index

  local new_instrument = renoise.song().instruments[new_instrument_index]
  local sample = new_instrument:insert_sample_at(1)

  sample.sample_buffer:create_sample_data(44100, 16, 1, 16800)

  local buffer = sample.sample_buffer
  buffer:prepare_sample_data_changes()

  for i=1, buffer.number_of_frames do
    local value = 1.0 - (2.0 * (i - 1) / (buffer.number_of_frames - 1))
    buffer:set_sample_data(1, i, value)
  end

  buffer:finalize_sample_data_changes()
  renoise.app():show_status("Paketti Diagonal Line to Sample created successfully.")
end

renoise.tool():add_keybinding{name="Global:Paketti:Diagonal Line to 16800 length Sample",invoke=function() Paketti_Diagonal_Line_to_Sample() end}

function normalize_selected_sample()
  local selected_sample = renoise.song().selected_sample
  
  if selected_sample.is_slice_alias then
    selected_sample = renoise.song().selected_instrument:sample(1)
  end
  
  if not selected_sample or not selected_sample.sample_buffer or not selected_sample.sample_buffer.has_sample_data then
    renoise.app():show_status("Normalization failed: No valid sample to normalize.")
    return
  end

  local sbuf = selected_sample.sample_buffer
  
  local highest_detected = 0
  
  for frame_idx = 1, sbuf.number_of_frames do
    if sbuf.number_of_channels == 2 then
      highest_detected = math.max(math.abs(sbuf:sample_data(1, frame_idx)), highest_detected)
      highest_detected = math.max(math.abs(sbuf:sample_data(2, frame_idx)), highest_detected)
    else
      highest_detected = math.max(math.abs(sbuf:sample_data(1, frame_idx)), highest_detected)
    end
  end
  
  if highest_detected == 0 then
    renoise.app():show_status("Sample is absolute silence, nothing to normalize.")
    return
  end
  
  sbuf:prepare_sample_data_changes()
  
  for frame_idx = 1, sbuf.number_of_frames do
    if sbuf.number_of_channels == 2 then
      local normalized_sdata = sbuf:sample_data(1, frame_idx) / highest_detected
      sbuf:set_sample_data(1, frame_idx, normalized_sdata)
      normalized_sdata = sbuf:sample_data(2, frame_idx) / highest_detected
      sbuf:set_sample_data(2, frame_idx, normalized_sdata)
    else
      local normalized_sdata = sbuf:sample_data(1, frame_idx) / highest_detected
      sbuf:set_sample_data(1, frame_idx, normalized_sdata)
    end
  end
  
  sbuf:finalize_sample_data_changes()
  
  if sbuf.has_sample_data then
    renoise.app():show_status("Sample successfully normalized (maximized volume).")
  else
    renoise.app():show_status("Normalization failed.")
  end
end

renoise.tool():add_keybinding{name="Global:Paketti:Paketti Normalize Sample",invoke=function() normalize_selected_sample() end}


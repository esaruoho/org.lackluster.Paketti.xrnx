-- Initialize ViewBuilder
local vb = renoise.ViewBuilder()

-- Declare global variables
local dialog = nil
local rows = {}
local track_names = {}
local track_indices = {}
local instrument_names = {}
local play_checkbox = nil
local follow_checkbox = nil
local bpm_display = nil
local groove_enabled_checkbox = nil
local random_gate_button = nil
local fill_empty_label = nil
local fill_empty_slider = nil
local global_step_buttons = nil
local global_controls = nil

-- Function to set global steps across all rows
local function set_global_steps(steps)
  for _, row_elements in ipairs(rows) do
    row_elements.updating_steps = true  -- Prevent notifier from triggering
    row_elements.valuebox.value = steps
    row_elements.updating_steps = false
    row_elements.print_to_pattern()
  end
  renoise.app():show_status("All step counts set to " .. tostring(steps) .. ".")
end

-- Function to implement Random Gate
local function random_gate()
  -- For each checkbox position (1 to 16)
  for i = 1, 16 do
    -- Randomly select one of the 8 rows
    local selected_row = math.random(1, #rows)
    -- Set the selected checkbox to true, others to false
    for row_index, row_elements in ipairs(rows) do
      row_elements.checkboxes[i].value = (row_index == selected_row)
    end
  end
  -- Update all patterns
  for _, row_elements in ipairs(rows) do
    row_elements.print_to_pattern()
  end
  renoise.app().window.active_middle_frame = 1  -- Focus frame 1 as per your requirement
end

-- Function to fill empty steps randomly
local function fill_empty_steps(probability)
  for _, row_elements in ipairs(rows) do
    local checkboxes = row_elements.checkboxes
    for i = 1, 16 do
      if not checkboxes[i].value then
        if math.random() < probability then
          checkboxes[i].value = true
        end
      end
    end
    row_elements.print_to_pattern()
  end
  renoise.app().window.active_middle_frame = 1  -- Focus frame 1 as per your requirement
end

-- Key Handler for Dialog
local function PakettiEightSlotsByOneTwentyKeyHandler(dialog, key)
  local closer = preferences.pakettiDialogClose.value
  if key.modifiers == "" and key.name == closer then
    dialog:close()
    dialog = nil
    rows = {}
    return nil
  else
    return key
  end
end

-- Function to update instrument list and popups
local function update_instrument_list_and_popups()
  instrument_names = {}
  for i, instr in ipairs(renoise.song().instruments) do
    table.insert(instrument_names, instr.name ~= "" and instr.name or "Instrument " .. i)
  end

  for i, row_elements in ipairs(rows) do
    local instrument_popup = row_elements.instrument_popup
    local previous_value = instrument_popup.value

    instrument_popup.items = instrument_names

    if previous_value <= #instrument_names then
      instrument_popup.value = previous_value
    else
      instrument_popup.value = 1
    end
  end
end

-- Function to create a single row
local function PakettiEightSlotsByOneTwentyCreateRow(row_index)
  local row_elements = {}

  preferences.PakettiEightSlotsByOneTwenty = preferences.PakettiEightSlotsByOneTwenty or {}
  local row_prefs = preferences.PakettiEightSlotsByOneTwenty[row_index] or {}
  preferences.PakettiEightSlotsByOneTwenty[row_index] = row_prefs

  -- Colors for buttons
  local normal_color = nil
  local highlight_color = { 0x22 / 255, 0xaa / 255, 0xff / 255 } -- Custom highlight color for specific buttons

  -- Numbered Buttons (for display)
  local number_buttons = {}
  for i = 1, 16 do
    local is_highlight = (i == 1 or i == 5 or i == 9 or i == 13)
    number_buttons[i] = vb:button {
      text = string.format("%02d", i),
      width = 30,
      color = is_highlight and highlight_color or normal_color,
      notifier = function() end,  -- No action needed
      active = false,  -- Make buttons non-clickable
    }
  end

  -- Create Checkboxes
  local checkboxes = {}
  for i = 1, 16 do
    checkboxes[i] = vb:checkbox {
      value = false,
      width = 30,
      notifier = function()
        row_elements.print_to_pattern()
        renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
      end
    }
  end

  -- Create Popups and Controls
  local track_popup = vb:popup {
    items = track_names,
    value = row_prefs.track_value or row_index,  -- Load from preferences or default to row_index
    notifier = function(value)
      row_prefs.track_value = value
      row_elements.initialize_row()
    end
  }

  -- Mute/Unmute Checkbox with minimized text width
  local mute_checkbox = vb:checkbox {
    value = false,  -- Will be set in initialize_row()
    notifier = function(value)
      -- Save to preferences
      row_prefs.mute_value = value

      -- Mute or unmute the track immediately
      local track_index = track_indices[track_popup.value]
      local track = renoise.song().tracks[track_index]
      track.mute_state = value and renoise.Track.MUTE_STATE_MUTED or renoise.Track.MUTE_STATE_ACTIVE
      renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
    end
  }

  -- Valuebox for Steps without "Steps:" label
  local valuebox = vb:valuebox {
    min = 1,
    max = 16,
    value = 16,
    width = 50,  -- Adjusted width to 50
    notifier = function(value)
      if not row_elements.updating_steps then
        row_elements.print_to_pattern()
        renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
      end
    end
  }

  -- Slider for Sample Selection
  local slider = vb:slider {
    min = 1,
    max = 120,
    value = 1,
    width = 100,
    notifier = function(value)
      -- Select the instrument defined in instrument_popup
      local instrument_index = row_elements.instrument_popup.value
      renoise.song().selected_instrument_index = instrument_index
      -- Assuming midi_sample_velocity_switcharoo is defined elsewhere
      if type(midi_sample_velocity_switcharoo) == "function" then
        midi_sample_velocity_switcharoo(value)
      end
      row_elements.update_sample_name_label()
      renoise.app().window.active_middle_frame = 5  -- Focus Sample Editor
    end
  }

  -- Sample Name Label
  local sample_name_label = vb:text { text = "Sample Name", font = "bold", style = "strong" }

  -- Instrument Popup with increased width
  local instrument_popup = vb:popup {
    items = instrument_names,
    value = row_prefs.instrument_value or row_index,  -- Load from preferences or default to row_index
    width = 150,  -- Increased width
    notifier = function(value)
      row_prefs.instrument_value = value
      row_elements.print_to_pattern()
      row_elements.update_sample_name_label()
      renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
    end
  }

  -- Function to print to pattern for this row
  local function print_to_pattern()
    -- Efficiently write notes to the pattern

    -- Get the pattern and its length
    local song = renoise.song()
    local pattern = song.selected_pattern
    local pattern_length = pattern.number_of_lines

    local steps = valuebox.value
    local track_index = track_indices[track_popup.value]
    local instrument_index = instrument_popup.value

    -- Write note data to the first 'steps' lines based on the checkboxes
    local track_in_pattern = pattern.tracks[track_index]

    -- Write notes based on checkboxes
    for line = 1, steps do
      local checkbox_value = checkboxes[line].value
      local note_line = track_in_pattern:line(line).note_columns[1]

      if checkbox_value then
        note_line.note_string = "C-4"
        note_line.instrument_value = instrument_index - 1
      else
        note_line:clear()
      end
    end

    -- Replicate the initial 'steps' lines throughout the rest of the pattern
    for line = steps + 1, pattern_length do
      local source_line_index = ((line - 1) % steps) + 1
      local source_note_line = track_in_pattern:line(source_line_index).note_columns[1]
      local dest_note_line = track_in_pattern:line(line).note_columns[1]

      dest_note_line:copy_from(source_note_line)
    end
  end

  -- Function to update sample name label
  local function update_sample_name_label()
    local instrument = renoise.song().instruments[instrument_popup.value]
    local sample_index = math.floor(slider.value)
    if instrument.samples[sample_index] then
      local sample = instrument.samples[sample_index]
      if sample.name ~= "" then
        sample_name_label.text = sample.name
      else
        sample_name_label.text = "Sample " .. sample_index
      end
    else
      sample_name_label.text = "No sample"
    end
  end

  -- Function to initialize the row (populate checkboxes and set mute state)
  local function initialize_row()
    -- Populate checkboxes
    local track_index = track_indices[track_popup.value]
    local track = renoise.song().tracks[track_index]
    local pattern = renoise.song().selected_pattern
    local line_count = pattern.number_of_lines

    -- Temporarily disable checkboxes during initialization
    for i = 1, 16 do
      checkboxes[i].active = false
      checkboxes[i].value = false
    end

    for line = 1, math.min(line_count, 16) do
      local note_line = pattern.tracks[track_index].lines[line].note_columns[1]
      if note_line and note_line.note_string == "C-4" then
        checkboxes[line].value = true
      end
    end

    local mute = track.mute_state == renoise.Track.MUTE_STATE_MUTED
    mute_checkbox.value = mute

    -- Determine the instrument used and set instrument_popup.value
    local instrument_used = nil
    for line = 1, math.min(line_count, 16) do
      local note_line = pattern.tracks[track_index].lines[line].note_columns[1]
      if note_line and not note_line.is_empty and note_line.note_string ~= '---' then
        instrument_used = note_line.instrument_value
        break
      end
    end

    if instrument_used then instrument_popup.value = instrument_used + 1 end
    update_sample_name_label()

    -- Re-enable checkboxes after initialization
    for i = 1, 16 do
      checkboxes[i].active = true
    end
  end

  -- Browse Function
  local function browse_instrument()
    renoise.song().selected_track_index = 1  -- Set selected_track_index to 1
    renoise.song().selected_instrument_index = instrument_popup.value
    -- Assuming pitchBendDrumkitLoader is defined elsewhere
    if type(pitchBendDrumkitLoader) == "function" then
      pitchBendDrumkitLoader()
    end
    --local instrument = renoise.song().instruments[instrument_popup.value]
    local instrument=renoise.song().selected_instrument
    for _, sample in ipairs(instrument.samples) do
      sample.sample_mapping.base_note = 48  -- C-4
      sample.sample_mapping.note_range = { 0, 119 }
    end
    renoise.app():show_status("Base notes set to C-4 and key mapping adjusted for all samples.")
    update_instrument_list_and_popups()  -- Refresh instruments
    slider.value = 1  -- Set slider to minimum (first sample gets 00-7F)
    update_sample_name_label()
    renoise.app().window.active_middle_frame = 5  -- Focus Sample Editor
  end

  -- Refresh Instruments Function
  local function refresh_instruments()
    update_instrument_list_and_popups()
    renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
  end

  -- Select Button Functionality
  local function select_instrument()
      renoise.song().selected_instrument_index = instrument_popup.value
      renoise.app().window.active_middle_frame = 5  -- Focus Sample Editor
  end

  -- Random Button Functionality
  local function random_button_pressed()
    -- Select the instrument defined in instrument_popup
    local instrument_index = instrument_popup.value
    renoise.song().selected_instrument_index = instrument_index

    -- Assuming sample_random is defined elsewhere
    if type(sample_random) == "function" then
      sample_random()
    end

    -- Find the sample that has key range 0-127 and set slider to that sample index
    local instrument = renoise.song().instruments[instrument_index]
    for sample_index, sample in ipairs(instrument.samples) do
      if sample.sample_mapping.note_range[1] == 0 and sample.sample_mapping.note_range[2] == 127 then
        slider.value = sample_index
        break
      end
    end

    -- Update sample name label
    update_sample_name_label()

    -- Select the first track
    renoise.song().selected_track_index = 1

    -- Focus frame 1 as per your requirement
    renoise.app().window.active_middle_frame = 5
  end

  -- Assemble the row with control buttons, including row-specific < and > buttons
  local row = vb:column {
    vb:row(number_buttons),
    vb:row {
      checkboxes[1], checkboxes[2], checkboxes[3], checkboxes[4],
      checkboxes[5], checkboxes[6], checkboxes[7], checkboxes[8],
      checkboxes[9], checkboxes[10], checkboxes[11], checkboxes[12],
      checkboxes[13], checkboxes[14], checkboxes[15], checkboxes[16],
      valuebox,
      sample_name_label
    },
    vb:row {
      vb:button { text = "<", notifier = function()
        -- Shift checkboxes left in this specific row
        local first_value = checkboxes[1].value
        for i = 1, 15 do
          checkboxes[i].value = checkboxes[i + 1].value
        end
        checkboxes[16].value = first_value
        print_to_pattern()
        renoise.app().window.active_middle_frame = 1  -- Focus frame 1
      end },
      vb:button { text = ">", notifier = function()
        -- Shift checkboxes right in this specific row
        local last_value = checkboxes[16].value
        for i = 16, 2, -1 do
          checkboxes[i].value = checkboxes[i - 1].value
        end
        checkboxes[1].value = last_value
        print_to_pattern()
        renoise.app().window.active_middle_frame = 1  -- Focus frame 1
      end },
      vb:button { text = "Clear", notifier = function()
        for i = 1, 16 do
          checkboxes[i].value = false
        end
        row_elements.print_to_pattern()
        renoise.app().window.active_middle_frame = 1  -- Focus frame 1
      end },
      vb:button { text = "Randomize", notifier = function()
        for i = 1, 16 do
          checkboxes[i].value = math.random() >= 0.5
        end
        row_elements.print_to_pattern()
        renoise.app().window.active_middle_frame = 1  -- Focus frame 1
      end },
      track_popup,
      vb:row {  -- Group Mute Checkbox and Label closely
        mute_checkbox,
        vb:text { text = "Mute", font = "bold", style = "strong", width = 30 },
      },
      instrument_popup,
      vb:button { text = "Browse", notifier = browse_instrument },
      vb:button { text = "Refresh", notifier = refresh_instruments },
      vb:button { text = "Select", notifier = select_instrument },
      slider,
      vb:button { text = "Random", notifier = random_button_pressed },
    },
  }

  -- Store elements for later use
  row_elements.checkboxes = checkboxes
  row_elements.valuebox = valuebox
  row_elements.slider = slider
  row_elements.track_popup = track_popup
  row_elements.instrument_popup = instrument_popup
  row_elements.mute_checkbox = mute_checkbox
  row_elements.initialize_row = initialize_row  -- Store initialize_row function
  row_elements.print_to_pattern = print_to_pattern  -- Store print_to_pattern function
  row_elements.update_sample_name_label = update_sample_name_label  -- Store update_sample_name_label function

  -- Initialize the row (populate checkboxes and set mute state)
  initialize_row()

  return row, row_elements
end

-- Function to create global controls at the top
local function create_global_controls()
  -- Groove Enabled Checkbox
  play_checkbox = vb:checkbox {
    value = renoise.song().transport.playing,
    notifier = function(value)
      if value then
        renoise.song().transport:start(renoise.Transport.PLAYMODE_RESTART_PATTERN)
      else
        renoise.song().transport:stop()
      end
      renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
    end
  }
  follow_checkbox = vb:checkbox {
    value = renoise.song().transport.follow_player,
    notifier = function(value)
      renoise.song().transport.follow_player = value
      renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
    end
  }


  groove_enabled_checkbox = vb:checkbox {
    value = renoise.song().transport.groove_enabled,
    notifier = function(value)
      renoise.song().transport.groove_enabled = value
      renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
    end
  }

  -- Play Checkbox
  play_checkbox = vb:checkbox {
    value = renoise.song().transport.playing,
    notifier = function(value)
      if value then
        renoise.song().transport:start(renoise.Transport.PLAYMODE_RESTART_PATTERN)
      else
        renoise.song().transport:stop()
      end
      renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
    end
  }

  -- Follow Checkbox
  follow_checkbox = vb:checkbox {
    value = renoise.song().transport.follow_player,
    notifier = function(value)
      renoise.song().transport.follow_player = value
      renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
    end
  }

  -- BPM Display
  bpm_display = vb:text {
    text = "BPM: " .. tostring(renoise.song().transport.bpm),
    font = "bold",
    style = "strong",
    width = 20,
  }

  -- Function to increase BPM
  local function increase_bpm()
    renoise.song().transport.bpm = renoise.song().transport.bpm + 1
    bpm_display.text = "BPM: " .. tostring(renoise.song().transport.bpm)
    renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
  end

  -- Function to decrease BPM
  local function decrease_bpm()
    renoise.song().transport.bpm = renoise.song().transport.bpm - 1
    bpm_display.text = "BPM: " .. tostring(renoise.song().transport.bpm)
    renoise.app().window.active_middle_frame = renoise.app().window.active_middle_frame
  end

  -- Groove Sliders and Labels
  local local_groove_sliders = {}
  local local_groove_labels = {}
  local groove_controls = vb:row {}

  for i = 1, 4 do
    local groove_value = renoise.song().transport.groove_amounts[i] or 0
    local_groove_labels[i] = vb:text {
      text = string.format("%d%%", groove_value * 100),
      width = 30,
    }
    local_groove_sliders[i] = vb:slider {
      min = 0.0,
      max = 1.0,
      value = groove_value,
      width = 100,
      notifier = function(value)
        local_groove_labels[i].text = string.format("%d%%", value * 100)
        -- Collect all groove values
        local groove_values = {}
        for j = 1, 4 do
          groove_values[j] = local_groove_sliders[j].value
        end
        -- Set groove_amounts to the array of groove_values
        renoise.song().transport.groove_amounts = groove_values
    renoise.song().selected_track_index = renoise.song().sequencer_track_count+1
    renoise.app().window.active_middle_frame = 2
      end
    }
    groove_controls:add_child(vb:row { local_groove_sliders[i], local_groove_labels[i] })
  end

  -- Random Groove Function
  local function randomize_groove()
    local groove_values = {}
    for i = 1, 4 do
      local random_value = math.random()
      local_groove_sliders[i].value = random_value
      local_groove_labels[i].text = string.format("%d%%", random_value * 100)
      groove_values[i] = random_value
    end
    renoise.song().transport.groove_amounts = groove_values
    renoise.song().transport.groove_enabled = true
    renoise.song().selected_track_index = renoise.song().sequencer_track_count+1
    renoise.app().window.active_middle_frame = 2
  end

  -- Random Groove Button
  local random_groove_button = vb:button{text="Random Groove",notifier=randomize_groove}

  -- Create Global Steps with << and >>
  global_step_buttons = vb:row {
    vb:text { text = "Global Steps:", font = "bold", style = "strong", width = 100 },
    vb:button { text = "1", notifier = function() set_global_steps(1) end },
    vb:button { text = "2", notifier = function() set_global_steps(2) end },
    vb:button { text = "4", notifier = function() set_global_steps(4) end },
    vb:button { text = "6", notifier = function() set_global_steps(6) end },
    vb:button { text = "8", notifier = function() set_global_steps(8) end },
    vb:button { text = "12", notifier = function() set_global_steps(12) end },
    vb:button { text = "16", notifier = function() set_global_steps(16) end },
    vb:button { text = "<<", notifier = function() 
      -- Shift all checkboxes left across all rows
      for _, row_elements in ipairs(rows) do
        local first_value = row_elements.checkboxes[1].value
        for i = 1, 15 do
          row_elements.checkboxes[i].value = row_elements.checkboxes[i + 1].value
        end
        row_elements.checkboxes[16].value = first_value
        row_elements.print_to_pattern()
      end
      renoise.app().window.active_middle_frame = 1  -- Focus frame 1
    end },
    vb:button { text = ">>", notifier = function() 
      -- Shift all checkboxes right across all rows
      for _, row_elements in ipairs(rows) do
        local last_value = row_elements.checkboxes[16].value
        for i = 16, 2, -1 do
          row_elements.checkboxes[i].value = row_elements.checkboxes[i - 1].value
        end
        row_elements.checkboxes[1].value = last_value
        row_elements.print_to_pattern()
      end
      renoise.app().window.active_middle_frame = 1  -- Focus frame 1
    end },
  }

  -- Random Gate Button
  random_gate_button = vb:button {
    text = "Random Gate",
    notifier = function()
      random_gate()
      renoise.app().window.active_middle_frame = 1  -- Focus frame 1 as per your requirement
    end
  }

  -- Fill Empty Steps Randomly Slider
  fill_empty_label=vb:text{text="Fill Empty Steps: 0%",width=90}

  fill_empty_slider = vb:slider {
    min = 0,
    max = 100,
    value = 0,
    width = 150,
    notifier = function(value)
      fill_empty_label.text = "Fill Empty Steps: " .. tostring(math.floor(value)) .. "%"
      if value == 0 then
        -- Run Clear All script
        for _, row_elements in ipairs(rows) do
          for i = 1, 16 do
            row_elements.checkboxes[i].value = false
          end
          row_elements.print_to_pattern()
        end
        renoise.app().window.active_middle_frame = 1  -- Focus frame 1
      else
        fill_empty_steps(value / 100)  -- Call the fill_empty_steps function
        renoise.app().window.active_middle_frame = 1  -- Keep focus on frame 1
      end
    end
  }

  -- Clear All Button Functionality
  local function clear_all()
    for _, row_elements in ipairs(rows) do
      local checkboxes = row_elements.checkboxes
      for i = 1, 16 do
        checkboxes[i].value = false
      end
      row_elements.print_to_pattern()
    end
    renoise.app().window.active_middle_frame = 1  -- Focus frame 1
  end

  -- Random Fill Button Functionality
  local function random_fill()
    for _, row_elements in ipairs(rows) do
      -- Set the steps to a random number between 1 and 16
      local random_steps = math.random(1, 16)
      row_elements.updating_steps = true  -- Prevent notifier from triggering
      row_elements.valuebox.value = random_steps
      row_elements.updating_steps = false
      -- Clear checkboxes
      local checkboxes = row_elements.checkboxes
      for i = 1, 16 do
        checkboxes[i].value = false
      end
      -- Fill random checkboxes up to random_steps
      for i = 1, random_steps do
        local rand_index = math.random(1, 16)
        checkboxes[rand_index].value = true
      end
      row_elements.print_to_pattern()
    end
    renoise.app().window.active_middle_frame = 1  -- Focus frame 1
  end

  -- Fetch Button Functionality
  local function fetch_pattern()
    -- Disable all checkboxes to prevent interaction during fetching
    for _, row_elements in ipairs(rows) do
      for _, checkbox in ipairs(row_elements.checkboxes) do
        checkbox.active = false
      end
    end

    -- Iterate through each row and fetch the pattern content
    for i, row_elements in ipairs(rows) do
      local track_index = track_indices[row_elements.track_popup.value]
      local pattern = renoise.song().selected_pattern
      local line_count = pattern.number_of_lines
      local instrument_used = nil

      for line = 1, math.min(line_count, 16) do
        local note_line = pattern.tracks[track_index].lines[line].note_columns[1]
        if note_line and note_line.note_string == "C-4" then
          row_elements.checkboxes[line].value = true
          if not instrument_used and not note_line.is_empty then
            instrument_used = note_line.instrument_value
          end
        else
          row_elements.checkboxes[line].value = false
        end
      end

      if instrument_used then
        row_elements.instrument_popup.value = instrument_used + 1
        renoise.song().selected_instrument_index = row_elements.instrument_popup.value
      end
      row_elements.print_to_pattern()
    end

    -- Re-enable all checkboxes after fetching
    for _, row_elements in ipairs(rows) do
      for _, checkbox in ipairs(row_elements.checkboxes) do
        checkbox.active = true
      end
    end

    renoise.app():show_status("Pattern fetched successfully.")
    renoise.app().window.active_middle_frame = 1  -- Focus frame 1 as per your requirement
  end

  -- Create Global Controls Layout
  local global_controls = vb:column {
    vb:row {
        play_checkbox,
           vb:text { text = "Play", font = "bold", style = "strong", width = 20 },
        follow_checkbox,
        vb:text { text = "Follow", font = "bold", style = "strong", width = 30 },
    
      vb:button { text = "-", notifier = decrease_bpm },
      bpm_display,
      vb:button { text = "+", notifier = increase_bpm },
      vb:button { text = "Clear All", notifier = clear_all },
      vb:button { text = "Random Fill", notifier = random_fill },
      random_gate_button,
      vb:button { text = "Fetch", notifier = fetch_pattern },
      fill_empty_label,
      fill_empty_slider
    },
  }

  -- Create Global Groove Controls
  local global_groove_controls = vb:row {
    groove_enabled_checkbox,
    vb:text { text = "Global Groove", font = "bold", style = "strong", width = 100 },
    groove_controls,
    random_groove_button
  }

  return global_controls, global_groove_controls, global_step_buttons
end

-- Function to create and show the dialog
local function PakettiEightSlotsByOneTwentyDialog()
  -- Ensure dialog is not already open
  if dialog and dialog.visible then
    dialog:show()
    return
  end

  -- Populate track and instrument names
  track_names = {}
  track_indices = {}
  for i, track in ipairs(renoise.song().tracks) do
    if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
      table.insert(track_names, track.name)
      table.insert(track_indices, i)
    end
  end

  instrument_names = {}
  for i, instr in ipairs(renoise.song().instruments) do
    table.insert(instrument_names, instr.name ~= "" and instr.name or "Instrument " .. i)
  end

  -- Create global controls and groove controls fresh each time
  local global_controls, global_groove_controls, global_step_buttons = create_global_controls()

  -- Create a fresh dialog content column
  local dc = vb:column {
    global_controls,
    global_groove_controls,
    global_step_buttons
  }

  -- Create 8 rows
  for i = 1, 8 do
    local row, elements = PakettiEightSlotsByOneTwentyCreateRow(i)
    dc:add_child(row)
    rows[i] = elements  -- Store the row elements for updating later
  end

  -- Add "Print to Pattern" button
  dc:add_child(
    vb:button {
      text = "Print to Pattern",
      notifier = function()
        for i, elements in ipairs(rows) do
          elements.print_to_pattern()
        end
        renoise.app():show_status("Pattern updated successfully.")
        renoise.app().window.active_middle_frame = 1  -- Focus frame 1 as per your requirement
      end
    }
  )

  -- Show the dialog
  dialog = renoise.app():show_custom_dialog(
    "Eight Slots by 120 Samples",
    dc,
    PakettiEightSlotsByOneTwentyKeyHandler
  )
end

-- Add Keybinding to toggle the dialog
renoise.tool():add_keybinding {
  name = "Global:Paketti:Eight Slots by 120 Samples",
  invoke = function()
    if dialog and dialog.visible then
      dialog:close()
      dialog = nil
      rows = {}
    else
      PakettiEightSlotsByOneTwentyDialog()
    end
  end
}


local vb = renoise.ViewBuilder()
local dialog = nil

local set_to_selected_instrument = preferences.OctaMEDPickPutSlots.SetSelectedInstrument.value or false
local use_edit_step_for_put = preferences.OctaMEDPickPutSlots.UseEditStep.value or false
local randomize_enabled = preferences.OctaMEDPickPutSlots.RandomizeEnabled.value or false
local randomize_percentage = preferences.OctaMEDPickPutSlots.RandomizePercentage.value or 100

-- Function to update the textfield display for empty slots
local function check_and_update_slot_display(slot_index)
  local textfield_value = vb.views["slot_display_"..string.format("%02d", slot_index)].text
  -- If the textfield only contains ' || ' or is empty, set it to "Slot is Empty"
  if textfield_value == " || " or textfield_value == "" then
    vb.views["slot_display_"..string.format("%02d", slot_index)].text = "Slot " .. string.format("%02d", slot_index) .. ": Empty"
  end
end

-- Function to save the picked slot data to preferences
local function save_slot_to_preferences(slot_index)
  local slot_key = "Slot" .. string.format("%02d", slot_index)
  local slot_text = vb.views["slot_display_"..string.format("%02d", slot_index)].text

  -- Ensure slot data is properly saved if the slot is not empty
  if slot_text ~= "Slot " .. string.format("%02d", slot_index) .. ": Empty" and slot_text ~= "" then
    print("Saving Slot", slot_index, "to preferences:", slot_text)
    preferences.OctaMEDPickPutSlots[slot_key].value = slot_text
  end

  -- Save the preferences document
  renoise.tool().preferences:save_as("preferences.xml")
end

-- Helper function to split a string by a given delimiter
local function string_split(input_str, delimiter)
  local result = {}
  for match in (input_str .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

-- Function to save checkbox preferences
local function save_checkbox_preference()
  preferences.OctaMEDPickPutSlots.SetSelectedInstrument.value = set_to_selected_instrument
  preferences.OctaMEDPickPutSlots.UseEditStep.value = use_edit_step_for_put
  preferences.OctaMEDPickPutSlots.RandomizeEnabled.value = randomize_enabled
  preferences.OctaMEDPickPutSlots.RandomizePercentage.value = randomize_percentage
  renoise.tool().preferences:save_as("preferences.xml")
end

-- Call this function after loading from preferences
local function load_slots_from_preferences()
  for i = 1, 10 do
    local slot_key = "Slot" .. string.format("%02d", i)
    local saved_slot_data = preferences.OctaMEDPickPutSlots[slot_key].value

    if saved_slot_data ~= "" then
      print("Loading Slot", i, "from preferences:", saved_slot_data)
      vb.views["slot_display_"..string.format("%02d", i)].text = saved_slot_data

      -- Check and update the slot display after loading data
      check_and_update_slot_display(i)
    end
  end
end

local function clear_pick(slot_index)
  -- Reset the slot text in preferences
  local slot_key = "Slot" .. string.format("%02d", slot_index)
  preferences.OctaMEDPickPutSlots[slot_key].value = "Slot " .. string.format("%02d", slot_index) .. ": Empty"
  renoise.tool().preferences:save_as("preferences.xml")

  -- Reset the textfield to empty state if the dialog is open
  if vb and vb.views["slot_display_"..string.format("%02d", slot_index)] then
    vb.views["slot_display_"..string.format("%02d", slot_index)].text = "Slot " .. string.format("%02d", slot_index) .. ": Empty"
  end

  -- Update status message
  renoise.app():show_status("Cleared Pick Slot " .. slot_index)
end

-- Function to handle the Put operation for Effect Columns
local function put_effect_columns(effect_data, line_indices)
  local track = renoise.song().selected_track

  -- Ensure the track has effect columns
  if track.visible_effect_columns == 0 then
    renoise.app():show_status("This track does not have visible effect columns.")
    return
  end

  -- Update the number of visible effect columns only if the pick-slot has more columns
  local effect_count_in_pick_slot = #effect_data
  if effect_count_in_pick_slot > track.visible_effect_columns then
    track.visible_effect_columns = effect_count_in_pick_slot
  end

  -- Iterate over the specified lines
  for _, line_index in ipairs(line_indices) do
    local pattern_line = renoise.song().selected_pattern.tracks[renoise.song().selected_track_index].lines[line_index]

    -- Write data into the visible effect columns without reducing the number of columns
    for i = 1, math.min(effect_count_in_pick_slot, track.visible_effect_columns) do
      local effect_column = pattern_line.effect_columns[i]
      local effect_str = effect_data[i]

      -- Handle the effect command and value properly
      effect_column.number_string = effect_str:sub(1, 2) -- First two characters (effect number)
      effect_column.amount_string = effect_str:sub(3, 4) -- Last two characters (effect amount)
    end
  end

  renoise.app():show_status("Effect columns updated successfully")
end

-- Function to handle the Put operation for Note and Effect Columns
local function put_note_instrument(slot_index)
  local track = renoise.song().selected_track
  local pattern = renoise.song().selected_pattern
  local current_line_index = renoise.song().selected_line_index

  local textfield_value = vb.views["slot_display_"..string.format("%02d", slot_index)].text
  if textfield_value == "Slot " .. string.format("%02d", slot_index) .. ": Empty" then
    renoise.app():show_status("Slot " .. string.format("%02d", slot_index) .. " is empty.")
    return
  end

  -- Split the text into note data and effect data
  local parts = string_split(textfield_value, "||")
  local note_data = string_split(parts[1] or "", "|")
  local effect_data = string_split(parts[2] or "", "|")

  local process_note_columns = true
  if track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER then
    process_note_columns = false
  end

  -- If there are no note columns in the slot data, do not overwrite current note columns
  if not note_data or #note_data == 0 or note_data[1]:match("^%s*$") then
    process_note_columns = false
  end

  -- Determine the lines to process based on randomization and edit step
  local line_indices = {}
  local pattern_length = pattern.number_of_lines
  local edit_step = renoise.song().transport.edit_step
  local start_line = current_line_index

  if randomize_enabled then
    local total_steps = pattern_length
    local step = 1

    if use_edit_step_for_put and edit_step > 0 then
      step = edit_step
      total_steps = math.floor((pattern_length - start_line + 1) / step)
    end

    for i = start_line, pattern_length, step do
      if math.random(100) <= randomize_percentage then
        table.insert(line_indices, i)
      end
    end
  else
    if use_edit_step_for_put and edit_step > 0 then
      table.insert(line_indices, current_line_index)
      renoise.song().selected_line_index = math.min(current_line_index + edit_step, pattern_length)
    else
      table.insert(line_indices, current_line_index)
    end
  end

  for _, line_index in ipairs(line_indices) do
    local pattern_line = pattern.tracks[renoise.song().selected_track_index].lines[line_index]

    -- Process Note Columns if applicable
    if process_note_columns then
      -- Update the number of visible note columns to fit the picked data
      if #note_data > track.visible_note_columns then
        track.visible_note_columns = #note_data
      end

      -- Process and write to all note columns
      for i = 1, math.min(#note_data, track.visible_note_columns) do
        local note_column = pattern_line.note_columns[i]
        local note_parts = string_split(note_data[i]:gsub("^%s+", ""), " ")  -- Remove leading spaces

        -- Assign the note column values only if they are not empty
        if note_parts[1] ~= "---" and note_parts[1] ~= "..." then
          note_column.note_string = note_parts[1]
        end

        if note_parts[2] ~= ".." then
          if set_to_selected_instrument then
            note_column.instrument_value = renoise.song().selected_instrument_index - 1
          else
            note_column.instrument_string = note_parts[2]
          end
        end

        if note_parts[3] ~= ".." then
        renoise.song().selected_track.volume_column_visible = true
          note_column.volume_string = note_parts[3]
        end

        if note_parts[4] ~= ".." then
        renoise.song().selected_track.panning_column_visible = true
          note_column.panning_string = note_parts[4]
        end

        if note_parts[5] ~= ".." then
        renoise.song().selected_track.delay_column_visible = true
          note_column.delay_string = note_parts[5]
        end

        -- Handle samplefx data
        if #note_parts > 5 and note_parts[6] ~= "...." then
                  renoise.song().selected_track.sample_effects_column_visible = true

          note_column.effect_number_string = note_parts[6]:sub(1, 2) -- Effect command
          note_column.effect_amount_string = note_parts[6]:sub(3, 4) -- Effect value
        end
      end
    end

    -- After processing note columns, call put_effect_columns for effect data
    if effect_data and #effect_data > 0 and effect_data[1] ~= "" then
      put_effect_columns(effect_data, {line_index})
    end
  end

  -- Update status and return focus to pattern editor
  renoise.app():show_status("Put: Slot " .. string.format("%02d", slot_index) .. " - " .. textfield_value)
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

local function put_from_preferences(slot_index)
  local track = renoise.song().selected_track
  local pattern = renoise.song().selected_pattern
  local current_line_index = renoise.song().selected_line_index

  -- Retrieve the slot text from preferences
  local slot_key = "Slot" .. string.format("%02d", slot_index)
  local slot_text = preferences.OctaMEDPickPutSlots[slot_key].value

  if slot_text == "" or slot_text == "Slot " .. string.format("%02d", slot_index) .. ": Empty" then
    renoise.app():show_status("Slot " .. string.format("%02d", slot_index) .. " is empty in preferences.")
    return
  end

  -- Split the text into note data and effect data
  local parts = string_split(slot_text, "||")
  local note_data = string_split(parts[1] or "", "|")
  local effect_data = string_split(parts[2] or "", "|")

  local process_note_columns = true
  if track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER then
    process_note_columns = false
  end

  -- If there are no note columns in the slot data, do not overwrite current note columns
  if not note_data or #note_data == 0 or note_data[1]:match("^%s*$") then
    process_note_columns = false
  end

  -- Determine the lines to process based on randomization and edit step
  local line_indices = {}
  local pattern_length = pattern.number_of_lines
  local edit_step = renoise.song().transport.edit_step
  local start_line = current_line_index

  if randomize_enabled then
    local total_steps = pattern_length
    local step = 1

    if use_edit_step_for_put and edit_step > 0 then
      step = edit_step
      total_steps = math.floor((pattern_length - start_line + 1) / step)
    end

    for i = start_line, pattern_length, step do
      if math.random(100) <= randomize_percentage then
        table.insert(line_indices, i)
      end
    end
  else
    if use_edit_step_for_put and edit_step > 0 then
      table.insert(line_indices, current_line_index)
      renoise.song().selected_line_index = math.min(current_line_index + edit_step, pattern_length)
    else
      table.insert(line_indices, current_line_index)
    end
  end

  for _, line_index in ipairs(line_indices) do
    local pattern_line = pattern.tracks[renoise.song().selected_track_index].lines[line_index]

    -- Process Note Columns if applicable
    if process_note_columns then
      -- Update the number of visible note columns to fit the picked data
      if #note_data > track.visible_note_columns then
        track.visible_note_columns = #note_data
      end

      -- Process and write to all note columns
      for i = 1, math.min(#note_data, track.visible_note_columns) do
        local note_column = pattern_line.note_columns[i]
        local note_parts = string_split(note_data[i]:gsub("^%s+", ""), " ")  -- Remove leading spaces

        -- Assign the note column values only if they are not empty
        if note_parts[1] ~= "---" and note_parts[1] ~= "..." then
          note_column.note_string = note_parts[1]
        end

        if note_parts[2] ~= ".." then
          if set_to_selected_instrument then
            note_column.instrument_value = renoise.song().selected_instrument_index - 1
          else
            note_column.instrument_string = note_parts[2]
          end
        end

        if note_parts[3] ~= ".." then
          renoise.song().selected_track.volume_column_visible = true
          note_column.volume_string = note_parts[3]
        end

        if note_parts[4] ~= ".." then
          renoise.song().selected_track.panning_column_visible = true
          note_column.panning_string = note_parts[4]
        end

        if note_parts[5] ~= ".." then
                  renoise.song().selected_track.delay_column_visible = true

          note_column.delay_string = note_parts[5]
        end

        -- Handle samplefx data
        if #note_parts > 5 and note_parts[6] ~= "...." then
          renoise.song().selected_track.sample_effects_column_visible = true
          note_column.effect_number_string = note_parts[6]:sub(1, 2) -- Effect command
          note_column.effect_amount_string = note_parts[6]:sub(3, 4) -- Effect value
        end
      end
    end

    -- After processing note columns, call put_effect_columns for effect data
    if effect_data and #effect_data > 0 and effect_data[1] ~= "" then
      put_effect_columns(effect_data, {line_index})
    end
  end

  -- Update status and return focus to pattern editor
  renoise.app():show_status("Put: Slot " .. string.format("%02d", slot_index) .. " from preferences.")
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

local function pick_to_preferences(slot_index)
  local track = renoise.song().selected_track
  local pattern_line = renoise.song().selected_pattern.tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index]

  local note_columns_str = {}
  local effect_columns_str = {}

  -- Process Note Columns if applicable
  if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
    for i = 1, track.visible_note_columns do
      local note_column = pattern_line.note_columns[i]
      local note_str = note_column.note_string .. " " ..
                       note_column.instrument_string .. " " ..
                       note_column.volume_string .. " " ..
                       note_column.panning_string .. " " ..
                       note_column.delay_string .. " "

      -- Handle Sample FX column, if empty, put "...."
      if note_column.effect_number_string == "00" and note_column.effect_amount_string == "00" then
        note_str = note_str .. "...."
      else
        note_str = note_str .. note_column.effect_number_string .. note_column.effect_amount_string
      end

      table.insert(note_columns_str, note_str)
    end
  end

  -- Process Effect Columns
  local last_non_empty_effect_index = 0
  for i = 1, track.visible_effect_columns do
    local effect_column = pattern_line.effect_columns[i]
    local effect_str = effect_column.number_string .. effect_column.amount_string

    -- If the effect column is not empty, update the last non-empty index
    if effect_str ~= "0000" then
      last_non_empty_effect_index = i
    end

    -- Collect all effect columns
    table.insert(effect_columns_str, effect_str)
  end

  -- Truncate effect columns after the last non-empty column
  effect_columns_str = {unpack(effect_columns_str, 1, last_non_empty_effect_index)}

  -- Combine Note and Effect Columns
  local slot_text = table.concat(note_columns_str, " | ") .. "||" .. table.concat(effect_columns_str, "|")

  -- Update the corresponding textfield
  vb.views["slot_display_"..string.format("%02d", slot_index)].text = slot_text

  -- Save the picked slot data
  save_slot_to_preferences(slot_index)
end

-- Function to handle picking note and instrument data
local function pick_note_instrument(slot_index)
  pick_to_preferences(slot_index)
  renoise.app():show_status("Picked to Slot " .. string.format("%02d", slot_index))
end

-- Function to save dialog content to a text file
local function save_dialog_content_to_file()
  local filename = renoise.app():prompt_for_filename_to_write(".txt", "Save Pick/Put Dialog Content")
  if filename and filename ~= "" then
    local file, err = io.open(filename, "w")
    if file then
      for i = 1, 10 do
        local slot_text = vb.views["slot_display_"..string.format("%02d", i)].text
        file:write(slot_text, "\n")
      end
      file:close()
      renoise.app():show_status("Dialog content saved to " .. filename)
    else
      renoise.app():show_warning("Error saving file: " .. err)
    end
  end
end

-- Function to load dialog content from a text file
local function load_dialog_content_from_file()
  local filename = renoise.app():prompt_for_filename_to_read({"*.txt", "*.TXT", "*.Txt", "*"}, "Load Pick/Put Dialog Content")
  if filename and filename ~= "" then
    local file, err = io.open(filename, "r")
    if file then
      local i = 1
      for line in file:lines() do
        if i > 10 then break end
        vb.views["slot_display_"..string.format("%02d", i)].text = line
        -- Update preferences
        local slot_key = "Slot" .. string.format("%02d", i)
        preferences.OctaMEDPickPutSlots[slot_key].value = line
        i = i + 1
      end
      file:close()
      renoise.app():show_status("Dialog content loaded from " .. filename)
      -- Save preferences after loading
      renoise.tool().preferences:save_as("preferences.xml")
    else
      renoise.app():show_warning("Error loading file: " .. err)
    end
  end
end

-- Custom key handler function to allow key events to pass through to pattern editor
local function my_keyhandler_func(dialog, key)
  local closer = preferences.pakettiDialogClose.value
  if key.modifiers == "" and key.name == closer then
    dialog:close()
    renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
    return
  end

  -- Allow other keys to pass through to the pattern editor
  return key
end

-- Function to toggle the visibility of the dialog
function toggle_paketti_pick_dialog()
  if dialog and dialog.visible then
    dialog:close()
    dialog = nil
  else
    dialog = renoise.app():show_custom_dialog(
      "Paketti OctaMED Pick/Put",
      create_paketti_pick_dialog(),
      my_keyhandler_func
    )
  end
  load_slots_from_preferences()

  -- Ensure focus returns to pattern editor
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Function to create the GUI dialog
function create_paketti_pick_dialog()
  vb = renoise.ViewBuilder()

  local rows = {}
  for i = 1, 10 do
    rows[#rows+1] = vb:row{
      vb:button{text="Pick " .. string.format("%02d", i), notifier=function()
        pick_note_instrument(i)
      end},
      vb:button{text="Put " .. string.format("%02d", i), notifier=function()
        put_note_instrument(i)
      end},
      vb:textfield{id="slot_display_"..string.format("%02d", i), text="Slot " .. string.format("%02d", i) .. ": Empty", width=800},
      vb:button{text="Clear", notifier=function()
        clear_pick(i)
      end}
    }
  end

  return vb:column{
    vb:row{
      vb:checkbox{
        value=set_to_selected_instrument,
        notifier=function(value)
          set_to_selected_instrument = value
          save_checkbox_preference()
        end
      },
      vb:text{text="Set to Selected Instrument"}
    },
    vb:row{
      vb:checkbox{
        value=use_edit_step_for_put,
        notifier=function(value)
          use_edit_step_for_put = value
          save_checkbox_preference()
        end
      },
      vb:text{text="Use EditStep for Put"}
    },
    vb:row{
      vb:checkbox{
        id = "randomize_checkbox",
        value = randomize_enabled,
        notifier = function(value)
          randomize_enabled = value
          save_checkbox_preference()
        end
      },
      vb:text{text="Randomize"},
      vb:slider{
        id = "randomize_slider",
        min = 0,
        max = 100,
        value = randomize_percentage,
        notifier = function(value)
          randomize_percentage = value
          vb.views["randomize_percentage_label"].text = tostring(math.floor(value)) .. "%"
          save_checkbox_preference()
        end
      },
      vb:text{id = "randomize_percentage_label", text = tostring(randomize_percentage) .. "%"}
    },
    vb:row{
      vb:button{
        text = "Save Slots",
        notifier = function()
          save_dialog_content_to_file()
        end
      },
      vb:button{
        text = "Load Slots",
        notifier = function()
          load_dialog_content_from_file()
        end
      }
    },
    vb:column(rows)
  }
end

-- Function to clear the current row
function clear_columns()
  local pattern_line = renoise.song().selected_pattern.tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index]
  local note_column = renoise.song().selected_note_column

  note_column:clear()

  for i = 1, #pattern_line.effect_columns do
    pattern_line.effect_columns[i]:clear()
  end

  renoise.app():show_status("Columns cleared!")
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Register shortcuts, keybindings, and MIDI mappings
for i = 1, 9 do
  renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Pick Slot 0"..i, invoke=function() pick_note_instrument(i) end}
  renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Put Slot 0"..i, invoke=function() put_from_preferences(i) end}
  renoise.tool():add_midi_mapping{name="Paketti:OctaMED Pick Slot 0"..i, invoke=function() pick_note_instrument(i) end}
  renoise.tool():add_midi_mapping{name="Paketti:OctaMED Put Slot 0"..i, invoke=function() put_from_preferences(i) end}
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Pick Slot 10", invoke=function() pick_note_instrument(10) end}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Put Slot 10", invoke=function() put_from_preferences(10) end}
renoise.tool():add_midi_mapping{name="Paketti:OctaMED Pick Slot 10", invoke=function() pick_note_instrument(10) end}
renoise.tool():add_midi_mapping{name="Paketti:OctaMED Put Slot 10", invoke=function() put_from_preferences(10) end}

-- Register the main keyboard shortcut and menu entry for the dialog
renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Pick/Put Dialog",invoke=function() toggle_paketti_pick_dialog() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Other Trackers..:OctaMED Pick/Put Dialog",invoke=function() toggle_paketti_pick_dialog() end}


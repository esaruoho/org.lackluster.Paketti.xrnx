local vb = renoise.ViewBuilder()
local dialog = nil

local set_to_selected_instrument = preferences.OctaMEDPickPutSlots.SetSelectedInstrument.value or false
local use_edit_step_for_put = preferences.OctaMEDPickPutSlots.UseEditStep.value or false

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
local function put_effect_columns(effect_data)
  local track = renoise.song().selected_track
  local pattern_line = renoise.song().selected_pattern.tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index]

  -- Ensure the track is valid for effect columns
  if track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER then
    renoise.app():show_status("This track does not support effect columns.")
    return
  end

  -- Update the number of visible effect columns only if the pick-slot has more columns
  local effect_count_in_pick_slot = #effect_data
  if effect_count_in_pick_slot > track.visible_effect_columns then
    track.visible_effect_columns = effect_count_in_pick_slot
  end

  -- Write data into the visible effect columns without reducing the number of columns
  for i = 1, math.min(effect_count_in_pick_slot, track.visible_effect_columns) do
    local effect_column = pattern_line.effect_columns[i]
    local effect_str = effect_data[i]

    -- Handle the effect command and value properly
    effect_column.number_string = effect_str:sub(1, 2) -- First two characters (effect number)
    effect_column.amount_string = effect_str:sub(3, 4) -- Last two characters (effect amount)
  end

  renoise.app():show_status("Effect columns updated successfully")
end

-- Function to handle the Put operation for Note and Effect Columns
local function put_note_instrument(slot_index)
  local track = renoise.song().selected_track
  local pattern_line = renoise.song().selected_pattern.tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index]

  if track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER then
    renoise.app():show_status("This is not a track that can have notes in it")
    return
  end

  local textfield_value = vb.views["slot_display_"..string.format("%02d", slot_index)].text
  if textfield_value == "Slot " .. string.format("%02d", slot_index) .. ": Empty" then
    renoise.app():show_status("Slot " .. string.format("%02d", slot_index) .. " is empty.")
    return
  end

  -- Split the text into note data and effect data
  local parts = string_split(textfield_value, "||")
  local note_data = string_split(parts[1] or "", "|")
  local effect_data = string_split(parts[2] or "", "|")

  -- Update the number of visible note columns to fit the picked data
  if #note_data > track.visible_note_columns then
    track.visible_note_columns = #note_data
  end

  -- Process and write to all note columns
  for i = 1, math.min(#note_data, track.visible_note_columns) do
    local note_column = pattern_line.note_columns[i]
    local note_parts = string_split(note_data[i]:gsub("^%s+", ""), " ")  -- Remove leading spaces

    -- Make note columns visible if they contain data
    track.volume_column_visible = track.volume_column_visible or note_parts[3] ~= ".."
    track.panning_column_visible = track.panning_column_visible or note_parts[4] ~= ".."
    track.delay_column_visible = track.delay_column_visible or note_parts[5] ~= ".."
    track.sample_effects_column_visible = track.sample_effects_column_visible or note_parts[6] ~= "...."

    -- Assign the note column values
    note_column.note_string = note_parts[1]

    -- Replace the instrument with the selected instrument if the option is enabled
    if set_to_selected_instrument and note_parts[2] ~= ".." then
      note_column.instrument_value = renoise.song().selected_instrument_index - 1
    else
      note_column.instrument_string = note_parts[2]
    end

    note_column.volume_string = note_parts[3]
    note_column.panning_string = note_parts[4]
    note_column.delay_string = note_parts[5]

    -- Handle samplefx data
    if #note_parts > 5 and note_parts[6] ~= "...." then
      note_column.effect_number_string = note_parts[6]:sub(1, 2) -- Effect command
      note_column.effect_amount_string = note_parts[6]:sub(3, 4) -- Effect value
    end
  end

  -- After processing note columns, call put_effect_columns for effect data
  put_effect_columns(effect_data)

  -- Update status and return focus to pattern editor
  renoise.app():show_status("Put: Slot " .. string.format("%02d", slot_index) .. " - " .. textfield_value)
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  -- Handle edit step if enabled
  if use_edit_step_for_put then
    local edit_step = renoise.song().transport.edit_step
    if edit_step > 0 then
      renoise.song().selected_line_index = math.min(renoise.song().selected_line_index + edit_step, renoise.song().selected_pattern.number_of_lines)
    end
  end
end

local function put_from_preferences(slot_index)
  local track = renoise.song().selected_track
  local pattern_line = renoise.song().selected_pattern.tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index]

  if track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER then
    renoise.app():show_status("This is not a track that can have notes in it")
    return
  end

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

  -- Update the number of visible note columns to fit the picked data
  if #note_data > track.visible_note_columns then
    track.visible_note_columns = #note_data
  end

  -- Process and write to all note columns
  for i = 1, math.min(#note_data, track.visible_note_columns) do
    local note_column = pattern_line.note_columns[i]
    local note_parts = string_split(note_data[i]:gsub("^%s+", ""), " ")  -- Remove leading spaces

    -- Make note columns visible if they contain data
    track.volume_column_visible = track.volume_column_visible or note_parts[3] ~= ".."
    track.panning_column_visible = track.panning_column_visible or note_parts[4] ~= ".."
    track.delay_column_visible = track.delay_column_visible or note_parts[5] ~= ".."
    track.sample_effects_column_visible = track.sample_effects_column_visible or note_parts[6] ~= "...."

    -- Assign the note column values
    note_column.note_string = note_parts[1]

    -- Replace the instrument with the selected instrument if the option is enabled
    if set_to_selected_instrument and note_parts[2] ~= ".." then
      note_column.instrument_value = renoise.song().selected_instrument_index - 1
    else
      note_column.instrument_string = note_parts[2]
    end

    note_column.volume_string = note_parts[3]
    note_column.panning_string = note_parts[4]
    note_column.delay_string = note_parts[5]

    -- Handle samplefx data
    if #note_parts > 5 and note_parts[6] ~= "...." then
      note_column.effect_number_string = note_parts[6]:sub(1, 2) -- Effect command
      note_column.effect_amount_string = note_parts[6]:sub(3, 4) -- Effect value
    end
  end

  -- After processing note columns, call put_effect_columns for effect data
  put_effect_columns(effect_data)

  -- Update status and return focus to pattern editor
  renoise.app():show_status("Put: Slot " .. string.format("%02d", slot_index) .. " from preferences.")
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  -- Handle edit step if enabled
  if use_edit_step_for_put then
    local edit_step = renoise.song().transport.edit_step
    if edit_step > 0 then
      renoise.song().selected_line_index = math.min(renoise.song().selected_line_index + edit_step, renoise.song().selected_pattern.number_of_lines)
    end
  end
end

local function pick_to_preferences(slot_index)
  local track = renoise.song().selected_track
  local pattern_line = renoise.song().selected_pattern.tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index]

  if track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER then
    renoise.app():show_status("This is not a track that can have notes in it")
    return
  end

  local note_columns_str = {}
  local effect_columns_str = {}

  -- Process Note Columns
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

  -- Combine Note and Effect Columns into a single string
  local slot_text = table.concat(note_columns_str, " | ") .. "||" .. table.concat(effect_columns_str, "|")

  -- Save the picked slot data to preferences
  local slot_key = "Slot" .. string.format("%02d", slot_index)
  preferences.OctaMEDPickPutSlots[slot_key].value = slot_text
  renoise.tool().preferences:save_as("preferences.xml")

  -- Status message
  renoise.app():show_status("Pick: Slot " .. string.format("%02d", slot_index) .. " saved to preferences.")
end

-- Declare a global slots table to store picked note and effect data
local slots = {}

-- Initialize the slots table for 10 slots
for i = 1, 10 do
  slots[i] = {
    note_columns = {},
    effect_columns = {}
  }
end

local function pick_note_instrument(slot_index)
  local track = renoise.song().selected_track
  local pattern_line = renoise.song().selected_pattern.tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index]

  if track.type ~= renoise.Track.TRACK_TYPE_SEQUENCER then
    renoise.app():show_status("This is not a track that can have notes in it")
    return
  end

  local note_columns_str = {}
  local effect_columns_str = {}

  -- Process Note Columns
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

-- Custom key handler function to allow key events to pass through to pattern editor
local function my_keyhandler_func(dialog, key)
  -- Check for specific keys to handle in the dialog
  if key.name == "esc" then
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

local function my_keyhandler_func(dialog, key)
  if not (key.modifiers == "" and key.name == "exclamation") then
    return key
  else
    dialog:close()
    dialog = nil
    save_slots_to_preferences()
    return nil
  end
end

-- Register shortcuts, keybindings, and MIDI mappings
for i = 1, 9 do
  renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Pick Slot 0"..i, invoke=function() pick_note_instrument(i) end}
  renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Put Slot 0"..i, invoke=function() put_from_preferences(i) end}  -- Updated to use put_from_preferences
  renoise.tool():add_midi_mapping{name="Paketti:OctaMED Pick Slot 0"..i, invoke=function() pick_note_instrument(i) end}
  renoise.tool():add_midi_mapping{name="Paketti:OctaMED Put Slot 0"..i, invoke=function() put_from_preferences(i) end}  -- Updated to use put_from_preferences
end

  renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Pick Slot 10", invoke=function() pick_note_instrument(i) end}
  renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Put Slot 10", invoke=function() put_from_preferences(i) end}  -- Updated to use put_from_preferences
  renoise.tool():add_midi_mapping{name="Paketti:OctaMED Pick Slot 10", invoke=function() pick_note_instrument(i) end}
  renoise.tool():add_midi_mapping{name="Paketti:OctaMED Put Slot 10", invoke=function() put_from_preferences(i) end}  -- Updated to use put_from_preferences


-- Register the main keyboard shortcut and menu entry for the dialog
renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Pick/Put Dialog",invoke=function() toggle_paketti_pick_dialog() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:OctaMED Pick/Put Dialog",invoke=function() toggle_paketti_pick_dialog() end}


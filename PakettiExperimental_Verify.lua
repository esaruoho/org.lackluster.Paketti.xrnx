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
for i = 1, 10 do
  renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Pick Slot "..i, invoke=function() pick_note_instrument(i) end}
  renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Put Slot "..i, invoke=function() put_from_preferences(i) end}  -- Updated to use put_from_preferences
  renoise.tool():add_midi_mapping{name="Paketti:OctaMED Pick Slot "..i, invoke=function() pick_note_instrument(i) end}
  renoise.tool():add_midi_mapping{name="Paketti:OctaMED Put Slot "..i, invoke=function() put_from_preferences(i) end}  -- Updated to use put_from_preferences
end


-- Register the main keyboard shortcut and menu entry for the dialog
renoise.tool():add_keybinding{name="Pattern Editor:Paketti..:OctaMED Pick/Put Dialog",invoke=function() toggle_paketti_pick_dialog() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:OctaMED Pick/Put Dialog",invoke=function() toggle_paketti_pick_dialog() end}

-- Debug reload function
_AUTO_RELOAD_DEBUG = function() end












































-- Main function to adjust sample velocity range
function pakettiSampleVelocityRangeChoke(sample_index)
  local song = renoise.song()
  local ing = song.selected_instrument

  -- Edge case: no instrument or no samples
  if not ing or #ing.samples == 0 then
    renoise.app():show_status("No instrument or samples available.")
    return
  end

  -- Set all samples' velocity ranges to {0, 0}, except the selected one
  for i = 1, #ing.samples do
    if i ~= sample_index then
      local mapping = ing.sample_mappings[1][i]
      if mapping then
        mapping.velocity_range = {0, 0} -- Disable all other samples
      end
    end
  end

  -- Set the selected sample's velocity range to {0, 127}
  local selected_mapping = ing.sample_mappings[1][sample_index]
  if selected_mapping then
    selected_mapping.velocity_range = {0, 127} -- Enable selected sample
  end
  
  renoise.song().selected_sample_index=sample_index
renoise.app():show_status("Sample " .. sample_index .. ": " .. renoise.song().selected_sample.name .. " selected.")
  -- Update status
  --renoise.app():show_status("Sample " .. sample_index .. " set to velocity range 00-7F, all other samples set to 00-00.")
end

-- MIDI Mapping: Adjust velocity ranges based on MIDI knob
function midi_sample_velocity_switcharoo(value)
  local song = renoise.song()
  local ing = song.selected_instrument

  -- Edge case: no instrument or no samples
  if not ing or #ing.samples == 0 then
    renoise.app():show_status("No instrument or samples available.")
    return
  end

  -- Map the MIDI knob value (0-127) to the sample index
  local selected_sample_index = math.floor((value / 127) * (#ing.samples - 1)) + 1


  -- Set velocity ranges for all samples based on the selected sample
  pakettiSampleVelocityRangeChoke(selected_sample_index)
end

-- "One-up" keybinding: Decreases selected_sample_index by 1
function sample_one_up()
  local song = renoise.song()
  local ing = song.selected_instrument
  local current_index = song.selected_sample_index

  -- Ensure boundary conditions
  if current_index > 1 then
    song.selected_sample_index = current_index - 1
    pakettiSampleVelocityRangeChoke(song.selected_sample_index)
  end
  end

-- "One-down" keybinding: Increases selected_sample_index by 1
function sample_one_down()
  local song = renoise.song()
  local ing = song.selected_instrument
  local current_index = song.selected_sample_index

  -- Ensure boundary conditions
  if current_index < #ing.samples then
    song.selected_sample_index = current_index + 1
    pakettiSampleVelocityRangeChoke(song.selected_sample_index)
  end
  end

-- "Random" keybinding: Selects a random sample and mutes others
function sample_random()
  local song = renoise.song()
  local ing = song.selected_instrument

  -- Edge case: no instrument or no samples
  if not ing or #ing.samples == 0 then
    renoise.app():show_status("No instrument or samples available.")
    return
  end

  -- Pick a random sample index
  local random_index = math.random(1, #ing.samples)
  song.selected_sample_index = random_index

  -- Set velocity ranges accordingly
  pakettiSampleVelocityRangeChoke(random_index)
end

-- Add MIDI mapping for knob control in one line
renoise.tool():add_midi_mapping{name="Paketti:Midi Set Selected Sample Velocity Range", invoke=function(midi_message) midi_sample_velocity_switcharoo(midi_message.int_value) end}

-- Add keybindings for moving up, down, and random sample selection, all in one line
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample (+1) Velocity Range 7F others 00", invoke=function() sample_one_down() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample (-1) Velocity Range 7F others 00", invoke=function() sample_one_up() end}
renoise.tool():add_keybinding{name="Global:Paketti:Set Selected Sample (Random) Velocity Range 7F others 00", invoke=function() sample_random() end}








function shrink_to_triplets()
    local song = renoise.song()
    local track = song.selected_pattern.tracks[renoise.song().selected_track_index]
    local pattern_length = song.selected_pattern.number_of_lines

    local note_positions = {}

    -- Collect all notes and their positions
    for line_index = 1, pattern_length do
        local line = track:line(line_index)
        local note_column = line.note_columns[1]

        if not note_column.is_empty then
            -- Manually clone the note data
            table.insert(note_positions, {line_index, {
                note_value = note_column.note_value,
                instrument_value = note_column.instrument_value,
                volume_value = note_column.volume_value,
                panning_value = note_column.panning_value,
                delay_value = note_column.delay_value
            }})
        end
    end

    -- Ensure we have enough notes to work with
    if #note_positions < 2 then
        renoise.app():show_status("Not enough notes to apply triplet structure.")
        return
    end

    -- Calculate the original spacing between notes
    local original_spacing = note_positions[2][1] - note_positions[1][1]

    -- Determine the modifier based on the spacing
    local modifier = math.floor(original_spacing / 2)  -- Will be 1 for 2-row spacing and 2 for 4-row spacing
    local cycle_step = 0

    -- Clear the pattern before applying the triplets
    for line_index = 1, pattern_length do
        track:line(line_index):clear()
    end

    -- Apply triplet logic based on the original spacing
    local new_index = note_positions[1][1]  -- Start at the first note

    for i = 1, #note_positions do
        local note_data = note_positions[i][2]
        local target_line = track:line(new_index)

        -- Triplet Logic
        if original_spacing == 2 then
            -- Case for notes every 2 rows
            if cycle_step == 0 then
                target_line.note_columns[1].note_value = note_data.note_value
                target_line.note_columns[1].instrument_value = note_data.instrument_value
                target_line.note_columns[1].delay_value = 0x00
            elseif cycle_step == 1 then
                target_line.note_columns[1].note_value = note_data.note_value
                target_line.note_columns[1].instrument_value = note_data.instrument_value
                target_line.note_columns[1].delay_value = 0x55
            elseif cycle_step == 2 then
                target_line.note_columns[1].note_value = note_data.note_value
                target_line.note_columns[1].instrument_value = note_data.instrument_value
                target_line.note_columns[1].delay_value = 0xAA

                -- Add extra empty row after AA
                new_index = new_index + 1
            end

            -- Move to the next row
            new_index = new_index + 1
            cycle_step = (cycle_step + 1) % 3

        elseif original_spacing == 4 then
            -- Case for notes every 4 rows
            if cycle_step == 0 then
                target_line.note_columns[1].note_value = note_data.note_value
                target_line.note_columns[1].instrument_value = note_data.instrument_value
                target_line.note_columns[1].delay_value = 0x00
            elseif cycle_step == 1 then
                -- Move the note up by 2 rows and apply AA delay
                new_index = new_index + 2
                target_line = track:line(new_index)
                target_line.note_columns[1].note_value = note_data.note_value
                target_line.note_columns[1].instrument_value = note_data.instrument_value
                target_line.note_columns[1].delay_value = 0xAA

                -- Add one empty row after AA
                new_index = new_index + 1
            elseif cycle_step == 2 then
                -- Apply 55 delay and move up by 1 row
                target_line = track:line(new_index)
                target_line.note_columns[1].note_value = note_data.note_value
                target_line.note_columns[1].instrument_value = note_data.instrument_value
                target_line.note_columns[1].delay_value = 0x55

                -- Add one empty row after 55
                new_index = new_index + 1
            end

            -- Move to the next row
            new_index = new_index + 1
            cycle_step = (cycle_step + 1) % 3
        end
    end

    renoise.app():show_status("Shrink to triplets applied successfully.")
end

-- Keybinding for the script
renoise.tool():add_keybinding {
    name = "Pattern Editor:Paketti:Shrink to Triplets",
    invoke = function() shrink_to_triplets() end
}


































function triple(first,second,where)
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index+first].note_columns[1]:copy_from(renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[1])



renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index+second].note_columns[1]:copy_from(renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[1])


local wherenext=renoise.song().selected_line_index+where

if wherenext > renoise.song().patterns[renoise.song().selected_pattern_index].number_of_lines then
wherenext=1 
renoise.song().selected_line_index = wherenext return
else  renoise.song().selected_line_index=renoise.song().selected_line_index+where
end
end

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Triple (Experimental)",invoke=function() triple(3,6,8) end}






local vb = renoise.ViewBuilder()
local pitch_shift_amount = 0
local dialog = nil

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

-- Function to perform modulation
local function modulate_samples()
  mix_and_process_samples("modulate")
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

-- Function to handle Phase Inversion and Audio Diff
local function phase_invert_and_diff_sample()
  phase_invert_sample()
  create_audio_diff_sample()
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

-- Function to handle Modulation and Audio Diff
local function modulate_and_diff_sample()
  modulate_samples()
  create_audio_diff_sample()
end

-- Keyhandler function for dialog
local function my_keyhandler_func(dialog, key)
  if not (key.modifiers == "" and key.name == "exclamation") then return key
  else dialog:close() dialog = nil return nil
  end
end

-- Dialog content creation
local dialog_content = vb:column {margin = 10,
  vb:text {text = "Audio Processing Tools"},

  -- Phase Inversion Buttons
  vb:row {
    vb:button {text = "Phase Inversion", notifier = function() phase_invert_sample() end},
    vb:button {text = "Phase Inversion & Audio Diff", notifier = function() phase_invert_and_diff_sample() end},
  },

  -- New Button for Invert Right, Sum Mono
  vb:row {
    vb:button {text = "Invert Right, Sum Mono", notifier = function() invert_right_sum_mono() end},
  },

  -- Pitch Shift Buttons
  vb:row {
    vb:valuebox {min = -100, max = 100, value = pitch_shift_amount, notifier = function(value) pitch_shift_amount = value end},
    vb:button {text = "Pitch Shift", notifier = function() pitch_shift_sample(pitch_shift_amount) end},
    vb:button {text = "Pitch Shift & Audio Diff", notifier = function() pitch_shift_and_diff_sample() end},
  },

  -- Modulation Buttons
  vb:row {
    vb:button {text = "Clip bottom of waveform", notifier = function() modulate_samples() end},
    vb:button {text = "Modulate & Audio Diff", notifier = function() modulate_and_diff_sample() end},
  },

  -- Audio Diff Button
  vb:row {
    vb:button {text = "Audio Diff", notifier = function() create_audio_diff_sample() end},
  }
}

-- Function to show the dialog
function PakettiAudioProcessingToolsDialogShow()
  if dialog and dialog.visible then dialog:show() else
    dialog = renoise.app():show_custom_dialog("Audio Processing Tools", dialog_content, my_keyhandler_func)
  end
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
renoise.tool():add_keybinding {name = "Sample Editor:Paketti:Audio Processing Tools Dialog", invoke = function() PakettiAudioProcessingToolsDialogShow() end}








local PakettiResamplerDialog = nil

-- Function to copy sample settings from one sample to another
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

-- Function to render the sample at a new sample rate without changing its sound
local function RenderSampleAtNewRate(target_sample_rate, target_bit_depth)
  local instrument = renoise.song().selected_instrument
  local sample_index = renoise.song().selected_sample_index
  local sample = instrument:sample(sample_index)
  local buffer = sample.sample_buffer

  if buffer.has_sample_data then
    local original_sample_rate = buffer.sample_rate
    local original_frame_count = buffer.number_of_frames
    local ratio = target_sample_rate / original_sample_rate
    local new_frame_count = math.floor(original_frame_count * ratio)
    
    print("Original frames: " .. original_frame_count)
    print("Result frames at " .. target_sample_rate .. " Hz: " .. new_frame_count)
    
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

    renoise.app():show_status("Sample resampled to " .. target_sample_rate .. " Hz and " .. target_bit_depth .. " bit.")
  else
    renoise.app():show_status("Sample buffer is either not loaded or is not at the correct sample rate.")
  end
end

-- Function to destructively resample the selected sample to a specified sample rate
local function DestructiveResample(target_sample_rate, target_bit_depth)
  local instrument = renoise.song().selected_instrument
  local sample_index = renoise.song().selected_sample_index
  local sample = instrument:sample(sample_index)
  local buffer = sample.sample_buffer
  
  if buffer.has_sample_data then
    local original_sample_rate = buffer.sample_rate
    local original_frame_count = buffer.number_of_frames
    local ratio = target_sample_rate / original_sample_rate
    local new_frame_count = math.floor(original_frame_count * ratio)
    
    print("Original frames: " .. original_frame_count)
    print("Result frames at " .. target_sample_rate .. " Hz: " .. new_frame_count)
    
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
    
    renoise.app():show_status("Sample processed with " .. target_sample_rate .. " Hz and " .. target_bit_depth .. " bit.")
  else
    renoise.app():show_status("Sample buffer is either not loaded or is not at the correct sample rate.")
  end
end

-- Custom key handler for the dialog
function my_keyhandler_func(dialog, key)
  if not (key.modifiers == "" and key.name == "exclamation") then
    return key
  else
    dialog:close()
    PakettiResamplerDialog = nil
    return nil
  end
end

-- Function to show the resampling dialog
function PakettiResamplerDialogShow()
  -- Close the dialog if it's already open
  if PakettiResamplerDialog and PakettiResamplerDialog.visible then
    PakettiResamplerDialog:close()
    PakettiResamplerDialog = nil
    return
  end

  local vb = renoise.ViewBuilder()  -- Create a new ViewBuilder instance every time

  local function update_dialog_values()
    local sample = renoise.song().selected_sample
    local buffer = sample.sample_buffer
    
    if buffer.has_sample_data then
      local selected_rate = vb.views.rate_slider.value
      local selected_bit_depth = vb.views.bitdepth_switch.value * 8
      vb.views.current_sample_rate.text = "Selected Sample Rate: " .. selected_rate .. " Hz"
      vb.views.current_length.text = "Number of Frames at Selected Sample Rate: " .. math.floor(buffer.number_of_frames * (selected_rate / buffer.sample_rate))
      vb.views.current_bit_depth.text = "Current Bit Depth: " .. selected_bit_depth .. " Bit"
    end
  end

if renoise.song().selected_sample ~= nil then
  local sample = renoise.song().selected_sample
else
renoise.app():show_status("Please select a Sample and then open this dialog again.")
return
end

    local sample = renoise.song().selected_sample

  local buffer = sample.sample_buffer
  
  if not buffer.has_sample_data then
    renoise.app():show_status("No sample data to process.")
    return
  end

  -- Default values based on current sample properties
  local current_name = sample.name
  local current_rate = buffer.sample_rate
  local current_length = buffer.number_of_frames
  local current_bit_depth = buffer.bit_depth

  local destination_rate = current_rate
  local destination_bit_depth = current_bit_depth
  
  -- UI Elements
  local dialog_content = vb:column {
    margin = 10,
    vb:text { text = "Sample Name: " .. current_name },
    vb:text { id = "current_sample_rate", text = "Selected Sample Rate: " .. current_rate .. " Hz" },
    vb:text { id = "current_length", text = "Number of Frames at Selected Sample Rate: " .. current_length },
    vb:text { id = "current_bit_depth", text = "Current Bit Depth: " .. current_bit_depth .. " Bit" },
    vb:space { height = 10 },
    vb:text { id = "rate_label", text = "Destination Sample Rate: " .. current_rate .. " Hz" },
    vb:slider {
      id = "rate_slider",
      min = 225,
      max = 192000,
      value = current_rate,
      width = 900,
      notifier = function(value)
        destination_rate = math.floor(value)
        vb.views.rate_label.text = "Destination Sample Rate: " .. destination_rate .. " Hz"
        update_dialog_values()
      end,
    },
    vb:space { height = 10 },
    vb:row {
      vb:button {
        text = "Halve Sample Rate",
        notifier = function()
          destination_rate = math.max(225, math.floor(vb.views.rate_slider.value / 2))
          vb.views.rate_slider.value = destination_rate
          update_dialog_values()
        end,
      },
      vb:button {
        text = "Double Sample Rate",
        notifier = function()
          destination_rate = math.min(192000, math.floor(vb.views.rate_slider.value * 2))
          vb.views.rate_slider.value = destination_rate
          update_dialog_values()
        end,
      },
      vb:button {
        text = "Resample to 44.1 kHz", -- Add this button for resampling to 44.1 kHz
        notifier = function()
          destination_rate = 44100
          vb.views.rate_slider.value = destination_rate
          RenderSampleAtNewRate(destination_rate, vb.views.bitdepth_switch.value * 8)
          update_dialog_values()
        end,
      },
    },
    vb:space { height = 10 },
    vb:row {
      vb:column {
        vb:row { vb:text { text = "Bit Depth:" } },
        vb:switch {
          id = "bitdepth_switch",
          items = { "8-bit", "16-bit", "24-bit", "32-bit" },
          value = (current_bit_depth / 8),
          width = 200,  -- Reduced to 1/3 of the original width
          notifier = function(idx)
            destination_bit_depth = idx * 8
            update_dialog_values()
          end,
        },
      },
    },
    vb:space { height = 20 },
    vb:button {
      text = "Process",
      notifier = function()
        -- Re-fetch selected sample and instrument data before processing
        local instrument = renoise.song().selected_instrument
        local sample_index = renoise.song().selected_sample_index
        local sample = instrument:sample(sample_index)
        local buffer = sample.sample_buffer
        
        if destination_rate == buffer.sample_rate and destination_bit_depth == buffer.bit_depth then
          renoise.app():show_status("Sample rate and bit depth are already set to the selected values.")
          return
        elseif destination_rate >= buffer.sample_rate then
          -- Render to a higher or equal sample rate or just change bit depth
          RenderSampleAtNewRate(destination_rate, destination_bit_depth)
        else
          -- If the sample rate is reduced, use destructive resampling
          DestructiveResample(destination_rate, destination_bit_depth)
        end
        
        -- Update dialog values after processing
        update_dialog_values()
        
        renoise.app():show_status("Sample processed with " .. destination_rate .. " Hz and " .. destination_bit_depth .. " bit.")
      end,
    },
  }
  
  -- Show the dialog with the custom key handler
  PakettiResamplerDialog = renoise.app():show_custom_dialog("Destructive Resampling", dialog_content, my_keyhandler_func)
end

-- Menu entry and keybinding to show the dialog
renoise.tool():add_menu_entry {name="Sample Editor:Show Resampling Dialog", invoke=function() 
PakettiResamplerDialogShow() 
end}
renoise.tool():add_keybinding {name="Global:Tools:Show Resampling Dialog", invoke=function() 
PakettiResamplerDialogShow() 

end}



























--------
function xypad()
local vb = renoise.ViewBuilder()
local dialog = nil

-- Initial center position
local initial_position = 0.5
local prev_x = initial_position
local prev_y = initial_position

-- Adjust the shift and rotation amounts
local shift_amount = 1  -- Reduced shift amount for smaller up/down changes
local rotation_amount = 2000  -- Adjusted rotation amount for left/right to be less intense

-- Custom key handler function
local function my_keyhandler_func(dialog, key)
  if not (key.modifiers == "" and key.name == "exclamation") then
    return key
  else
    dialog:close()
    dialog = nil
    return nil
  end
end

-- Set the middle frame to the instrument sample editor
renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR

-- Function to wrap the sample value
local function wrap_sample_value(value)
  if value > 1.0 then
    return value - 2.0
  elseif value < -1.0 then
    return value + 2.0
  else
    return value
  end
end

-- Function to shift the sample buffer upwards with wrap-around
local function PakettiXYPadSampleRotatorUp(knob_value)
  local song = renoise.song()
  local sample = song.selected_sample
  local buffer = sample.sample_buffer

  if buffer.has_sample_data then
    buffer:prepare_sample_data_changes()
    for c = 1, buffer.number_of_channels do
      for i = 1, buffer.number_of_frames do
        local current_value = buffer:sample_data(c, i)
        local shift_value = shift_amount * knob_value * 1000  -- Adjusted to match the desired intensity
        local new_value = wrap_sample_value(current_value + shift_value)
        buffer:set_sample_data(c, i, new_value)
      end
    end
    buffer:finalize_sample_data_changes()
    renoise.app():show_status("Sample buffer shifted upwards with wrap-around.")
  else
    renoise.app():show_status("No sample data to shift.")
  end
end

-- Function to shift the sample buffer downwards with wrap-around
local function PakettiXYPadSampleRotatorDown(knob_value)
  local song = renoise.song()
  local sample = song.selected_sample
  local buffer = sample.sample_buffer

  if buffer.has_sample_data then
    buffer:prepare_sample_data_changes()
    for c = 1, buffer.number_of_channels do
      for i = 1, buffer.number_of_frames do
        local current_value = buffer:sample_data(c, i)
        local shift_value = shift_amount * knob_value * 1000  -- Adjusted to match the desired intensity
        local new_value = wrap_sample_value(current_value - shift_value)
        buffer:set_sample_data(c, i, new_value)
      end
    end
    buffer:finalize_sample_data_changes()
    renoise.app():show_status("Sample buffer shifted downwards with wrap-around.")
  else
    renoise.app():show_status("No sample data to shift.")
  end
end

-- Function to rotate sample buffer content forwards by a specified number of frames
local function PakettiXYPadSampleRotatorRight(knob_value)
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
        local new_pos = (i + rotation_amount * knob_value - 1) % frames + 1
        buffer:set_sample_data(c, new_pos, temp_data[i])
      end
    end
    buffer:finalize_sample_data_changes()
    renoise.app():show_status("Sample buffer rotated forward by "..(rotation_amount * knob_value).." frames.")
  else
    renoise.app():show_status("No sample data to rotate.")
  end
end

-- Function to rotate sample buffer content backwards by a specified number of frames
local function PakettiXYPadSampleRotatorLeft(knob_value)
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
        local new_pos = (i - rotation_amount * knob_value - 1 + frames) % frames + 1
        buffer:set_sample_data(c, new_pos, temp_data[i])
      end
    end
    buffer:finalize_sample_data_changes()
    renoise.app():show_status("Sample buffer rotated backward by "..(rotation_amount * knob_value).." frames.")
  else
    renoise.app():show_status("No sample data to rotate.")
  end
end

-- Function to handle XY pad changes and call appropriate rotator functions
local function on_xy_change(value)
  local x = value.x
  local y = value.y

  -- Compare current x and y with previous values to determine direction
  if x > prev_x then
    PakettiXYPadSampleRotatorRight(x - prev_x) -- Moving right
  elseif x < prev_x then
    PakettiXYPadSampleRotatorLeft(prev_x - x) -- Moving left
  end

  if y > prev_y then
    PakettiXYPadSampleRotatorUp(y - prev_y) -- Moving up
  elseif y < prev_y then
    PakettiXYPadSampleRotatorDown(prev_y - y) -- Moving down
  end

  -- Update previous x and y with the current position
  prev_x = x
  prev_y = y

  -- Set focus back to the sample editor after each interaction
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
end

-- Function to handle vertical slider change (up/down)
local function on_vertical_slider_change(value)
  if value > initial_position then
    PakettiXYPadSampleRotatorUp(value - initial_position)
  elseif value < initial_position then
    PakettiXYPadSampleRotatorDown(initial_position - value)
  end
  -- Set focus back to the sample editor after each interaction
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
end

-- Function to handle horizontal slider change (left/right)
local function on_horizontal_slider_change(value)
  if value > initial_position then
    PakettiXYPadSampleRotatorRight(value - initial_position)
  elseif value < initial_position then
    PakettiXYPadSampleRotatorLeft(initial_position - value)
  end
  -- Set focus back to the sample editor after each interaction
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
end

-- Function to display the dialog with the XY pad and sliders
local function show_paketti_sample_rotator_dialog()
  -- Reset the XY pad to the center (0.5, 0.5)
  prev_x = initial_position
  prev_y = initial_position

  if dialog and dialog.visible then
    dialog:show()
    return
  end

  dialog = renoise.app():show_custom_dialog("Paketti XYPad Sample Rotator",
    vb:column{
      vb:row{
        vb:xypad{
          width = 200,
          height = 200,
          notifier = on_xy_change,
          value = {x = initial_position, y = initial_position} -- Center the XY pad
        },
        vb:vertical_aligner{
          mode = "center",
          vb:slider{
            height = 200,
            min = 0.0,
            max = 1.0,
            value = initial_position,
            notifier = on_vertical_slider_change
          }
        }
      },
      vb:horizontal_aligner{
        mode = "center",
        vb:slider{
          width = 200,
          min = 0.0,
          max = 1.0,
          value = initial_position,
          notifier = on_horizontal_slider_change
        }
      }
    },
    my_keyhandler_func
  )
end

-- Show the dialog when the script is run
--show_paketti_sample_rotator_dialog()

end













-- Updated shift amount
local shift_amount = 0.01  -- Default value for subtle shifts

-- Function to wrap the sample value
local function wrap_sample_value(value)
  if value > 1.0 then
    return value - 2.0
  elseif value < -1.0 then
    return value + 2.0
  else
    return value
  end
end

-- Function to shift the sample buffer upwards with wrap-around
function PakettiShiftSampleBufferUpwards(knob_value)
  local song = renoise.song()
  local sample = song.selected_sample
  local buffer = sample.sample_buffer

  if buffer.has_sample_data then
    buffer:prepare_sample_data_changes()
    for c = 1, buffer.number_of_channels do
      for i = 1, buffer.number_of_frames do
        local current_value = buffer:sample_data(c, i)
        local shift_value = shift_amount * knob_value
        local new_value = wrap_sample_value(current_value + shift_value)
        buffer:set_sample_data(c, i, new_value)
      end
    end
    buffer:finalize_sample_data_changes()
    renoise.app():show_status("Sample buffer shifted upwards with wrap-around.")
  else
    renoise.app():show_status("No sample data to shift.")
  end
end

-- Function to shift the sample buffer downwards with wrap-around
function PakettiShiftSampleBufferDownwards(knob_value)
  local song = renoise.song()
  local sample = song.selected_sample
  local buffer = sample.sample_buffer

  if buffer.has_sample_data then
    buffer:prepare_sample_data_changes()
    for c = 1, buffer.number_of_channels do
      for i = 1, buffer.number_of_frames do
        local current_value = buffer:sample_data(c, i)
        local shift_value = shift_amount * knob_value
        local new_value = wrap_sample_value(current_value - shift_value)
        buffer:set_sample_data(c, i, new_value)
      end
    end
    buffer:finalize_sample_data_changes()
    renoise.app():show_status("Sample buffer shifted downwards with wrap-around.")
  else
    renoise.app():show_status("No sample data to shift.")
  end
end

-- Function to shift the sample buffer based on knob position (Up/Down)
function PakettiShiftSampleBuffer(knob_value)
  local song = renoise.song()
  local sample = song.selected_sample
  local buffer = sample.sample_buffer

  if buffer.has_sample_data then
    buffer:prepare_sample_data_changes()
    local direction = 0
    if knob_value <= 63 then
      direction = -1  -- Shift downwards
    else
      direction = 1  -- Shift upwards
    end
    local adjusted_knob_value = math.abs(knob_value - 64) / 63  -- Normalize to 0...1 range
    
    for c = 1, buffer.number_of_channels do
      for i = 1, buffer.number_of_frames do
        local current_value = buffer:sample_data(c, i)
        local shift_value = shift_amount * adjusted_knob_value * direction
        local new_value = wrap_sample_value(current_value + shift_value)
        buffer:set_sample_data(c, i, new_value)
      end
    end
    buffer:finalize_sample_data_changes()
    renoise.app():show_status("Sample buffer shifted " .. (direction > 0 and "upwards" or "downwards") .. " with wrap-around.")
  else
    renoise.app():show_status("No sample data to shift.")
  end
end

-- Adding MIDI mapping for shifting sample buffer upwards [Trigger]
renoise.tool():add_midi_mapping{name="Paketti:Shift Sample Buffer Up x[Trigger]",invoke=function(message)
  if message:is_trigger() then
    PakettiShiftSampleBufferUpwards(1)  -- Full shift on trigger
  end
end}

-- Adding MIDI mapping for shifting sample buffer downwards [Trigger]
renoise.tool():add_midi_mapping{name="Paketti:Shift Sample Buffer Down x[Trigger]",invoke=function(message)
  if message:is_trigger() then
    PakettiShiftSampleBufferDownwards(1)  -- Full shift on trigger
  end
end}

-- Adding MIDI mapping for shifting sample buffer upwards [Knob]
renoise.tool():add_midi_mapping{name="Paketti:Shift Sample Buffer Up x[Knob]",invoke=function(message)
  local knob_value = message.int_value / 127  -- Normalize knob value
  PakettiShiftSampleBufferUpwards(knob_value)
end}

-- Adding MIDI mapping for shifting sample buffer downwards [Knob]
renoise.tool():add_midi_mapping{name="Paketti:Shift Sample Buffer Down x[Knob]",invoke=function(message)
  local knob_value = message.int_value / 127  -- Normalize knob value
  PakettiShiftSampleBufferDownwards(knob_value)
end}

-- Adding MIDI mapping for shifting sample buffer upwards/downwards based on knob position
renoise.tool():add_midi_mapping{name="Paketti:Shift Sample Buffer Up/Down x[Knob]",invoke=function(message)
  PakettiShiftSampleBuffer(message.int_value)
end}

renoise.tool():add_keybinding{name="Sample Editor:Paketti:Shift Sample Buffer Upwards",invoke=function() PakettiShiftSampleBufferUpwards(1) end}

renoise.tool():add_keybinding{name="Sample Editor:Paketti:Shift Sample Buffer Downwards",invoke=function() PakettiShiftSampleBufferDownwards(1) end}

















--[[
local function randomizeSmatterEffectColumnCustom(effect_command)
  local song = renoise.song()
  local track_index = song.selected_track_index
  local pattern_index = song.selected_pattern_index
  local pattern = song.patterns[pattern_index]
  local selection = song.selection_in_pattern
  local randomize = function()
    return string.format("%02X", math.random(1, 255))
  end

  local apply_command = function(line)
    local effect_column = line.effect_columns[1]
    if math.random() > 0.5 then
      effect_column.number_string = effect_command
      effect_column.amount_string = randomize()
    else
      effect_column:clear()
    end
  end

  if selection then
    for line_index = selection.start_line, selection.end_line do
      local line = pattern:track(track_index).lines[line_index]
      apply_command(line)
    end
  else
    for sequence_index, sequence in ipairs(song.sequencer.pattern_sequence) do
      if song:pattern(sequence).tracks[track_index] then
        local lines = song:pattern(sequence).number_of_lines
        for line_index = 1, lines do
          local line = song:pattern(sequence).tracks[track_index].lines[line_index]
          apply_command(line)
        end
      end
    end
  end

  renoise.app():show_status("Random " .. effect_command .. " commands applied to the first effect column of the selected track.")
end
]]--
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Smatter (C00/C0F)", invoke=function() randomizeSmatterEffectColumnCustom("0C", false, 0x00, 0xFF) end}
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Smatter (0G Glide)",invoke=function() randomizeSmatterEffectColumnCustom("0G", false, 0x00, 0xFF) end}
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Smatter (0U Slide Up)",invoke=function() randomizeSmatterEffectColumnCustom("0U", false, 0x00, 0xFF) end}
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Smatter (0D Slide Down)",invoke=function() randomizeSmatterEffectColumnCustom("0D", false, 0x00, 0xFF) end}
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Smatter (0R Retrig)",invoke=function() randomizeSmatterEffectColumnCustom("0R", false, 0x00, 0xFF) end}
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Smatter (0P Panning)",invoke=function() randomizeSmatterEffectColumnCustom("0P", false,0x00, 0xFF) end}
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Smatter (0B00/0B01)",invoke=function() randomizeSmatterEffectColumnCustom("0B", false, 0x00, 0xFF) end}


renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Fill (C00/C0F)", invoke=function() randomizeSmatterEffectColumnCustom("0C", true, 0x00, 0xFF) end}
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Fill (0G Glide)",invoke=function() randomizeSmatterEffectColumnCustom("0G", true, 0x00, 0xFF) end}
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Fill (0U Slide Up)",invoke=function() randomizeSmatterEffectColumnCustom("0U", true, 0x00, 0xFF) end}
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Fill (0D Slide Down)",invoke=function() randomizeSmatterEffectColumnCustom("0D", true, 0x00, 0xFF) end}
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Fill (0R Retrig)",invoke=function() randomizeSmatterEffectColumnCustom("0R", true, 0x00, 0xFF) end}
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Fill (0P Panning)",invoke=function() randomizeSmatterEffectColumnCustom("0P", true,0x00, 0xFF) end}
renoise.tool():add_keybinding{name="Global:Tools:Randomize Effect Column Fill (0B00/0B01)",invoke=function() randomizeSmatterEffectColumnCustom("0B", true, 0x00, 0xFF) end}


























---------







------------------------

function PakettiCreateUnisonSamples()
-- HELLO THIS IS 21st July 2024 08.07am Finnish time calling
  local song = renoise.song()
  local selected_instrument_index = song.selected_instrument_index
  local instrument = song.selected_instrument
  
  if not instrument then
    renoise.app():show_status("No instrument selected.")
    return
  end

  if #instrument.samples == 0 then
    renoise.app():show_status("The selected instrument has no samples.")
    return
  end

  if #instrument.samples == 1 then
    local original_instrument = instrument
    local original_sample = original_instrument.samples[1]
    local original_sample_name = original_sample.name
    local original_instrument_name = original_instrument.name
    original_sample.loop_mode = 2
    -- Create a new instrument underneath the selected instrument
    local new_instrument_index = selected_instrument_index + 1
    song:insert_instrument_at(new_instrument_index)
    song.selected_instrument_index = new_instrument_index
    local new_instrument = renoise.song().selected_instrument
    
    pakettiPreferencesDefaultInstrumentLoader()
    
    if preferences.pakettiPitchbendLoaderEnvelope.value then
renoise.song().selected_instrument.sample_modulation_sets[1].devices[2].is_active = true else end

    
    -- Copy sample buffer from the original instrument to the new instrument
    renoise.song().selected_instrument.samples[1]:copy_from(original_sample)
    
    -- Rename the new instrument to match the original instrument's name
    renoise.song().selected_instrument.name = original_instrument.name .. " (Unison)"
--    new_instrument.name = original_instrument_name
    local og=renoise.song().selected_instrument_index-1
    local original_sample_index = renoise.song().instruments[og].samples[1]
    -- Create 7 additional sample slots.
    for i = 2, 8 do
      renoise.song().selected_instrument:insert_sample_at(i)
      local new_sample = renoise.song().selected_instrument:sample(i)
      renoise.song().selected_instrument.samples[i]:copy_from(renoise.song().selected_instrument.samples[1])
      renoise.song().selected_instrument.samples[i].loop_mode = 2
    end
    
    -- Define the finetune adjustments.
    local finetune_values = {-3, -2, -1, 1, 2, 3, 4}
    local fraction_values = {1/8, 2/8, 3/8, 4/8, 5/8, 6/8, 7/8}
    
    -- Adjust finetune and sample buffer content.
    for i = 2, 8 do
      local sample = renoise.song().selected_instrument.samples[i]
      local new_sample_buffer = sample.sample_buffer
      local fraction = fraction_values[i - 1]
      
      -- Adjust finetune, force Forwards
      if i <= 8 then
        sample.fine_tune = finetune_values[i - 1] or 0
        sample.loop_mode = 2
      end
      
      -- Adjust sample buffer.
      if original_sample.sample_buffer.has_sample_data then
        new_sample_buffer:prepare_sample_data_changes()
        for channel = 1, original_sample.sample_buffer.number_of_channels do
          for frame = 1, original_sample.sample_buffer.number_of_frames do
            local new_frame_index = frame + math.floor(original_sample.sample_buffer.number_of_frames * fraction)
            if new_frame_index > original_sample.sample_buffer.number_of_frames then
              new_frame_index = new_frame_index - original_sample.sample_buffer.number_of_frames
            end
            new_sample_buffer:set_sample_data(channel, new_frame_index, original_sample.sample_buffer:sample_data(channel, frame))
          end
        end
        new_sample_buffer:finalize_sample_data_changes()
      end
      
      -- Rename the sample to match the original sample's name
      sample.name = string.format("%s (Unison %d [%d])", original_sample_name, i - 1, sample.fine_tune)
    end
    
    -- Set the volume to -7 dB for each sample in the instrument.
    local volume = math.db2lin(-14)
    for i = 1, #renoise.song().selected_instrument.samples do
      renoise.song().selected_instrument.samples[i].volume = volume
    end
  else
    renoise.app():show_status("Cannot create Unison because Instrument has more than 1 Sample.")
  end
  
local info=""
local loop_modes={"No Loop","Forward","Backward","PingPong"}
for i=1,#renoise.song().selected_instrument.samples do
  local sample=renoise.song().selected_instrument.samples[i]
    renoise.song().selected_instrument.samples[i].device_chain_index=1


  sample.loop_mode = 2
end
  
  
  
end

-- Adding keybinding and menu entries
renoise.tool():add_keybinding{name="Global:Paketti:Paketti Unison Generator",invoke=PakettiCreateUnisonSamples}
renoise.tool():add_menu_entry{name="Sample Navigator:Paketti..:Unison Generator",invoke=PakettiCreateUnisonSamples}
renoise.tool():add_menu_entry{name="Sample Editor:Paketti..:Unison Generator",invoke=PakettiCreateUnisonSamples}
renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Unison Generator",invoke=PakettiCreateUnisonSamples}
renoise.tool():add_menu_entry{name="Instrument Box:Paketti..:Unison Generator",invoke=PakettiCreateUnisonSamples}













local vb=renoise.ViewBuilder()
local column2=vb:column{style="group"}
local column3=vb:column{style="group"}
local hex_text2=vb:text{text="0", style="normal"}
local hex_text3=vb:text{text="0", style="normal"}
local combined_text1=vb:text{text="00", style="strong"}
local value_labels2={}
local value_labels3={}
local label_map2 = {}
local label_map3 = {}
local writing_enabled = false

local function update_combined_value()
  local combined_value=hex_text3.text..hex_text2.text
  combined_text1.text=combined_value
  renoise.app():show_status(combined_text1.text)

  if not renoise.song() or not writing_enabled then return end

  local song = renoise.song()
  local start_pos, end_pos
  local start_track, end_track

  if song.selection_in_pattern then
    start_pos = song.selection_in_pattern.start_line
    end_pos = song.selection_in_pattern.end_line
    start_track = song.selection_in_pattern.start_track
    end_track = song.selection_in_pattern.end_track
  else
    start_pos = song.selected_line_index
    end_pos = start_pos
    start_track = song.selected_track_index
    end_track = start_track
  end

  for track = start_track, end_track do
    for line = start_pos, end_pos do
      song:pattern(song.selected_pattern_index):track(track):line(line):effect_column(1).amount_string = combined_value
    end
  end
end

local function create_valuebox(i, column, hex_text, value_labels, label_map, position, id_prefix)
  local hex=string.format("%X",i)
  local label_id = id_prefix .. "_label_" .. hex
  local number_label=vb:text{text=hex, width=2,style="normal"}
  label_map[label_id] = number_label
  value_labels[#value_labels + 1] = number_label
  
  local valuebox=vb:valuebox{
    value=i,min=i,max=i,width=8,
    tostring=function(v)
      local hex_value=string.format("%X",v)
      hex_text.text=hex_value
      update_combined_value()
      for _, label in ipairs(value_labels) do 
        if label.text ~= hex_value then
          label.style="normal"
        end
      end
      number_label.style="strong"
      return hex_value
    end,
    tonumber=function(str)
      return tonumber(str,16)
    end,
    notifier=function(val)
      local hex_value=string.format("%X",val)
      for _, label in ipairs(value_labels) do 
        if label.text ~= hex_value then
          label.style="normal"
        end
      end
      label_map[id_prefix .. "_label_" .. hex_value].style = "strong"
    end
  }

  if position == "number_first" then
    column:add_child(vb:row{number_label,valuebox})
  elseif position == "valuebox_first" then
    column:add_child(vb:row{valuebox,number_label})
  end
end

for i=0,15 do
  create_valuebox(i, column3, hex_text3, value_labels3, label_map3, "number_first", "col3")
  create_valuebox(i, column2, hex_text2, value_labels2, label_map2, "valuebox_first", "col2")
end

-- Ensure that all text styles are "normal" at the start
for _, label in ipairs(value_labels2) do
  label.style = "normal"
end

for _, label in ipairs(value_labels3) do
  label.style = "normal"
end

local separator = vb:space{width=10}

local dialog_content=vb:column{
  margin=10,
  vb:row{
    vb:checkbox{
      value = writing_enabled,
      notifier = function(val)
        writing_enabled = val
      end
    },
    vb:text{text="Write", style="strong"}
  },
  vb:row{
    vb:column{column3, vb:space{width=35}},
    vb:column{column2}
  },
  vb:horizontal_aligner{
    vb:row{combined_text1}
  }
}

--renoise.app():show_custom_dialog("FX", dialog_content)
































----
local vb = renoise.ViewBuilder()
local dialog

local note_names = {"C-", "C#", "D-", "D#", "E-", "F-", "F#", "G-", "G#", "A-", "A#", "B-"}
local notes = {}
for octave = 0, 9 do
  for _, note in ipairs(note_names) do
    table.insert(notes, note .. octave)
  end
end
table.insert(notes, "000") -- Adding "---" as "000"
table.insert(notes, "OFF")

local switch_group = {"Off", "Off"}
local volume_switch_group = {"Off", "Off"}

local effect_descriptions = {
  "0Axy - Arpeggio (x=base note offset1, y=base note offset 2) *",
  "0Uxx - Pitch Slide up (00-FF) *",
  "0Dxx - Pitch Slide down (00-FF) *",
  "0Mxx - Set Channel volume (00-FF)",
  "0Cxy - Volume slicer -- x=factor (0=0.0, F=1.0), slice at tick y. *",
  "0Gxx - Glide to note with step xx (00-FF)*",
  "0Ixx - Volume Slide Up with step xx (00-64) (64x0601 or 2x0632 = slide0-full) *",
  "0Oxx - Volume Slide Down with step xx (00-64) *",
  "0Pxx - Set Panning (00-FF) (00: left; 80: center; FF: right)",
  "0Sxx - Trigger Sample Offset, 00 is sample start, FF is sample end. *",
  "0Wxx - Surround Width (00-FF) *",
  "0Bxx - Play Sample Backwards (B00) or forwards again (B01) *",
  "0Lxx - Set track-Volume (00-FF)",
  "0Qxx - Delay notes in track-row xx ticks before playing. (00-speed)",
  "0Rxy - Retrig notes in track-row every xy ticks (x=volume; y=ticks 0 - speed) **",
  "0Vxy - Set Vibrato x= speed, y= depth; x=(0-F); y=(0-F)*",
  "0Txy - Set Tremolo x= speed, y= depth",
  "0Nxy - Set Auto Pan, x= speed, y= depth",
  "0Exx - Set Active Sample Envelope's Position to Offset XX",
  "0Jxx - Set Track's Output Routing to channel XX",
  "0Xxx - Stop all notes and FX (xx = 00), or only effect xx (xx > 00)"
}

local function update_instrument_popup()
  local instrument_items = {"<None>"}
  for i = 0, #renoise.song().instruments - 1 do
    local instrument = renoise.song().instruments[i + 1]
    table.insert(instrument_items, string.format("%02d: %s", i, (instrument.name or "Untitled")))
  end
  if vb.views["instrument_popup"] then
    vb.views["instrument_popup"].items = instrument_items
  end
end

local function pakettiPlayerProInsertIntoLine(line, col, note, instrument, effect, effect_argument, volume)
  if note then
    line:note_column(col).note_string = note
  end
  if instrument and note ~= "---" and note ~= "OFF" then
    line:note_column(col).instrument_value = instrument
  end
  if effect and effect ~= "Off" and note ~= "---" and note ~= "OFF" then
    line:effect_column(col).number_string = effect
    line:effect_column(col).amount_string = effect_argument ~= "Off" and effect_argument or ".."
  end
  if volume and volume ~= "Off" and note ~= "---" and note ~= "OFF" then
    line:note_column(col).volume_string = volume
  end
end

local function pakettiPlayerProInsertNoteInPattern(note, instrument, effect, effect_argument, volume)
  local song = renoise.song()
  local sel = song.selection_in_pattern
  local pattern_index = song.selected_pattern_index
  local note_to_insert = note == "000" and "---" or note
  local note_column_selected = false

  -- Debug logs
  print("Inserting note: " .. (note or "N/A"))
  if instrument then print("Instrument: " .. instrument) end
  if effect then print("Effect: " .. effect) end
  if effect_argument then print("Effect Argument: " .. effect_argument) end
  if volume then print("Volume: " .. volume) end

  if sel then
    print("Selection in pattern:")
    print("  start_track: " .. sel.start_track .. ", end_track: " .. sel.end_track)
    print("  start_line: " .. sel.start_line .. ", end_line: " .. sel.end_line)
    print("  start_column: " .. sel.start_column .. ", end_column: " .. sel.end_column)
  else
    print("No selection in pattern.")
  end

  if sel == nil then
    local line = song.selected_line
    local col = song.selected_note_column_index
    local visible_note_columns = song.selected_track.visible_note_columns
    if col > 0 and col <= visible_note_columns then
      pakettiPlayerProInsertIntoLine(line, col, note_to_insert, instrument, effect, effect_argument, volume)
      note_column_selected = true
      print("Inserted note (" .. (note_to_insert or "N/A") .. ") at track " .. song.selected_track_index .. " (" .. song.selected_track.name .. "), line " .. song.selected_line_index .. ", column " .. col)
    end
  else
    for track_index = sel.start_track, sel.end_track do
      local pattern_track = song.patterns[pattern_index]:track(track_index)
      local visible_note_columns = song:track(track_index).visible_note_columns
      for line_index = sel.start_line, sel.end_line do
        local line = pattern_track:line(line_index)
        for col_index = 1, renoise.song().tracks[track_index].visible_note_columns do
          if (track_index > sel.start_track) or (col_index >= sel.start_column) then
            if col_index <= visible_note_columns then
              pakettiPlayerProInsertIntoLine(line, col_index, note_to_insert, instrument, effect, effect_argument, volume)
              note_column_selected = true
              print("Inserted note (" .. (note_to_insert or "N/A") .. ") at track " .. track_index .. " (" .. song:track(track_index).name .. "), line " .. line_index .. ", column " .. col_index)
            end
          end
        end
      end
    end
  end

  if not note_column_selected then
    local message = "No Note Columns were selected, doing nothing."
    print(message)
    renoise.app():show_status(message)
  end
end

local function pakettiPlayerProCreateNoteGrid()
  local grid_rows = 11
  local grid_columns = 12
  local grid = vb:column{}
  for row = 1, grid_rows do
    local row_items = vb:row{}
    for col = 1, grid_columns do
      local index = (row - 1) * grid_columns + col
      if notes[index] then
        row_items:add_child(vb:button{
          text = notes[index],
          width = 30,
          height = 15,
          notifier = function()
            local instrument_value = vb.views["instrument_popup"].value - 2
            local instrument = instrument_value >= 0 and instrument_value or nil
            local effect = vb.views["effect_popup"].value > 1 and vb.views["effect_popup"].items[vb.views["effect_popup"].value] or nil
            local effect_argument = vb.views["effect_argument_display"].text
            local volume = vb.views["volume_display"].text
            pakettiPlayerProInsertNoteInPattern(notes[index], instrument, effect, effect_argument, volume)
            print("Inserted: " .. notes[index])
            -- Return focus to the Pattern Editor
            renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
          end
        })
      end
    end
    grid:add_child(row_items)
  end
  return grid
end

local function pakettiPlayerProCreateArgumentColumn(column_index, switch_group, update_display)
  return vb:switch{
    items = {"Off", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"},
    width = 200,
    height = 30,
    value = 1, -- default to "Off"
    notifier = function(idx)
      switch_group[column_index] = idx == 1 and "Off" or string.format("%X", idx - 1)
      update_display()
    end
  }
end

local function pakettiPlayerProUpdateEffectArgumentDisplay()
  local arg_display = switch_group[1] .. switch_group[2]
  vb.views["effect_argument_display"].text = arg_display == "OffOff" and ".." or arg_display
end

local function pakettiPlayerProUpdateVolumeDisplay()
  local vol_display = volume_switch_group[1] .. volume_switch_group[2]
  vb.views["volume_display"].text = vol_display == "OffOff" and ".." or vol_display
end

local function pakettiPlayerProShowMainDialog()
  local instrument_items = {"<None>"}
  for i = 0, #renoise.song().instruments - 1 do
    local instrument = renoise.song().instruments[i + 1]
    table.insert(instrument_items, string.format("%02d: %s", i, (instrument.name or "Untitled")))
  end

  local dialog_content = vb:column{
    margin = 10,
    vb:row{
      vb:text{
        text = "Instrument:"
      },
      vb:popup{
        items = instrument_items,
        width = 200,
        id = "instrument_popup"
      },
      vb:button{
        text = "Refresh",
        width = 100,
        notifier = function()
          update_instrument_popup()
        end
      }
    },
    vb:row{
      vb:text{
        text = "Note:"
      },
      pakettiPlayerProCreateNoteGrid()
    },
    vb:row{
      vb:text{
        text = "Effect:"
      },
      vb:popup{
        items = {"None", "Effect 1", "Effect 2", "Effect 3"}, -- Add actual effects here
        width = 200,
        id = "effect_popup"
      }
    },
    vb:row{
      vb:text{
        text = "Argument:"
      },
      vb:row{
        vb:column{
          vb:text{text = "Volume"},
          pakettiPlayerProCreateArgumentColumn(1, volume_switch_group, pakettiPlayerProUpdateVolumeDisplay),
          vb:text{id = "volume_display", text = "..", width = 40, align = "center"},
        },
        vb:column{
          vb:text{text = "Volume"},
          pakettiPlayerProCreateArgumentColumn(2, volume_switch_group, pakettiPlayerProUpdateVolumeDisplay),
        },
        vb:column{},
        vb:column{
          vb:text{text = "Effect"},
          pakettiPlayerProCreateArgumentColumn(1, switch_group, pakettiPlayerProUpdateEffectArgumentDisplay),
          vb:text{id = "effect_argument_display", text = "..", width = 40, align = "center"},
        },
        vb:column{
          vb:text{text = "Effect"},
          pakettiPlayerProCreateArgumentColumn(2, switch_group, pakettiPlayerProUpdateEffectArgumentDisplay),
        },
      }
    },
    vb:row{
      spacing = 10,
      vb:button{
        text = "Apply",
        width = 100,
        notifier = function()
          local instrument_value = vb.views["instrument_popup"].value - 2
          local instrument = instrument_value >= 0 and instrument_value or nil
          local effect_value = vb.views["effect_popup"].value
          local effect = effect_value > 1 and vb.views["effect_popup"].items[effect_value] or nil
          local effect_argument = vb.views["effect_argument_display"].text
          local volume = vb.views["volume_display"].text
          -- Insert all selected values
          pakettiPlayerProInsertNoteInPattern(nil, instrument, effect, effect_argument, volume)
          -- Return focus to the Pattern Editor
          renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        end
      },
      vb:button{
        text = "Cancel",
        width = 100,
        notifier = function()
          dialog:close()
        end
      }
    }
  }

  local function my_keyhandler_func(dialog, key)
    if not (key.modifiers == "" and key.name == "exclamation") then
      return key
    else
      dialog:close()
    end
  end

  dialog = renoise.app():show_custom_dialog("Player Pro Main Dialog", dialog_content, my_keyhandler_func)
end

renoise.tool():add_menu_entry{name = "Pattern Editor:Paketti..:Open Player Pro Tools Dialog", invoke = pakettiPlayerProShowMainDialog}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Open Player Pro Tools Dialog", invoke = pakettiPlayerProShowMainDialog}


-----------
















--------------

























-- Utility function to check if a table contains a value
function table_contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

-- Function to unmute all tracks and send tracks except the master track
function PakettiToggleSoloTracksUnmuteAllTracks()
  local song = renoise.song()
  local total_track_count = song.sequencer_track_count + 1 + song.send_track_count

  print("----")
  print("Unmuting all tracks")
  for i = 1, total_track_count do
    if song:track(i).type ~= renoise.Track.TRACK_TYPE_MASTER then
      song:track(i).mute_state = renoise.Track.MUTE_STATE_ACTIVE
      print("Unmuting track index: " .. i .. " (" .. song:track(i).name .. ")")
    end
  end
end

-- Function to mute all tracks except a specific range, and not the master track
function PakettiToggleSoloTracksMuteAllExceptRange(start_track, end_track)
  local song = renoise.song()
  local total_track_count = song.sequencer_track_count + 1 + song.send_track_count
  local group_parents = {}

  print("----")
  print("Muting all tracks except range: " .. start_track .. " to " .. end_track)
  for i = start_track, end_track do
    if song:track(i).group_parent then
      local group_parent = song:track(i).group_parent.name
      if not table_contains(group_parents, group_parent) then
        table.insert(group_parents, group_parent)
      end
    end
  end

  for i = 1, total_track_count do
    if song:track(i).type ~= renoise.Track.TRACK_TYPE_MASTER then
      if i < start_track or i > end_track then
        song:track(i).mute_state = renoise.Track.MUTE_STATE_OFF
        print("Muting track index: " .. i .. " (" .. song:track(i).name .. ")")
      end
    end
  end

  for i = start_track, end_track do
    if song:track(i).type ~= renoise.Track.TRACK_TYPE_MASTER then
      song:track(i).mute_state = renoise.Track.MUTE_STATE_ACTIVE
      print("Unmuting track index: " .. i .. " (" .. song:track(i).name .. ")")
    end
  end

  for _, group_parent_name in ipairs(group_parents) do
    local group_parent_index = nil
    for i = 1, song.sequencer_track_count do
      if song:track(i).name == group_parent_name then
        group_parent_index = i
        break
      end
    end
    if group_parent_index then
      local group_parent = song:track(group_parent_index)
      group_parent.mute_state = renoise.Track.MUTE_STATE_ACTIVE
      print("Unmuting group track: " .. group_parent.name)
    end
  end
end

-- Function to mute all tracks except a specific track and its group, and not the master track
function PakettiToggleSoloTracksMuteAllExceptSelectedTrack(track_index)
  local song = renoise.song()
  local total_track_count = song.sequencer_track_count + 1 + song.send_track_count
  local selected_track = song:track(track_index)
  local group_tracks = {}

  print("----")
  print("Muting all tracks except selected track: " .. track_index .. " (" .. selected_track.name .. ")")

  if selected_track.type == renoise.Track.TRACK_TYPE_GROUP then
    table.insert(group_tracks, track_index)
    print("Group name is " .. selected_track.name .. ", Number of Members is " .. #selected_track.members)
    for i = track_index + 1, track_index + #selected_track.members do
      if song:track(i).group_parent and song:track(i).group_parent.name == selected_track.name then
        table.insert(group_tracks, i)
        print("Member index: " .. i .. " (" .. song:track(i).name .. ")")
      else
        break
      end
    end
  elseif selected_track.group_parent then
    local group_parent = selected_track.group_parent.name
    for i = 1, song.sequencer_track_count do
      if song:track(i).type == renoise.Track.TRACK_TYPE_GROUP and song:track(i).name == group_parent then
        table.insert(group_tracks, i)
        print("Group parent: " .. group_parent .. " at index " .. i)
        break
      end
    end
    table.insert(group_tracks, track_index)
    print("Member index: " .. track_index .. " (" .. selected_track.name .. ")")
  else
    table.insert(group_tracks, track_index)
    print("Single track index: " .. track_index .. " (" .. selected_track.name .. ")")
  end

  for i = 1, total_track_count do
    if song:track(i).type ~= renoise.Track.TRACK_TYPE_MASTER and not table_contains(group_tracks, i) then
      song:track(i).mute_state = renoise.Track.MUTE_STATE_OFF
      print("Muting track index: " .. i .. " (" .. song:track(i).name .. ")")
    end
  end

  for _, group_track in ipairs(group_tracks) do
    if song:track(group_track).type ~= renoise.Track.TRACK_TYPE_MASTER then
      song:track(group_track).mute_state = renoise.Track.MUTE_STATE_ACTIVE
      print("Unmuting track index: " .. group_track .. " (" .. song:track(group_track).name .. ")")
    end
  end
end

-- Function to check if all tracks and send tracks are unmuted
function PakettiToggleSoloTracksAllTracksUnmuted()
  local song = renoise.song()
  local total_track_count = song.sequencer_track_count + 1 + song.send_track_count

  for i = 1, total_track_count do
    if song:track(i).type ~= renoise.Track.TRACK_TYPE_MASTER and song:track(i).mute_state ~= renoise.Track.MUTE_STATE_ACTIVE then
      return false
    end
  end
  return true
end

-- Function to check if all tracks except the selected track and its group are muted
function PakettiToggleSoloTracksAllOthersMutedExceptSelected(track_index)
  local song = renoise.song()
  local selected_track = song:track(track_index)
  local group_tracks = {}
  local total_track_count = song.sequencer_track_count + 1 + song.send_track_count

  if selected_track.type == renoise.Track.TRACK_TYPE_GROUP then
    table.insert(group_tracks, track_index)
    for i = track_index + 1, song.sequencer_track_count do
      if song:track(i).group_parent and song:track(i).group_parent.name == selected_track.name then
        table.insert(group_tracks, i)
      else
        break
      end
    end
  elseif selected_track.group_parent then
    local group_parent = selected_track.group_parent.name
    for i = 1, song.sequencer_track_count do
      if song:track(i).type == renoise.Track.TRACK_TYPE_GROUP and song:track(i).name == group_parent then
        table.insert(group_tracks, i)
        break
      end
    end
    table.insert(group_tracks, track_index)
  else
    table.insert(group_tracks, track_index)
  end

  for i = 1, total_track_count do
    if song:track(i).type ~= renoise.Track.TRACK_TYPE_MASTER and not table_contains(group_tracks, i) and song:track(i).mute_state ~= renoise.Track.MUTE_STATE_OFF then
      return false
    end
  end
  return selected_track.mute_state == renoise.Track.MUTE_STATE_ACTIVE
end

-- Function to check if all tracks except the selected range are muted
function PakettiToggleSoloTracksAllOthersMutedExceptRange(start_track, end_track)
  local song = renoise.song()
  local total_track_count = song.sequencer_track_count + 1 + song.send_track_count
  local group_parents = {}

  print("Selection In Pattern is from index " .. start_track .. " to index " .. end_track)
  for i = start_track, end_track do
    print("Track index: " .. i .. " (" .. song:track(i).name .. ")")
    if song:track(i).group_parent then
      local group_parent = song:track(i).group_parent.name
      if not table_contains(group_parents, group_parent) then
        table.insert(group_parents, group_parent)
        print("Group parent: " .. group_parent)
      end
    end
  end

  for i = 1, total_track_count do
    if song:track(i).type ~= renoise.Track.TRACK_TYPE_MASTER and (i < start_track or i > end_track) and song:track(i).mute_state ~= renoise.Track.MUTE_STATE_OFF then
      return false
    end
  end
  for i = start_track, end_track do
    if song:track(i).mute_state ~= renoise.Track.MUTE_STATE_ACTIVE then
      return false
    end
  end

  for _, group_parent_name in ipairs(group_parents) do
    local group_parent_index = nil
    for i = 1, song.sequencer_track_count do
      if song:track(i).name == group_parent_name then
        group_parent_index = i
        break
      end
    end
    if group_parent_index then
      local group_parent = song:track(group_parent_index)
      if group_parent.mute_state ~= renoise.Track.MUTE_STATE_ACTIVE then
        return false
      end
    end
  end
  return true
end

-- Main function to toggle mute states
function PakettiToggleSoloTracks()
  local song = renoise.song()
  local sip = song.selection_in_pattern
  local selected_track_index = song.selected_track_index
  local selected_track = song:track(selected_track_index)

  print("----")
  print("Running PakettiToggleSoloTracks")

  if sip then
    -- If a selection in pattern exists
    print("Selection In Pattern is from index " .. sip.start_track .. " to " .. sip.end_track)
    for i = sip.start_track, sip.end_track do
      print("Track index: " .. i .. " (" .. song:track(i).name .. ")")
    end
    if PakettiToggleSoloTracksAllOthersMutedExceptRange(sip.start_track, sip.end_track) then
      print("Detecting all-tracks-should-be-unmuted situation")
      PakettiToggleSoloTracksUnmuteAllTracks()
    else
      print("Detecting Muting situation")
      PakettiToggleSoloTracksMuteAllExceptRange(sip.start_track, sip.end_track)
    end
  elseif selected_track.type == renoise.Track.TRACK_TYPE_GROUP then
    -- If the selected track is a group, mute all tracks and then unmute the group and its members
    print("Selected track is a group")
    print("Group name is " .. selected_track.name .. ", Number of Members is " .. #selected_track.members)
    if PakettiToggleSoloTracksAllOthersMutedExceptSelected(selected_track_index) then
      print("Detecting all-tracks-should-be-unmuted situation")
      PakettiToggleSoloTracksUnmuteAllTracks()
    else
      for i = 1, song.sequencer_track_count + song.send_track_count do
        if song:track(i).type ~= renoise.Track.TRACK_TYPE_MASTER then
          song:track(i).mute_state = renoise.Track.MUTE_STATE_OFF
          print("Muting track index: " .. i .. " (" .. song:track(i).name .. ")")
        end
      end
      for i = selected_track_index - #selected_track.members, selected_track_index do
        song:track(i).mute_state = renoise.Track.MUTE_STATE_ACTIVE
        print("Unmuting track index: " .. i .. " (" .. song:track(i).name .. ")")
      end
    end
  else
    -- If no selection in pattern and selected track is not a group
    print("No selection in pattern, using selected track: " .. selected_track_index .. " (" .. selected_track.name .. ")")
    if PakettiToggleSoloTracksAllOthersMutedExceptSelected(selected_track_index) then
      print("Detecting all-tracks-should-be-unmuted situation")
      PakettiToggleSoloTracksUnmuteAllTracks()
    else
      print("Detecting Muting situation")
      PakettiToggleSoloTracksMuteAllExceptSelectedTrack(selected_track_index)
    end
  end
end

-- Add menu entry, keybinding, and MIDI mapping for the toggle solo tracks function
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Pattern Editor:Toggle Solo Tracks",invoke=PakettiToggleSoloTracks}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Toggle Solo Tracks",invoke=PakettiToggleSoloTracks}
renoise.tool():add_keybinding{name="Global:Paketti:Toggle Solo Tracks",invoke=PakettiToggleSoloTracks}
renoise.tool():add_midi_mapping{name="Paketti:Toggle Solo Tracks",invoke=PakettiToggleSoloTracks}










--------
-- Function to initialize selection if it is nil
function PakettiImpulseTrackerShiftInitializeSelection()
  local song = renoise.song()
  local pos = song.transport.edit_pos
  local selected_track_index = song.selected_track_index
  local selected_column_index = song.selected_note_column_index > 0 and song.selected_note_column_index or song.selected_effect_column_index

  song.selection_in_pattern = {
    start_track = selected_track_index,
    end_track = selected_track_index,
    start_column = selected_column_index,
    end_column = selected_column_index,
    start_line = pos.line,
    end_line = pos.line
  }
end

-- Function to ensure selection is valid and swap if necessary
function PakettiImpulseTrackerShiftEnsureValidSelection()
  local song = renoise.song()
  local selection = song.selection_in_pattern

  if selection.start_track > selection.end_track then
    local temp = selection.start_track
    selection.start_track = selection.end_track
    selection.end_track = temp
  end

  if selection.start_column > selection.end_column then
    local temp = selection.start_column
    selection.start_column = selection.end_column
    selection.end_column = temp
  end

  if selection.start_line > selection.end_line then
    local temp = selection.start_line
    selection.start_line = selection.end_line
    selection.end_line = temp
  end

  song.selection_in_pattern = selection
end

-- Debug function to print selection details
local function debug_print_selection(message)
  local song = renoise.song()
  local selection = song.selection_in_pattern
  print(message)
print("--------")
  print("Start Track: " .. selection.start_track .. ", End Track: " .. selection.end_track)
  print("Start Column: " .. selection.start_column .. ", End Column: " .. selection.end_column)
  print("Start Line: " .. selection.start_line .. ", End Line: " .. selection.end_line)
print("--------")

end

-- Function to select the next column or track to the right
function PakettiImpulseTrackerShiftRight()
  local song = renoise.song()
  local selection = song.selection_in_pattern

  if not selection then
    PakettiImpulseTrackerShiftInitializeSelection()
    selection = song.selection_in_pattern
  end

  debug_print_selection("Before Right Shift")

  if song.selected_track_index == selection.end_track and (song.selected_note_column_index == selection.end_column or song.selected_effect_column_index == selection.end_column) then
    if selection.end_column < song:track(selection.end_track).visible_note_columns then
      selection.end_column = selection.end_column + 1
    elseif selection.end_track < #song.tracks then
      selection.end_track = selection.end_track + 1
      local track = song:track(selection.end_track)
      if track.visible_note_columns > 0 then
        selection.end_column = 1
      else
        selection.end_column = track.visible_effect_columns > 0 and 1 or 0
      end
    else
      renoise.app():show_status("You are on the last track. No more can be selected in that direction.")
      return
    end
  else
    if song.selected_track_index < selection.start_track then
      local temp_track = selection.start_track
      selection.start_track = selection.end_track
      selection.end_track = temp_track

      local temp_column = selection.start_column
      selection.start_column = selection.end_column
      selection.end_column = temp_column
    end
    selection.start_track = song.selected_track_index
    selection.start_column = song.selected_note_column_index > 0 and song.selected_note_column_index or song.selected_effect_column_index
  end

  PakettiImpulseTrackerShiftEnsureValidSelection()
  song.selection_in_pattern = selection

  if song:track(selection.end_track).visible_note_columns > 0 then
    song.selected_note_column_index = selection.end_column
  else
    song.selected_effect_column_index = selection.end_column
  end

  debug_print_selection("After Right Shift")
end

-- Function to select the previous column or track to the left
function PakettiImpulseTrackerShiftLeft()
  local song = renoise.song()
  local selection = song.selection_in_pattern

  if not selection then
    PakettiImpulseTrackerShiftInitializeSelection()
    selection = song.selection_in_pattern
  end

  debug_print_selection("Before Left Shift")

  if song.selected_track_index == selection.end_track and (song.selected_note_column_index == selection.end_column or song.selected_effect_column_index == selection.end_column) then
    if selection.end_column > 1 then
      selection.end_column = selection.end_column - 1
    elseif selection.end_track > 1 then
      selection.end_track = selection.end_track - 1
      local track = song:track(selection.end_track)
      if track.visible_note_columns > 0 then
        selection.end_column = track.visible_note_columns
      else
        selection.end_column = track.visible_effect_columns > 0 and track.visible_effect_columns or 0
      end
    else
      renoise.app():show_status("You are on the first track. No more can be selected in that direction.")
      return
    end
  else
    if song.selected_track_index > selection.start_track then
      local temp_track = selection.start_track
      selection.start_track = selection.end_track
      selection.end_track = temp_track

      local temp_column = selection.start_column
      selection.start_column = selection.end_column
      selection.end_column = temp_column
    end
    selection.start_track = song.selected_track_index
    selection.start_column = song.selected_note_column_index > 0 and song.selected_note_column_index or song.selected_effect_column_index
  end

  PakettiImpulseTrackerShiftEnsureValidSelection()
  song.selection_in_pattern = selection

  if song:track(selection.end_track).visible_note_columns > 0 then
    song.selected_note_column_index = selection.end_column
  else
    song.selected_effect_column_index = selection.end_column
  end

  debug_print_selection("After Left Shift")
end

-- Function to extend the selection down by one line
function PakettiImpulseTrackerShiftDown()
  local song = renoise.song()
  local selection = song.selection_in_pattern
  local current_pattern = song.selected_pattern_index

  if not selection then
    PakettiImpulseTrackerShiftInitializeSelection()
    selection = song.selection_in_pattern
  end

  debug_print_selection("Before Down Shift")

  if song.transport.edit_pos.line == selection.end_line then
    if selection.end_line < song:pattern(current_pattern).number_of_lines then
      selection.end_line = selection.end_line + 1
    else
      renoise.app():show_status("You are at the end of the pattern. No more can be selected.")
      return
    end
  else
    if song.transport.edit_pos.line < selection.start_line then
      local temp_line = selection.start_line
      selection.start_line = selection.end_line
      selection.end_line = temp_line
    end
    selection.start_line = song.transport.edit_pos.line
  end

  PakettiImpulseTrackerShiftEnsureValidSelection()
  song.selection_in_pattern = selection
  song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.end_line)

  debug_print_selection("After Down Shift")
end

-- Main function to determine which shift up function to call
function PakettiImpulseTrackerShiftUp()
  local song = renoise.song()
  local selection = song.selection_in_pattern

  if not selection then
    PakettiImpulseTrackerShiftInitializeSelection()
    selection = song.selection_in_pattern
  end

  if selection.start_column == selection.end_column then
    PakettiImpulseTrackerShiftUpSingleColumn()
  else
    PakettiImpulseTrackerShiftUpMultipleColumns()
  end
end

-- Function to extend the selection up by one line in a single column
function PakettiImpulseTrackerShiftUpSingleColumn()
  local song = renoise.song()
  local selection = song.selection_in_pattern
  local edit_pos = song.transport.edit_pos

  debug_print_selection("Before Up Shift (Single Column)")

  -- Determine the current column index based on the track type
  local current_column_index
  if song:track(song.selected_track_index).visible_note_columns > 0 then
    current_column_index = song.selected_note_column_index
  else
    current_column_index = song.selected_effect_column_index
  end

  -- Check if the cursor is within the current selection
  local cursor_in_selection = song.selected_track_index == selection.start_track and
                              song.selected_track_index == selection.end_track and
                              current_column_index == selection.start_column and
                              edit_pos.line >= selection.start_line and
                              edit_pos.line <= selection.end_line

  if not cursor_in_selection then
    -- Reset the selection to start from the current cursor position if the cursor is not within the selection
    selection.start_track = song.selected_track_index
    selection.end_track = song.selected_track_index
    selection.start_column = current_column_index
    selection.end_column = current_column_index
    selection.start_line = edit_pos.line
    selection.end_line = edit_pos.line

    if selection.start_line > 1 then
      selection.start_line = selection.start_line - 1
      song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.start_line)
    else
      renoise.app():show_status("You are at the beginning of the pattern. No more can be selected.")
      return
    end
  else
    -- Extend the selection upwards if the cursor is within the selection
    if edit_pos.line == selection.end_line then
      if selection.end_line > selection.start_line then
        selection.end_line = selection.end_line - 1
        song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.end_line)
      elseif selection.end_line == selection.start_line then
        if selection.start_line > 1 then
          selection.start_line = selection.start_line - 1
          song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.start_line)
        else
          renoise.app():show_status("You are at the beginning of the pattern. No more can be selected.")
          return
        end
      end
    elseif edit_pos.line == selection.start_line then
      if selection.start_line > 1 then
        selection.start_line = selection.start_line - 1
        song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.start_line)
      else
        renoise.app():show_status("You are at the beginning of the pattern. No more can be selected.")
        return
      end
    else
      if edit_pos.line < selection.start_line then
        selection.start_line = edit_pos.line
        song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.start_line)
      else
        selection.end_line = edit_pos.line - 1
        song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.end_line)
      end
    end
  end

  -- Ensure start_line is always <= end_line
  if selection.start_line > selection.end_line then
    local temp = selection.start_line
    selection.start_line = selection.end_line
    selection.end_line = temp
  end

  PakettiImpulseTrackerShiftEnsureValidSelection()
  song.selection_in_pattern = selection

  debug_print_selection("After Up Shift (Single Column)")
end

-- Function to extend the selection up by one line in multiple columns
function PakettiImpulseTrackerShiftUpMultipleColumns()
  local song = renoise.song()
  local selection = song.selection_in_pattern
  local edit_pos = song.transport.edit_pos

  -- Print separator and current state
  print("----")
  print("Before Up Shift (Multiple Columns)")
  print("Current Line Index: " .. edit_pos.line)
  print("Start Track: " .. selection.start_track .. ", End Track: " .. selection.end_track)
  print("Start Column: " .. selection.start_column .. ", End Column: " .. selection.end_column)
  print("Start Line: " .. selection.start_line .. ", End Line: " .. selection.end_line)

  -- Determine the current column index based on the track type
  local current_column_index
  if song:track(song.selected_track_index).visible_note_columns > 0 then
    current_column_index = song.selected_note_column_index
  else
    current_column_index = song.selected_effect_column_index
  end

  -- Print the current column index and edit position line
  print("Current Column Index: " .. current_column_index)
  print("Edit Position Line: " .. edit_pos.line)

  -- Check if the cursor is within the current selection
  local cursor_in_selection = song.selected_track_index == selection.start_track and
                              song.selected_track_index == selection.end_track and
                              current_column_index >= selection.start_column and
                              current_column_index <= selection.end_column and
                              edit_pos.line >= selection.start_line and
                              edit_pos.line <= selection.end_line

  print("Cursor in Selection: " .. tostring(cursor_in_selection))

  if not cursor_in_selection then
    -- Reset the selection to start from the current cursor position if the cursor is not within the selection
    print("Cursor not in selection, resetting selection.")
    selection.start_track = song.selected_track_index
    selection.end_track = song.selected_track_index
    selection.start_column = current_column_index
    selection.end_column = current_column_index
    selection.start_line = edit_pos.line
    selection.end_line = edit_pos.line

    if selection.start_line > 1 then
      selection.start_line = selection.start_line - 1
      song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.start_line)
    else
      renoise.app():show_status("You are at the beginning of the pattern. No more can be selected.")
      return
    end
  else
    -- Extend the selection upwards if the cursor is within the selection
    print("Cursor in selection, extending selection upwards.")
    if edit_pos.line == selection.end_line and current_column_index == selection.end_column then
      if selection.end_line > selection.start_line then
        print("Decrementing end_line")
        selection.end_line = selection.end_line - 1
        song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.end_line)
      elseif selection.start_line > 1 then
        print("Decrementing start_line")
        selection.start_line = selection.start_line - 1
        song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.start_line)
      else
        renoise.app():show_status("You are at the beginning of the pattern. No more can be selected.")
        return
      end
    elseif edit_pos.line == selection.start_line and current_column_index == selection.start_column then
      if selection.start_line > 1 then
        print("Decrementing start_line")
        selection.start_line = selection.start_line - 1
        song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.start_line)
      else
        renoise.app():show_status("You are at the beginning of the pattern. No more can be selected.")
        return
      end
    else
      if edit_pos.line < selection.start_line then
        print("Adjusting start_line to edit position")
        selection.start_line = edit_pos.line
        song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.start_line)
      else
        print("Adjusting end_line to edit position")
        selection.end_line = edit_pos.line
        song.transport.edit_pos = renoise.SongPos(song.selected_sequence_index, selection.end_line)
      end
    end
  end

  -- Ensure start_line is always <= end_line
  if selection.start_line > selection.end_line then
    print("Swapping start_line and end_line to ensure start_line <= end_line")
    local temp = selection.start_line
    selection.start_line = selection.end_line
    selection.end_line = temp
  end

  PakettiImpulseTrackerShiftEnsureValidSelection()
  song.selection_in_pattern = selection

  -- Print separator and current state after the operation
  print("After Up Shift (Multiple Columns)")
  print("Current Line Index: " .. song.transport.edit_pos.line)
  print("Start Track: " .. selection.start_track .. ", End Track: " .. selection.end_track)
  print("Start Column: " .. selection.start_column .. ", End Column: " .. selection.end_column)
  print("Start Line: " .. selection.start_line .. ", End Line: " .. selection.end_line)
  print("----")
end


















-- Add key bindings for the functions
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker Shift-Right Selection In Pattern",invoke=PakettiImpulseTrackerShiftRight}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker Shift-Left Selection In Pattern",invoke=PakettiImpulseTrackerShiftLeft}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker Shift-Down Selection In Pattern",invoke=PakettiImpulseTrackerShiftDown}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker Shift-Up Selection In Pattern",invoke=PakettiImpulseTrackerShiftUp}


-- Function to copy a single note column
function PakettiImpulseTrackerSlideSelectedNoteColumnCopy(src, dst)
  if src and dst then
    dst.note_value = src.note_value
    dst.instrument_value = src.instrument_value
    dst.volume_value = src.volume_value
    dst.panning_value = src.panning_value
    dst.delay_value = src.delay_value
    dst.effect_number_value = src.effect_number_value
    dst.effect_amount_value = src.effect_amount_value
  elseif dst then
    dst:clear()
  end
end

-- Function to copy a single effect column
function PakettiImpulseTrackerSlideSelectedEffectColumnCopy(src, dst)
  if src and dst then
    dst.number_value = src.number_value
    dst.amount_value = src.amount_value
  elseif dst then
    dst:clear()
  end
end

-- Slide selected column content down by one row in the current pattern
function PakettiImpulseTrackerSlideSelectedColumnDown()
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local track_index = song.selected_track_index
  local pattern = song:pattern(pattern_index)
  local track = pattern:track(track_index)
  local number_of_lines = pattern.number_of_lines
  local column_index = song.selected_note_column_index
  local is_note_column = column_index > 0

  if not is_note_column then
    column_index = song.selected_effect_column_index
  end

  -- Store the content of the last row to move it to the first row
  local last_row_content
  if is_note_column then
    last_row_content = track:line(number_of_lines).note_columns[column_index]
  else
    last_row_content = track:line(number_of_lines).effect_columns[column_index]
  end

  -- Slide content down
  for line = number_of_lines, 2, -1 do
    local src_line = track:line(line - 1)
    local dst_line = track:line(line)
    if is_note_column then
      PakettiImpulseTrackerSlideSelectedNoteColumnCopy(src_line.note_columns[column_index], dst_line.note_columns[column_index])
    else
      PakettiImpulseTrackerSlideSelectedEffectColumnCopy(src_line.effect_columns[column_index], dst_line.effect_columns[column_index])
    end
  end

  -- Move the last row content to the first row and clear the last row
  local first_line = track:line(1)
  if is_note_column then
    PakettiImpulseTrackerSlideSelectedNoteColumnCopy(last_row_content, first_line.note_columns[column_index])
    track:line(number_of_lines).note_columns[column_index]:clear()
  else
    PakettiImpulseTrackerSlideSelectedEffectColumnCopy(last_row_content, first_line.effect_columns[column_index])
    track:line(number_of_lines).effect_columns[column_index]:clear()
  end
end

-- Slide selected column content up by one row in the current pattern
function PakettiImpulseTrackerSlideSelectedColumnUp()
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local track_index = song.selected_track_index
  local pattern = song:pattern(pattern_index)
  local track = pattern:track(track_index)
  local number_of_lines = pattern.number_of_lines
  local column_index = song.selected_note_column_index
  local is_note_column = column_index > 0

  if not is_note_column then
    column_index = song.selected_effect_column_index
  end

  -- Store the content of the first row to move it to the last row
  local first_row_content
  if is_note_column then
    first_row_content = track:line(1).note_columns[column_index]
  else
    first_row_content = track:line(1).effect_columns[column_index]
  end

  -- Slide content up
  for line = 1, number_of_lines - 1 do
    local src_line = track:line(line + 1)
    local dst_line = track:line(line)
    if is_note_column then
      PakettiImpulseTrackerSlideSelectedNoteColumnCopy(src_line.note_columns[column_index], dst_line.note_columns[column_index])
    else
      PakettiImpulseTrackerSlideSelectedEffectColumnCopy(src_line.effect_columns[column_index], dst_line.effect_columns[column_index])
    end
  end

  -- Move the first row content to the last row and clear the first row
  local last_line = track:line(number_of_lines)
  if is_note_column then
    PakettiImpulseTrackerSlideSelectedNoteColumnCopy(first_row_content, last_line.note_columns[column_index])
    track:line(1).note_columns[column_index]:clear()
  else
    PakettiImpulseTrackerSlideSelectedEffectColumnCopy(first_row_content, last_line.effect_columns[column_index])
    track:line(1).effect_columns[column_index]:clear()
  end
end

-- Functions to slide selected columns up or down within a selection
local function slide_selected_columns_up(track, start_line, end_line, selected_note_columns, selected_effect_columns)
  local first_row_content_note_columns = {}
  local first_row_content_effect_columns = {}

  for _, column_index in ipairs(selected_note_columns) do
    first_row_content_note_columns[column_index] = track:line(start_line).note_columns[column_index]
  end
  for _, column_index in ipairs(selected_effect_columns) do
    first_row_content_effect_columns[column_index] = track:line(start_line).effect_columns[column_index]
  end

  for line = start_line, end_line - 1 do
    local src_line = track:line(line + 1)
    local dst_line = track:line(line)
    for _, column_index in ipairs(selected_note_columns) do
      PakettiImpulseTrackerSlideSelectedNoteColumnCopy(src_line.note_columns[column_index], dst_line.note_columns[column_index])
    end
    for _, column_index in ipairs(selected_effect_columns) do
      PakettiImpulseTrackerSlideSelectedEffectColumnCopy(src_line.effect_columns[column_index], dst_line.effect_columns[column_index])
    end
  end

  local last_line = track:line(end_line)
  for _, column_index in ipairs(selected_note_columns) do
    PakettiImpulseTrackerSlideSelectedNoteColumnCopy(first_row_content_note_columns[column_index], last_line.note_columns[column_index])
    track:line(start_line).note_columns[column_index]:clear()
  end
  for _, column_index in ipairs(selected_effect_columns) do
    PakettiImpulseTrackerSlideSelectedEffectColumnCopy(first_row_content_effect_columns[column_index], last_line.effect_columns[column_index])
    track:line(start_line).effect_columns[column_index]:clear()
  end
end

local function slide_selected_columns_down(track, start_line, end_line, selected_note_columns, selected_effect_columns)
  local last_row_content_note_columns = {}
  local last_row_content_effect_columns = {}

  for _, column_index in ipairs(selected_note_columns) do
    last_row_content_note_columns[column_index] = track:line(end_line).note_columns[column_index]
  end
  for _, column_index in ipairs(selected_effect_columns) do
    last_row_content_effect_columns[column_index] = track:line(end_line).effect_columns[column_index]
  end

  for line = end_line, start_line + 1, -1 do
    local src_line = track:line(line - 1)
    local dst_line = track:line(line)
    for _, column_index in ipairs(selected_note_columns) do
      PakettiImpulseTrackerSlideSelectedNoteColumnCopy(src_line.note_columns[column_index], dst_line.note_columns[column_index])
    end
    for _, column_index in ipairs(selected_effect_columns) do
      PakettiImpulseTrackerSlideSelectedEffectColumnCopy(src_line.effect_columns[column_index], dst_line.effect_columns[column_index])
    end
  end

  local first_line = track:line(start_line)
  for _, column_index in ipairs(selected_note_columns) do
    PakettiImpulseTrackerSlideSelectedNoteColumnCopy(last_row_content_note_columns[column_index], first_line.note_columns[column_index])
  end
  for _, column_index in ipairs(selected_effect_columns) do
    PakettiImpulseTrackerSlideSelectedEffectColumnCopy(last_row_content_effect_columns[column_index], first_line.effect_columns[column_index])
  end
end

-- Function to get selected columns in the current selection
local function get_selected_columns(track, start_line, end_line)
  local selected_note_columns = {}
  local selected_effect_columns = {}

  for column_index = 1, #track:line(start_line).note_columns do
    for line = start_line, end_line do
      if track:line(line).note_columns[column_index].is_selected then
        table.insert(selected_note_columns, column_index)
        break
      end
    end
  end

  for column_index = 1, #track:line(start_line).effect_columns do
    for line = start_line, end_line do
      if track:line(line).effect_columns[column_index].is_selected then
        table.insert(selected_effect_columns, column_index)
        break
      end
    end
  end

  return selected_note_columns, selected_effect_columns
end

-- Slide selected column content down by one row or the selection if it exists
function PakettiImpulseTrackerSlideDown()
  local song = renoise.song()
  local selection = song.selection_in_pattern

  if selection then
    local pattern_index = song.selected_pattern_index
    local track_index = song.selected_track_index
    local pattern = song:pattern(pattern_index)
    local track = pattern:track(track_index)
    local start_line = selection.start_line
    local end_line = math.min(selection.end_line, pattern.number_of_lines)
    local selected_note_columns, selected_effect_columns = get_selected_columns(track, start_line, end_line)
    slide_selected_columns_down(track, start_line, end_line, selected_note_columns, selected_effect_columns)
  else
    PakettiImpulseTrackerSlideSelectedColumnDown()
  end
end

-- Slide selected column content up by one row or the selection if it exists
function PakettiImpulseTrackerSlideUp()
  local song = renoise.song()
  local selection = song.selection_in_pattern

  if selection then
    local pattern_index = song.selected_pattern_index
    local track_index = song.selected_track_index
    local pattern = song:pattern(pattern_index)
    local track = pattern:track(track_index)
    local start_line = selection.start_line
    local end_line = math.min(selection.end_line, pattern.number_of_lines)
    local selected_note_columns, selected_effect_columns = get_selected_columns(track, start_line, end_line)
    slide_selected_columns_up(track, start_line, end_line, selected_note_columns, selected_effect_columns)
  else
    PakettiImpulseTrackerSlideSelectedColumnUp()
  end
end

-- Add menu entry for sliding selected column content down
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Slide Selected Column Content Down",invoke=PakettiImpulseTrackerSlideDown}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Slide Selected Column Content Up",invoke=PakettiImpulseTrackerSlideUp}

renoise.tool():add_midi_mapping{name="Paketti:Slide Selected Column Content Down",invoke=PakettiImpulseTrackerSlideDown}
renoise.tool():add_midi_mapping{name="Paketti:Slide Selected Column Content Up",invoke=PakettiImpulseTrackerSlideUp}

renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Slide Selected Column Content Down",invoke=PakettiImpulseTrackerSlideDown}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Slide Selected Column Content Up",invoke=PakettiImpulseTrackerSlideUp}





--------------
-- Function to copy note columns
function PakettiImpulseTrackerSlideTrackCopyNoteColumns(src, dst)
  for i = 1, #src do
    if src[i] and dst[i] then
      dst[i].note_value = src[i].note_value
      dst[i].instrument_value = src[i].instrument_value
      dst[i].volume_value = src[i].volume_value
      dst[i].panning_value = src[i].panning_value
      dst[i].delay_value = src[i].delay_value
      dst[i].effect_number_value = src[i].effect_number_value
      dst[i].effect_amount_value = src[i].effect_amount_value
    elseif dst[i] then
      dst[i]:clear()
    end
  end
end

-- Function to copy effect columns
function PakettiImpulseTrackerSlideTrackCopyEffectColumns(src, dst)
  for i = 1, #src do
    if src[i] and dst[i] then
      dst[i].number_value = src[i].number_value
      dst[i].amount_value = src[i].amount_value
    elseif dst[i] then
      dst[i]:clear()
    end
  end
end

-- Slide selected track content down by one row in the current pattern
function PakettiImpulseTrackerSlideTrackDown()
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local track_index = song.selected_track_index
  local pattern = song:pattern(pattern_index)
  local track = pattern:track(track_index)
  local number_of_lines = pattern.number_of_lines

  -- Store the content of the last row to move it to the first row
  local last_row_note_columns = {}
  local last_row_effect_columns = {}

  for pos, column in song.pattern_iterator:note_columns_in_pattern_track(pattern_index, track_index) do
    if pos.line == number_of_lines then
      table.insert(last_row_note_columns, column)
    end
  end

  for pos, column in song.pattern_iterator:effect_columns_in_pattern_track(pattern_index, track_index) do
    if pos.line == number_of_lines then
      table.insert(last_row_effect_columns, column)
    end
  end

  -- Slide content down
  for line = number_of_lines, 2, -1 do
    local src_line = track:line(line - 1)
    local dst_line = track:line(line)
    PakettiImpulseTrackerSlideTrackCopyNoteColumns(src_line.note_columns, dst_line.note_columns)
    PakettiImpulseTrackerSlideTrackCopyEffectColumns(src_line.effect_columns, dst_line.effect_columns)
  end

  -- Move the last row content to the first row
  local first_line = track:line(1)
  PakettiImpulseTrackerSlideTrackCopyNoteColumns(last_row_note_columns, first_line.note_columns)
  PakettiImpulseTrackerSlideTrackCopyEffectColumns(last_row_effect_columns, first_line.effect_columns)
end

-- Slide selected track content up by one row in the current pattern
function PakettiImpulseTrackerSlideTrackUp()
  local song = renoise.song()
  local pattern_index = song.selected_pattern_index
  local track_index = song.selected_track_index
  local pattern = song:pattern(pattern_index)
  local track = pattern:track(track_index)
  local number_of_lines = pattern.number_of_lines

  -- Store the content of the first row to move it to the last row
  local first_row_note_columns = {}
  local first_row_effect_columns = {}

  for pos, column in song.pattern_iterator:note_columns_in_pattern_track(pattern_index, track_index) do
    if pos.line == 1 then
      table.insert(first_row_note_columns, column)
    end
  end

  for pos, column in song.pattern_iterator:effect_columns_in_pattern_track(pattern_index, track_index) do
    if pos.line == 1 then
      table.insert(first_row_effect_columns, column)
    end
  end

  -- Slide content up
  for line = 1, number_of_lines - 1 do
    local src_line = track:line(line + 1)
    local dst_line = track:line(line)
    PakettiImpulseTrackerSlideTrackCopyNoteColumns(src_line.note_columns, dst_line.note_columns)
    PakettiImpulseTrackerSlideTrackCopyEffectColumns(src_line.effect_columns, dst_line.effect_columns)
  end

  -- Move the first row content to the last row
  local last_line = track:line(number_of_lines)
  PakettiImpulseTrackerSlideTrackCopyNoteColumns(first_row_note_columns, last_line.note_columns)
  PakettiImpulseTrackerSlideTrackCopyEffectColumns(first_row_effect_columns, last_line.effect_columns)
end

renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Slide Selected Track Content Down",invoke=PakettiImpulseTrackerSlideTrackDown}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Slide Selected Track Content Up",invoke=PakettiImpulseTrackerSlideTrackUp}

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Slide Selected Track Content Up",invoke=PakettiImpulseTrackerSlideTrackUp}
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Slide Selected Track Content Down",invoke=PakettiImpulseTrackerSlideTrackDown}

renoise.tool():add_midi_mapping{name="Paketti:Slide Selected Track Content Up",invoke=PakettiImpulseTrackerSlideTrackUp}
renoise.tool():add_midi_mapping{name="Paketti:Slide Selected Track Content Down",invoke=PakettiImpulseTrackerSlideTrackDown}



-- Toggle Note Off "===" On / Off in all selected tracks within the selection or current row.
function PakettiNoteOffToSelection()
  local s = renoise.song()
  local currPatt = s.selected_pattern_index
  local selection = s.selection_in_pattern
  local note_col_idx = s.selected_note_column_index

  if selection then
    -- Loop through all lines and tracks within the selection
    for line = selection.start_line, selection.end_line do
      for track = selection.start_track, selection.end_track do
        local note_col = s.patterns[currPatt].tracks[track].lines[line].note_columns[note_col_idx]
        
        if note_col_idx and note_col_idx > 0 then
          if note_col.note_string == "OFF" then
            note_col.note_string = ""
          else
            note_col.note_string = "OFF"
          end
        end
      end
    end
  else
    -- No selection, operate on the current row
    local currLine = s.selected_line_index
    local currTrack = s.selected_track_index
    
    if note_col_idx and note_col_idx > 0 then
      local note_col = s.patterns[currPatt].tracks[currTrack].lines[currLine].note_columns[note_col_idx]
      
      if note_col.note_string == "OFF" then
        note_col.note_string = ""
      else
        note_col.note_string = "OFF"
      end
    end
  end
end

-- Add keybinding for the new function
renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Toggle Note Off in Selected Tracks",invoke=function() PakettiNoteOffToSelection() end}




-----------
-- Define the XML content as a string
local InstrautomationXML = [[
<?xml version="1.0" encoding="UTF-8"?>
<FilterDevicePreset doc_version="13">
  <DeviceSlot type="InstrumentAutomationDevice">
    <IsMaximized>true</IsMaximized>
    <ParameterNumber0>0</ParameterNumber0>
    <ParameterNumber1>1</ParameterNumber1>
    <ParameterNumber2>2</ParameterNumber2>
    <ParameterNumber3>3</ParameterNumber3>
    <ParameterNumber4>4</ParameterNumber4>
    <ParameterNumber5>5</ParameterNumber5>
    <ParameterNumber6>6</ParameterNumber6>
    <ParameterNumber7>7</ParameterNumber7>
    <ParameterNumber8>8</ParameterNumber8>
    <ParameterNumber9>9</ParameterNumber9>
    <ParameterNumber10>10</ParameterNumber10>
    <ParameterNumber11>11</ParameterNumber11>
    <ParameterNumber12>12</ParameterNumber12>
    <ParameterNumber13>13</ParameterNumber13>
    <ParameterNumber14>14</ParameterNumber14>
    <ParameterNumber15>15</ParameterNumber15>
    <ParameterNumber16>16</ParameterNumber16>
    <ParameterNumber17>17</ParameterNumber17>
    <ParameterNumber18>18</ParameterNumber18>
    <ParameterNumber19>19</ParameterNumber19>
    <ParameterNumber20>20</ParameterNumber20>
    <ParameterNumber21>21</ParameterNumber21>
    <ParameterNumber22>22</ParameterNumber22>
    <ParameterNumber23>23</ParameterNumber23>
    <ParameterNumber24>24</ParameterNumber24>
    <ParameterNumber25>25</ParameterNumber25>
    <ParameterNumber26>26</ParameterNumber26>
    <ParameterNumber27>27</ParameterNumber27>
    <ParameterNumber28>28</ParameterNumber28>
    <ParameterNumber29>29</ParameterNumber29>
    <ParameterNumber30>30</ParameterNumber30>
    <ParameterNumber31>31</ParameterNumber31>
    <ParameterNumber32>32</ParameterNumber32>
    <ParameterNumber33>33</ParameterNumber33>
    <ParameterNumber34>34</ParameterNumber34>
    <VisiblePages>8</VisiblePages>
  </DeviceSlot>
</FilterDevicePreset>
]]

-- Function to load the preset XML directly into the Instr. Automation device
function openVisiblePagesToFitParameters()
  local song = renoise.song()

  -- Load the Instr. Automation device into the selected track using insert_device_at
  local track = song.selected_track
  track:insert_device_at("Audio/Effects/Native/*Instr. Automation", 2)

  -- Set the active_preset_data to the provided XML content
  renoise.song().selected_track.devices[2].active_preset_data = InstrautomationXML

  -- Debug logging: Confirm the preset has been loaded
  renoise.app():show_status("Preset loaded into Instr. Automation device.")
end

-- Register the function to a menu entry
renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Plugins/Devices:Open Visible Pages to Fit Plugin Parameter Count",invoke=openVisiblePagesToFitParameters}
renoise.tool():add_menu_entry{name="DSP Device:Paketti..:Open Visible Pages to Fit Plugin Parameter Count",invoke=openVisiblePagesToFitParameters}

-- Register a keybinding for easier access (optional)
renoise.tool():add_keybinding{name="Global:Paketti:Open Visible Pages to Fit Parameters",invoke=openVisiblePagesToFitParameters}

--------------
-- Mix-Paste Tool for Renoise
-- This tool will mix clipboard data with the pattern data in Renoise

local temp_text_path = renoise.tool().bundle_path .. "temp_mixpaste.txt"
local mix_paste_mode = false

renoise.tool():add_keybinding{name="Pattern Editor:Paketti:Impulse Tracker MixPaste",invoke=function()
  mix_paste()
end}

function mix_paste()
  if not mix_paste_mode then
    -- First invocation: save selection to text file and perform initial paste
    save_selection_to_text()
    local clipboard_data = load_pattern_data_from_text()
    if clipboard_data then
      print("Debug: Clipboard data loaded for initial paste:\n" .. clipboard_data)
      perform_initial_paste(clipboard_data)
      renoise.app():show_status("Initial mix-paste performed. Run Mix-Paste again to perform the final mix.")
    else
      renoise.app():show_error("Failed to load clipboard data from text file.")
    end
    mix_paste_mode = true
  else
    -- Second invocation: load from text file and perform final mix-paste
    local clipboard_data = load_pattern_data_from_text()
    if clipboard_data then
      print("Debug: Clipboard data loaded for final paste:\n" .. clipboard_data)
      perform_final_mix_paste(clipboard_data)
      mix_paste_mode = false
      -- Clear the temp text file
      local file = io.open(temp_text_path, "w")
      file:write("")
      file:close()
    else
      renoise.app():show_error("Failed to load clipboard data from text file.")
    end
  end
end

function save_selection_to_text()
  local song = renoise.song()
  local selection = song.selection_in_pattern
  if not selection then
    renoise.app():show_error("Please make a selection in the pattern first.")
    return
  end

  -- Capture pattern data using rprint and save to text file
  local pattern_data = {}
  local pattern = song:pattern(song.selected_pattern_index)
  local track_index = song.selected_track_index

  for line_index = selection.start_line, selection.end_line do
    local line_data = {}
    local line = pattern:track(track_index):line(line_index)
    for col_index = 1, #line.note_columns do
      local note_column = line:note_column(col_index)
      table.insert(line_data, string.format("%s %02X %02X %02X %02X", 
        note_column.note_string, note_column.instrument_value, 
        note_column.volume_value, note_column.effect_number_value, 
        note_column.effect_amount_value))
    end
    for col_index = 1, #line.effect_columns do
      local effect_column = line:effect_column(col_index)
      table.insert(line_data, string.format("%02X %02X", 
        effect_column.number_value, effect_column.amount_value))
    end
    table.insert(pattern_data, table.concat(line_data, " "))
  end

  -- Save pattern data to text file
  local file = io.open(temp_text_path, "w")
  file:write(table.concat(pattern_data, "\n"))
  file:close()

  print("Debug: Saved pattern data to text file:\n" .. table.concat(pattern_data, "\n"))
end

function load_pattern_data_from_text()
  local file = io.open(temp_text_path, "r")
  if not file then
    return nil
  end
  local clipboard = file:read("*a")
  file:close()
  return clipboard
end

function perform_initial_paste(clipboard_data)
  local song = renoise.song()
  local track_index = song.selected_track_index
  local line_index = song.selected_line_index
  local pattern = song:pattern(song.selected_pattern_index)
  local track = pattern:track(track_index)

  local clipboard_lines = parse_clipboard_data(clipboard_data)

  for i, clipboard_line in ipairs(clipboard_lines) do
    local line = track:line(line_index + i - 1)
    for col_index, clipboard_note_col in ipairs(clipboard_line.note_columns) do
      if col_index <= #line.note_columns then
        local note_col = line:note_column(col_index)
        if note_col.is_empty then
          note_col.note_string = clipboard_note_col.note_string
          note_col.instrument_value = clipboard_note_col.instrument_value
          note_col.volume_value = clipboard_note_col.volume_value
          note_col.effect_number_value = clipboard_note_col.effect_number_value
          note_col.effect_amount_value = clipboard_note_col.effect_amount_value
        end
      end
    end
    for col_index, clipboard_effect_col in ipairs(clipboard_line.effect_columns) do
      if col_index <= #line.effect_columns then
        local effect_col = line:effect_column(col_index)
        if effect_col.is_empty then
          effect_col.number_value = clipboard_effect_col.number_value
          effect_col.amount_value = clipboard_effect_col.amount_value
        end
      end
    end
  end
end

function perform_final_mix_paste(clipboard_data)
  local song = renoise.song()
  local track_index = song.selected_track_index
  local line_index = song.selected_line_index
  local pattern = song:pattern(song.selected_pattern_index)
  local track = pattern:track(track_index)

  local clipboard_lines = parse_clipboard_data(clipboard_data)

  for i, clipboard_line in ipairs(clipboard_lines) do
    local line = track:line(line_index + i - 1)
    for col_index, clipboard_note_col in ipairs(clipboard_line.note_columns) do
      if col_index <= #line.note_columns then
        local note_col = line:note_column(col_index)
        if not note_col.is_empty then
          if clipboard_note_col.effect_number_value > 0 then
            note_col.effect_number_value = clipboard_note_col.effect_number_value
            note_col.effect_amount_value = clipboard_note_col.effect_amount_value
          end
        end
      end
    end
    for col_index, clipboard_effect_col in ipairs(clipboard_line.effect_columns) do
      if col_index <= #line.effect_columns then
        local effect_col = line:effect_column(col_index)
        if not effect_col.is_empty then
          if clipboard_effect_col.number_value > 0 then
            effect_col.number_value = clipboard_effect_col.number_value
            effect_col.amount_value = clipboard_effect_col.amount_value
          end
        end
      end
    end
  end
end

function parse_clipboard_data(clipboard)
  local lines = {}
  for line in clipboard:gmatch("[^\r\n]+") do
    table.insert(lines, parse_line(line))
  end
  return lines
end

function parse_line(line)
  local note_columns = {}
  local effect_columns = {}
  for note_col_data in line:gmatch("(%S+ %S+ %S+ %S+ %S+)") do
    table.insert(note_columns, parse_note_column(note_col_data))
  end
  for effect_col_data in line:gmatch("(%S+ %S+)") do
    table.insert(effect_columns, parse_effect_column(effect_col_data))
  end
  return {note_columns=note_columns,effect_columns=effect_columns}
end

function parse_note_column(data)
  local note, instrument, volume, effect_number, effect_amount = data:match("(%S+) (%S+) (%S+) (%S+) (%S+)")
  return {
    note_string=note,
    instrument_value=tonumber(instrument, 16),
    volume_value=tonumber(volume, 16),
    effect_number_value=tonumber(effect_number, 16),
    effect_amount_value=tonumber(effect_amount, 16),
  }
end

function parse_effect_column(data)
  local number, amount = data:match("(%S+) (%S+)")
  return {
    number_value=tonumber(number, 16),
    amount_value=tonumber(amount, 16),
  }
end












-------------------------
--------
function Experimental()
    function read_file(path)
        local file = io.open(path, "r")  -- Open the file in read mode
        if not file then
            print("Failed to open file")
            return nil
        end
        local content = file:read("*a")  -- Read the entire content
        file:close()
        return content
    end

    function check_and_execute(xml_path, bash_script)
        local xml_content = read_file(xml_path)
        if not xml_content then
            return
        end

        local pattern = "<ShowScriptingDevelopmentTools>(.-)</ShowScriptingDevelopmentTools>"
        local current_value = xml_content:match(pattern)

        if current_value == "false" then  -- Check if the value is false
            print("Scripting tools are disabled. Executing the bash script to enable...")
            local command = 'open -a Terminal "' .. bash_script .. '"'
            os.execute(command)
        elseif current_value == "true" then
            print("Scripting tools are already enabled. No need to execute the bash script.")
          local bash_script = "/Users/esaruoho/macOS_DisableScriptingTools.sh"
            local command = 'open -a Terminal "' .. bash_script .. '"'
            os.execute(command)
        else
            print("Could not find the <ShowScriptingDevelopmentTools> tag in the XML.")
        end
    end

    local config_path = "/Users/esaruoho/Library/Preferences/Renoise/V3.4.3/Config.xml"
    local bash_script = "/Users/esaruoho/macOS_EnableScriptingTools.sh" -- Ensure this path is correct

    check_and_execute(config_path, bash_script)
end

--renoise.tool():add_menu_entry{name="Main Menu:Tools:Paketti..:Experimental (macOS Only) Config.XML overwriter (Destructive)",invoke=function() Experimental() end}

--Wipes the pattern data, but not the samples or instruments.
--WARNING: Does not reset current filename.
-- TODO
--[[
function wipeSongPattern()
local s=renoise.song()
  for i=1,300 do
    if s.patterns[i].is_empty==false then
    s.patterns[i]:clear()
    renoise.song().patterns[i].number_of_lines=64
    else 
    print ("Encountered empty pattern, not deleting")
    renoise.song().patterns[i].number_of_lines=64
    end
  end
end
renoise.tool():add_keybinding{name="Global:Paketti:Wipe Song Patterns", invoke=function() wipeSongPattern() end}
renoise.tool():add_menu_entry{name="Main Menu:File:Wipe Song Patterns", invoke=function() wipeSongPattern() end}
----
function AutoGapper()
-- Something has changed with the Filter-device:
--*** ./Experimental_Verify.lua:30: attempt to index field '?' (a nil value)
--*** stack traceback:
--***   ./Experimental_Verify.lua:30: in function 'AutoGapper'
--***   ./Experimental_Verify.lua:37: in function <./Experimental_Verify.lua:37>

--renoise.song().tracks[get_master_track_index()].visible_effect_columns = 4  
local gapper=nil
renoise.app().window.active_lower_frame=1
renoise.app().window.lower_frame_is_visible=true
  loadnative("Audio/Effects/Native/Filter")
  loadnative("Audio/Effects/Native/*LFO")
  renoise.song().selected_track.devices[2].parameters[2].value=2
  renoise.song().selected_track.devices[2].parameters[3].value=1
  renoise.song().selected_track.devices[2].parameters[7].value=2
  renoise.song().selected_track.devices[3].parameters[5].value=0.0074
local gapper=renoise.song().patterns[renoise.song().selected_pattern_index].number_of_lines*2*4
  renoise.song().selected_track.devices[2].parameters[6].value_string=tostring(gapper)
--renoise.song().selected_pattern.tracks[get_master_track_index()].lines[renoise.song().selected_line_index].effect_columns[4].number_string = "18"
end

renoise.tool():add_keybinding{name="Global:Paketti:Add Filter & LFO (AutoGapper)", invoke=function() AutoGapper() end}
--]]

------------
function start_stop_sample_and_loop_oh_my()
local w=renoise.app().window
local s=renoise.song()
local t=s.transport
local ss=s.selected_sample
local currTrak=s.selected_track_index
local currPatt=s.selected_pattern_index

if w.sample_record_dialog_is_visible then
    -- we are recording, stop
    t:start_stop_sample_recording()
    -- write note
     ss.autoseek=true
     s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].number_string="0G"
     s.patterns[currPatt].tracks[currTrak].lines[1].effect_columns[1].amount_string="01"

for i= 1,12 do
if s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[i].is_empty==true then
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[i].note_string="C-4"
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[i].instrument_value=s.selected_instrument_index-1
else
 if i == renoise.song().tracks[currTrak].visible_note_columns and i == 12
  then renoise.song():insert_track_at(renoise.song().selected_track_index)
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[1].note_string="C-4"
   s.patterns[currPatt].tracks[currTrak].lines[1].note_columns[1].instrument_value=s.selected_instrument_index-1
end
end
end
    -- hide dialog
    w.sample_record_dialog_is_visible = false
  else
    -- not recording. show dialog, start recording.
    w.sample_record_dialog_is_visible = true
    t:start_stop_sample_recording()
  end
end

--renoise.tool():add_keybinding{name="Global:Paketti:Stair RecordToCurrent", invoke=function() 
--if renoise.song().transport.playing==false then
    --renoise.song().transport.playing=true end
--start_stop_sample_and_loop_oh_my() end}
--
--function stairs()
--local currCol=nil
--local addCol=nil
--currCol=renoise.song().selected_note_column_index
---
--if renoise.song().selected_track.visibile_note_columns and renoise.song().selected_note_column_index == 12   then 
--renoise.song().selected_note_column_index = 1
--end
--
--
--if currCol == renoise.song().selected_track.visible_note_columns
--then renoise.song().selected_track.visible_note_columns = addCol end
--
--renoise.song().selected_note_column_index=currCol+1
--
--end
--renoise.tool():add_keybinding{name="Global:Paketti:Stair", invoke=function() stairs() end}
renoise.tool():add_menu_entry{name="--Pattern Editor:Paketti..:Bypass All Devices on Channel", invoke=function() effectbypass() end}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Enable All Devices on Channel", invoke=function() effectenable() end}
----------------------------

-- has-line-input + add-line-input
function has_line_input()
-- Write some code to find the line input in the correct place
local tr = renoise.song().selected_track
 if tr.devices[2] and tr.devices[2].device_path=="Audio/Effects/Native/#Line Input" 
  then return true
 else
  return false
 end
end

function add_line_input()
-- Write some code to add the line input in the correct place
 loadnative("Audio/Effects/Native/#Line Input")
end

function remove_line_input()
-- Write some code to remove the line input if it's in the correct place
 renoise.song().selected_track:delete_device_at(2)
end

-- recordamajic
function recordamajic9000(running)
    if running then
    renoise.song().transport.playing=true
        -- start recording code here
renoise.app().window.sample_record_dialog_is_visible=true
renoise.app().window.lock_keyboard_focus=true
renoise.song().transport:start_stop_sample_recording()
    else
    -- Stop recording here
    end
end

renoise.tool():add_keybinding{name="Global:Paketti:Recordammajic9000",
invoke=function() if has_line_input() then 
      recordtocurrenttrack()    
      G01()
 else add_line_input()
      recordtocurrenttrack()
      G01()
 end end}

-- turn samplerecorder ON
function SampleRecorderOn()
local howmany = table.count(renoise.song().selected_track.devices)

if renoise.app().window.sample_record_dialog_is_visible==false then
renoise.app().window.sample_record_dialog_is_visible=true 

  if howmany == 1 then 
    loadnative("Audio/Effects/Native/#Line Input")
    return
  else
    if renoise.song().selected_track.devices[2].name=="#Line Input" then
    renoise.song().selected_track:delete_device_at(2)
    renoise.app().window.sample_record_dialog_is_visible=false
    else
    loadnative("Audio/Effects/Native/#Line Input")
    return
end    
  end  

else renoise.app().window.sample_record_dialog_is_visible=false
  if renoise.song().selected_track.devices[2].name=="#Line Input" then
  renoise.song().selected_track:delete_device_at(2)
  end
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Display Sample Recorder with #Line Input", invoke=function() SampleRecorderOn() end}

function glideamount(amount)
local counter=nil 
for i=renoise.song().selection_in_pattern.start_line,renoise.song().selection_in_pattern.end_line 
do renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[1].number_string="0G" 
counter=renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[1].amount_value+amount 

if counter > 255 then counter=255 end
if counter < 1 then counter=0 
end
renoise.song().patterns[renoise.song().selected_pattern_index].tracks[renoise.song().selected_track_index].lines[i].effect_columns[1].amount_value=counter 
end
end

local s = nil

function startup_()
  local s=renoise.song()
--   renoise.app().window:select_preset(1)
   
   renoise.song().instruments[s.selected_instrument_index].active_tab=1
    if renoise.app().window.active_middle_frame==0 and s.selected_sample.sample_buffer_observable:has_notifier(sample_loaded_change_to_sample_editor) then 
    s.selected_sample.sample_buffer_observable:remove_notifier(sample_loaded_change_to_sample_editor)
    else
  --s.selected_sample.sample_buffer_observable:add_notifier(sample_loaded_change_to_sample_editor)

    return
    end
end

  function sample_loaded_change_to_sample_editor()
--    renoise.app().window.active_middle_frame=4
  end

if not renoise.tool().app_new_document_observable:has_notifier(startup_) 
   then renoise.tool().app_new_document_observable:add_notifier(startup_)
   else renoise.tool().app_new_document_observable:remove_notifier(startup_)
end
--------------------------------------------------------------------------------
function PakettiCapsLockNoteOffNextPtn()   
local s=renoise.song()
local wrapping=s.transport.wrapped_pattern_edit
local editstep=s.transport.edit_step

local currLine=s.selected_line_index
local currPatt=s.selected_pattern_index

local counter=nil
local addlineandstep=nil
local counting=nil
local seqcount=nil
local resultPatt=nil

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and 
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="FF"
then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=""
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=""
return
else
end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="CF"
then s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="00"  
     s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="00"
return
end

if renoise.song().transport.edit_mode==true then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="0O"  
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="CF"
return
end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string=="0O" and 
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string=="CF"

then s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="00" 
     s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="00"
return
end

if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string~=nil then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].number_string="0O"
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].effect_columns[1].amount_string="FF"
return
else 
if s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=="OFF" then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=""
return
else
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="OFF"
end

--s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="OFF"
end

addlineandstep=currLine+editstep
seqcount = currPatt+1

if addlineandstep > s.patterns[currPatt].number_of_lines then
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
counting=addlineandstep-s.patterns[currPatt].number_of_lines
 if seqcount > (table.count(renoise.song().sequencer.pattern_sequence)) then 
 seqcount = (table.count(renoise.song().sequencer.pattern_sequence))
 s.selected_sequence_index=seqcount
 end
 
resultPatt=currPatt+1 
 if resultPatt > #renoise.song().sequencer.pattern_sequence then 
 resultPatt = (table.count(renoise.song().sequencer.pattern_sequence))
s.selected_sequence_index=resultPatt
s.selected_line_index=counting
end
else 
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
--s.selected_sequence_index=currPatt+1
s.selected_line_index=addlineandstep

counter = addlineandstep-1

renoise.app():show_status("Now on: " .. counter .. "/" .. s.patterns[currPatt].number_of_lines .. " In Pattern: " .. currPatt)
end
end
----
function PakettiCapsLockNoteOff()   
local s=renoise.song()
local st=s.transport
local wrapping=st.wrapped_pattern_edit
local editstep=st.edit_step

local currLine=s.selected_line_index
local currPatt=s.selected_sequence_index

local counter=nil
local addlineandstep=nil
local counting=nil
local seqcount=nil

if renoise.song().patterns[renoise.song().selected_sequence_index].tracks[renoise.song().selected_track_index].lines[renoise.song().selected_line_index].note_columns[renoise.song().selected_note_column_index].note_string=="OFF" then 

s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=""
return
else end

if not s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=="OFF"
then
s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string="OFF"
else s.patterns[currPatt].tracks[s.selected_track_index].lines[s.selected_line_index].note_columns[s.selected_note_column_index].note_string=""
end

addlineandstep=currLine+editstep
seqcount = currPatt+1

if addlineandstep > s.patterns[currPatt].number_of_lines then
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
counting=addlineandstep-s.patterns[currPatt].number_of_lines
 if seqcount > (table.count(renoise.song().sequencer.pattern_sequence)) then 
 seqcount = (table.count(renoise.song().sequencer.pattern_sequence))
 s.selected_sequence_index=seqcount
 end
--s.selected_sequence_index=currPatt+1
s.selected_line_index=counting
else 
print ("Trying to move to index: " .. addlineandstep .. " Pattern number of lines is: " .. s.patterns[currPatt].number_of_lines)
--s.selected_sequence_index=currPatt+1
s.selected_line_index=addlineandstep

counter = addlineandstep-1

renoise.app():show_status("Now on: " .. counter .. "/" .. s.patterns[currPatt].number_of_lines .. " In Pattern: " .. currPatt)
end
end

renoise.tool():add_keybinding{name="Global:Paketti:Note Off / Caps Lock replacement", invoke=function() 
if renoise.song().transport.wrapped_pattern_edit == false then PakettiCapsLockNoteOffNextPtn() 
else PakettiCapsLockNoteOff() end
end}
--------------------------------------------------------------
renoise.tool():add_keybinding{name="Global:Paketti:Record to Current Track+Plus", 
invoke=function() 
      renoise.app().window.active_lower_frame=1
local howmany = table.count(renoise.song().selected_track.devices)

if howmany == 1 then 
loadnative("Audio/Effects/Native/#Line Input")
recordtocurrenttrack()
return
else
if renoise.song().selected_track.devices[2].name=="#Line Input" then
  renoise.song().selected_track:delete_device_at(2)
  recordtocurrenttrack()
  return
else
  loadnative("Audio/Effects/Native/#Line Input")
  recordtocurrenttrack()
  return
end end end}

renoise.tool():add_menu_entry{name="Sample Mappings:Paketti..:Record To Current", invoke=function() recordtocurrenttrack() end}
----------------------------------------------------------------------------------------------------------
--esa- 2nd keybind for Record Toggle ON/OFF with effect_column reading
function RecordToggle()
 local a=renoise.app()
 local s=renoise.song()
 local t=s.transport
 local currentstep=t.edit_step
--if has notifier, dump notifier, if no notifier, add notifier
 if t.edit_mode then
    t.edit_mode=false
 if t.edit_step==0 then
    t.edit_step=1
 else
  return
 end 
 else
      t.edit_mode = true
   if s.selected_effect_column_index == 1 then t.edit_step=0
   elseif s.selected_effect_column_index == 0 then t.edit_step=currentstep return
   end
end
end
----------------------------------------
require "Research/FormulaDeviceManual"

renoise.tool():add_keybinding{name="Global:Paketti:FormulaDevice", invoke=function()  
renoise.app().window.lower_frame_is_visible=true
renoise.app().window.active_lower_frame=1
renoise.song().tracks[renoise.song().selected_track_index]:insert_device_at("Audio/Effects/Native/*Formula", 2)  
local infile = io.open( "Research/FormulaDeviceXML.txt", "rb" )
local indata = infile:read( "*all" )
renoise.song().tracks[renoise.song().selected_track_index].devices[2].active_preset_data = indata
infile:close()

show_manual (
    "Formula Device Documentation", -- manual dialog title
    "Research/FormulaDevice.txt" -- the textfile which contains the manual
  )
end}
---------------------------
renoise.tool():add_keybinding{name="Sample Editor:Paketti:Disk Browser Focus",invoke=function() renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(7) end}

renoise.tool():add_keybinding{name="Global:Paketti:Disk Browser Focus",invoke=function() renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(8) end}

renoise.tool():add_keybinding{name="Global:Paketti:Disk Browser Focus (2nd)",invoke=function() renoise.app().window.lock_keyboard_focus=false
renoise.app().window:select_preset(8) end}

renoise.tool():add_keybinding{name="Global:Paketti:Contour Shuttle Disk Browser Focus",invoke=function() renoise.app().window:select_preset(8) end}
------------------------------------------------------------------------------------------------
function G01()
  local s=renoise.song()
  local currTrak=s.selected_track_index
  local currPatt=s.selected_pattern_index
  local rightinstrument=nil
  local rightinstrument=renoise.song().selected_instrument_index-1

  if preferences._0G01_Loader.value then
    local new_track_index = currTrak + 1
    s:insert_track_at(new_track_index)
    s.selected_track_index = new_track_index
    currTrak = new_track_index
    local line=s.patterns[currPatt].tracks[currTrak].lines[1]
    line.note_columns[1].note_string="C-4"
    line.note_columns[1].instrument_value=rightinstrument
    line.effect_columns[1].number_string="0G"
    line.effect_columns[1].amount_string="01"
      
  end

end

---------
function move_up(chg)
local sindex=renoise.song().selected_line_index
local s= renoise.song()
local note=s.selected_note_column
--This switches currently selected row but doesn't 
--move the note
--s.selected_line_index = (sindex+chg)
-- moving note up, applying correct delay value and moving cursor up goes here
end
--movedown
function move_down(chg)
local sindex=renoise.song().selected_line_index
local s= renoise.song()
--This switches currently selected row but doesn't 
--move the note
--s.selected_line_index = (sindex+chg)
-- moving note down, applying correct delay value and moving cursor down goes here
end


-- Function to adjust the delay value of the selected note column within the current phrase
-- TODO: missing API for reading phrase.selected_line_index. can't work
function Phrplusdelay(chg)
  local song = renoise.song()
  local nc = song.selected_note_column

  -- Check if a note column is selected
  if not nc then
    local message = "No note column is selected!"
    renoise.app():show_status(message)
    print(message)
    return
  end

  local currTrak = song.selected_track_index
  local currInst = song.selected_instrument_index
  local currPhra = song.selected_phrase_index
  local sli = song.selected_line_index
  local snci = song.selected_note_column_index

  -- Check if a phrase is selected
  if currPhra == 0 then
    local message = "No phrase is selected!"
    renoise.app():show_status(message)
    print(message)
    return
  end

  -- Ensure delay columns are visible in both track and phrase
  song.instruments[currInst].phrases[currPhra].delay_column_visible = true
  song.tracks[currTrak].delay_column_visible = true

  -- Get current delay value from the selected note column in the phrase
  local phrase = song.instruments[currInst].phrases[currPhra]
  local line = phrase:line(sli)
  local note_column = line:note_column(snci)
  local Phrad = note_column.delay_value

  -- Adjust delay value, ensuring it stays within 0-255 range
  note_column.delay_value = math.max(0, math.min(255, Phrad + chg))

  -- Show and print status message
  local message = "Delay value adjusted by " .. chg .. " at line " .. sli .. ", column " .. snci
  renoise.app():show_status(message)
  print(message)

  -- Show and print visible note columns and effect columns
  local visible_note_columns = phrase.visible_note_columns
  local visible_effect_columns = phrase.visible_effect_columns
  local columns_message = string.format("Visible Note Columns: %d, Visible Effect Columns: %d", visible_note_columns, visible_effect_columns)
  renoise.app():show_status(columns_message)
  print(columns_message)
end

-- Add keybindings for adjusting the delay value
--renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Increase Delay +1",invoke=function() Phrplusdelay(1) end}
--renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Decrease Delay -1",invoke=function() Phrplusdelay(-1) end}
--renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Increase Delay +10",invoke=function() Phrplusdelay(10) end}
--renoise.tool():add_keybinding{name="Phrase Editor:Paketti:Decrease Delay -10",invoke=function() Phrplusdelay(-10) end}
---------------------------------------------------------------------------------------------------------
----------
function delay(seconds)
    local command = "sleep " .. tonumber(seconds)
    os.execute(command)
end

----------
function pattern_line_notifier(pos) --here
  local colnumber=nil
  local countline=nil
  local count=nil
--  print (pos.pattern)
--  print (pos.track)
--  print (pos.line)

local s=renoise.song() 
local t=s.transport
if t.edit_step==0 then 
count=s.selected_note_column_index+1

if count == s.tracks[s.selected_track_index].visible_note_columns then s.selected_note_column_index=count return end
if count > s.tracks[s.selected_track_index].visible_note_columns then 
local slicount=nil
slicount=s.selected_line_index+1 
if slicount > s.patterns[s.selected_pattern_index].number_of_lines
then 
s.selected_line_index=s.patterns[s.selected_pattern_index].number_of_lines end
count=1 
s.selected_note_column_index=count return
else s.selected_note_column_index=count return end
end

countline=s.selected_line_index+1---1+renoise.song().transport.edit_step
   if t.edit_step>1 then
   countline=countline-1
   else countline=s.selected_line_index end
   --print ("countline is selected line index +1" .. countline)
   --print ("editstep" .. renoise.song().transport.edit_step)
   if countline > s.patterns[s.selected_pattern_index].number_of_lines
   then countline=1
   end
   s.selected_line_index=countline
 
   colnumber=s.selected_note_column_index+1
   if colnumber > s.tracks[s.selected_track_index].visible_note_columns then
   s.selected_note_column_index=1
   return end
  s.selected_note_column_index=colnumber end
  
function startcolumncycling(number) -- here
local s=renoise.song()
  if s.patterns[s.selected_pattern_index]:has_line_notifier(pattern_line_notifier) 
then s.patterns[s.selected_pattern_index]:remove_line_notifier(pattern_line_notifier)
 renoise.app():show_status(number .. " Column Cycle Keyjazz Off")
else s.patterns[s.selected_pattern_index]:add_line_notifier(pattern_line_notifier)
 renoise.app():show_status(number .. " Column Cycle Keyjazz On") end
end

for cck=1,12 do
renoise.tool():add_keybinding{name="Global:Paketti:Column Cycle Keyjazz " .. cck,invoke=function() displayNoteColumn(cck) startcolumncycling(cck) end}
end

renoise.tool():add_keybinding{name="Global:Paketti:Start/Stop Column Cycling",invoke=function() startcolumncycling() 
  if renoise.song().patterns[renoise.song().selected_pattern_index]:has_line_notifier(pattern_line_notifier)
then renoise.app():show_status("Column Cycle Keyjazz On")
else renoise.app():show_status("Column Cycle Keyjazz Off") end end}

renoise.tool():add_keybinding{name="Global:Paketti:Column Cycle Keyjazz 01_Special",invoke=function() 
displayNoteColumn(12) 
GenerateDelayValue()
renoise.song().transport.edit_mode=true
renoise.song().transport.edit_step=0
renoise.song().selected_note_column_index=1
startcolumncycling(12) end}
----------------------------





-- Resize all non-empty patterns to 96 lines
function resize_all_non_empty_patterns_to_96()
  local song = renoise.song()
  for i = 1, #song.patterns do
    if not song.patterns[i].is_empty then
      song.patterns[i].number_of_lines = 96
    end
  end
  renoise.app():show_status("Resized all non-empty patterns to 96 lines.")
end

-- Resize all non-empty patterns to the current pattern's length
function resize_all_non_empty_patterns_to_current_pattern_length()
  local song = renoise.song()
  local current_pattern_length = song.patterns[song.selected_pattern_index].number_of_lines
  for i = 1, #song.patterns do
    if not song.patterns[i].is_empty then
      song.patterns[i].number_of_lines = current_pattern_length
    end
  end
  renoise.app():show_status("Resized all non-empty patterns to the current pattern's length (" .. song.patterns[song.selected_pattern_index].number_of_lines .. ")")
end

-- Add the menu entries to the Global:Paketti section
renoise.tool():add_keybinding{name="Global:Paketti:Resize all non-empty Patterns to 96",invoke = resize_all_non_empty_patterns_to_96}
renoise.tool():add_keybinding{name="Global:Paketti:Resize all non-empty Patterns to current Pattern length",invoke = resize_all_non_empty_patterns_to_current_pattern_length}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Resize all non-empty Patterns to 96",invoke = resize_all_non_empty_patterns_to_96}
renoise.tool():add_menu_entry{name="Pattern Editor:Paketti..:Resize all non-empty Patterns to current Pattern length",invoke = resize_all_non_empty_patterns_to_current_pattern_length}
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Resize all non-empty Patterns to 96",invoke = resize_all_non_empty_patterns_to_96}
renoise.tool():add_menu_entry{name="Pattern Sequencer:Paketti..:Resize all non-empty Patterns to current Pattern length",invoke = resize_all_non_empty_patterns_to_current_pattern_length}






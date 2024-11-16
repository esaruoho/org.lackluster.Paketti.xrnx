local vb = renoise.ViewBuilder()
local dialog
local checkboxes = {}
local retrig_checkboxes = {}
local playback_checkboxes = {}
local num_checkboxes = 16
local max_rows = 64
local column_choice = "FX Column"
local retrig_value = 4
local retrig_column_choice = "FX Column"
local active_steps_volume = num_checkboxes
local active_steps_retrig = num_checkboxes
local active_steps_playback = num_checkboxes
local panning_left_checkboxes = {}
local panning_center_checkboxes = {}
local panning_right_checkboxes = {}
local panning_buttons = {}
local active_steps_panning = num_checkboxes
local panning_column_choice = "FX Column"
local initializing = false -- Flag to control printing during initialization or fetching

-- Colors for buttons
local normal_color = nil
local highlight_color = {0x22, 0xaa, 0xff}

-- Initialize buttons and checkboxes
local buttons = {}
local retrig_buttons = {}
local playback_buttons = {}

-- Paketti Gater Device Script

local function initialize_checkboxes(count)
  checkboxes = {}
  retrig_checkboxes = {}
  playback_checkboxes = {}
  buttons = {}
  retrig_buttons = {}
  playback_buttons = {}
  panning_left_checkboxes = {}
  panning_center_checkboxes = {}
  panning_right_checkboxes = {}
  panning_buttons = {}

  for i = 1, count do
    local is_highlight = (i == 1 or i == 5 or i == 9 or i == 13)
    buttons[i] = vb:button {
      text = string.format("%02d", i),
      width = 30,
      color = is_highlight and highlight_color or normal_color
    }
    retrig_buttons[i] = vb:button {
      text = string.format("%02d", i),
      width = 30,
      color = is_highlight and highlight_color or normal_color
    }
    playback_buttons[i] = vb:button {
      text = string.format("%02d", i),
      width = 30,
      color = is_highlight and highlight_color or normal_color
    }
    checkboxes[i] = vb:checkbox {
      value = false,
      width = 30,
      notifier = function()
        if not initializing then
          insert_commands()
        end
      end
    }
    retrig_checkboxes[i] = vb:checkbox {
      value = false,
      width = 30,
      notifier = function()
        if not initializing then
          insert_commands()
        end
      end
    }
    playback_checkboxes[i] = vb:checkbox {
      value = false,
      width = 30,
      notifier = function()
        if not initializing then
          insert_commands()
        end
      end
    }
  end

  for i = 1, count do
    panning_left_checkboxes[i] = vb:checkbox {
      value = false,
      width = 30,
      notifier = function()
        if panning_left_checkboxes[i].value then
          panning_center_checkboxes[i].value = false
          panning_right_checkboxes[i].value = false
        end
        if not initializing then
          insert_commands()
        end
      end
    }
    panning_center_checkboxes[i] = vb:checkbox {
      value = true,
      width = 30,
      notifier = function()
        if panning_center_checkboxes[i].value then
          panning_left_checkboxes[i].value = false
          panning_right_checkboxes[i].value = false
        end
        if not initializing then
          insert_commands()
        end
      end
    }
    panning_right_checkboxes[i] = vb:checkbox {
      value = false,
      width = 30,
      notifier = function()
        if panning_right_checkboxes[i].value then
          panning_left_checkboxes[i].value = false
          panning_center_checkboxes[i].value = false
        end
        if not initializing then
          insert_commands()
        end
      end
    }
    panning_buttons[i] = vb:button {
      text = string.format("%02d", i),
      width = 30,
      color = (i == 1 or i == 5 or i == 9 or i == 13) and highlight_color or normal_color
    }
  end
end

initialize_checkboxes(num_checkboxes)

-- Set active steps based on the valuebox
local function set_active_steps_volume(value)
  active_steps_volume = value
  if not initializing then
    insert_commands()
  end
end

local function set_active_steps_retrig(value)
  active_steps_retrig = value
  if not initializing then
    insert_commands()
  end
end

local function set_active_steps_playback(value)
  active_steps_playback = value
  if not initializing then
    insert_commands()
  end
end

local function set_active_steps_panning(value)
  active_steps_panning = value
  if not initializing then
    insert_commands()
  end
end

-- Receive Volume checkboxes state
local function receive_volume_checkboxes()
  if not renoise.song() then return end

  initializing = true -- Halt printing during fetching

  local pattern = renoise.song().selected_pattern
  local track_index = renoise.song().selected_track_index
  local track = renoise.song().selected_track
  local visible_note_columns = track.visible_note_columns

  for i = 1, num_checkboxes do
    local line_index = 1 + i -1
    if line_index <= max_rows then
      local line = pattern:track(track_index):line(line_index)
      if column_choice == "FX Column" then
        checkboxes[i].value = (line.effect_columns[1].number_string == "0C" and line.effect_columns[1].amount_string == "0F")
      elseif column_choice == "Volume Column" then
        checkboxes[i].value = false
        for j = 1, visible_note_columns do
          local note_column = line:note_column(j)
          if note_column.volume_string == "80" then
            checkboxes[i].value = true
            break
          end
        end
      elseif column_choice == "FX Column (L00)" then
        checkboxes[i].value = (line.effect_columns[1].number_string == "0L" and line.effect_columns[1].amount_string == "C0")
      end
    end
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  initializing = false -- Resume printing after fetching
  insert_commands()
end

-- Receive Retrig checkboxes state
local function receive_retrig_checkboxes()
  if not renoise.song() then return end

  initializing = true

  local pattern = renoise.song().selected_pattern
  local track_index = renoise.song().selected_track_index
  local track = renoise.song().selected_track
  local visible_note_columns = track.visible_note_columns

  for i = 1, num_checkboxes do
    local line_index = 1 + i -1
    if line_index <= max_rows then
      local line = pattern:track(track_index):line(line_index)
      if retrig_column_choice == "FX Column" then
        retrig_checkboxes[i].value = (line.effect_columns[2].number_string == "0R")
      elseif retrig_column_choice == "Volume Column" then
        retrig_checkboxes[i].value = false
        for j = 1, visible_note_columns do
          local note_column = line:note_column(j)
          if string.sub(note_column.volume_string, 1, 1) == "R" then
            retrig_checkboxes[i].value = true
            break
          end
        end
      elseif retrig_column_choice == "Panning Column" then
        renoise.song().selected_track.panning_column_visible=true
        retrig_checkboxes[i].value = false
        for j = 1, visible_note_columns do
          local note_column = line:note_column(j)
          if string.sub(note_column.panning_string, 1, 1) == "R" then
            retrig_checkboxes[i].value = true
            break
          end
        end
      end
    end
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  initializing = false
  insert_commands()
end

-- Receive Playback checkboxes state
local function receive_playback_checkboxes()
  if not renoise.song() then return end

  initializing = true

  local pattern = renoise.song().selected_pattern
  local track_index = renoise.song().selected_track_index

  for i = 1, num_checkboxes do
    local line_index = 1 + i -1
    if line_index <= max_rows then
      local line = pattern:track(track_index):line(line_index)
      playback_checkboxes[i].value = (line.effect_columns[3].number_string == "0B" and line.effect_columns[3].amount_string == "00")
    end
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  initializing = false
  insert_commands()
end

-- Receive Panning checkboxes state
local function receive_panning_checkboxes()
  if not renoise.song() then return end

  initializing = true

  local pattern = renoise.song().selected_pattern
  local track_index = renoise.song().selected_track_index

  for i = 1, num_checkboxes do
    local line = pattern:track(track_index):line(i)

    if panning_column_choice == "Panning Column" then
      renoise.song().selected_track.panning_column_visible=true
      if line:note_column(1).panning_string == "00" then
        panning_left_checkboxes[i].value = true
        panning_center_checkboxes[i].value = false
        panning_right_checkboxes[i].value = false
      elseif line:note_column(1).panning_string == "80" then
        panning_left_checkboxes[i].value = false
        panning_center_checkboxes[i].value = false
        panning_right_checkboxes[i].value = true
      elseif line:note_column(1).panning_string == "40" then
        panning_left_checkboxes[i].value = false
        panning_center_checkboxes[i].value = true
        panning_right_checkboxes[i].value = false
      end
    elseif panning_column_choice == "FX Column" then
      if line.effect_columns[4].number_string == "0P" then
        if line.effect_columns[4].amount_string == "00" then
          panning_left_checkboxes[i].value = true
          panning_center_checkboxes[i].value = false
          panning_right_checkboxes[i].value = false
        elseif line.effect_columns[4].amount_string == "FF" then
          panning_left_checkboxes[i].value = false
          panning_center_checkboxes[i].value = false
          panning_right_checkboxes[i].value = true
        elseif line.effect_columns[4].amount_string == "7F" then
          panning_left_checkboxes[i].value = false
          panning_center_checkboxes[i].value = true
          panning_right_checkboxes[i].value = false
        end
      end
    end
  end

  initializing = false
  insert_commands()
end

-- Randomize Volume checkboxes
local function rand_volume_checkboxes()
  if not renoise.song() then return end

  for i = 1, num_checkboxes do
    if i <= active_steps_volume then
      checkboxes[i].value = math.random() > 0.5
    else
      checkboxes[i].value = false
    end
  end
  renoise.app():show_status("Randomized Volume Gater")
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  if not initializing then
    insert_commands()
  end
end

-- Randomize Retrig checkboxes
local function rand_retrig_checkboxes()
  if not renoise.song() then return end

  for i = 1, num_checkboxes do
    if i <= active_steps_retrig then
      retrig_checkboxes[i].value = math.random() > 0.5
    else
      retrig_checkboxes[i].value = false
    end
  end
  renoise.app():show_status("Randomized Retrig Gater")
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  if not initializing then
    insert_commands()
  end
end

-- Randomize Playback checkboxes
local function rand_playback_checkboxes()
  if not renoise.song() then return end

  for i = 1, num_checkboxes do
    if i <= active_steps_playback then
      playback_checkboxes[i].value = math.random() > 0.5
    else
      playback_checkboxes[i].value = false
    end
  end
  renoise.app():show_status("Randomized Playback Direction Gater")
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  if not initializing then
    insert_commands()
  end
end

-- Randomize Panning checkboxes
local function rand_panning_checkboxes()
  if not renoise.song() then return end

  for i = 1, num_checkboxes do
    if i <= active_steps_panning then
      local rand_choice = math.random(1, 3)
      if rand_choice == 1 then
        panning_left_checkboxes[i].value = true
        panning_center_checkboxes[i].value = false
        panning_right_checkboxes[i].value = false
      elseif rand_choice == 2 then
        panning_left_checkboxes[i].value = false
        panning_center_checkboxes[i].value = true
        panning_right_checkboxes[i].value = false
      else
        panning_left_checkboxes[i].value = false
        panning_center_checkboxes[i].value = false
        panning_right_checkboxes[i].value = true
      end
    else
      panning_left_checkboxes[i].value = false
      panning_center_checkboxes[i].value = true
      panning_right_checkboxes[i].value = false
    end
  end
  renoise.app():show_status("Randomized Panning Gater")

  if not initializing then
    insert_commands()
  end
end

-- Clear Volume Gater
local function clear_volume_gater()
  if not renoise.song() then return end

  for i = 1, num_checkboxes do
    checkboxes[i].value = false
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  if not initializing then
    insert_commands()
  end
end

-- Clear Retrig checkboxes
local function clear_retrig_checkboxes()
  if not renoise.song() then return end

  for i = 1, num_checkboxes do
    retrig_checkboxes[i].value = false
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  if not initializing then
    insert_commands()
  end
end

-- Clear Playback checkboxes
local function clear_playback_checkboxes()
  if not renoise.song() then return end

  for i = 1, num_checkboxes do
    playback_checkboxes[i].value = false
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  if not initializing then
    insert_commands()
  end
end

-- Clear Panning checkboxes
local function clear_panning_checkboxes()
  if not renoise.song() then return end

  for i = 1, num_checkboxes do
    panning_left_checkboxes[i].value = false
    panning_center_checkboxes[i].value = true
    panning_right_checkboxes[i].value = false
  end

  if not initializing then
    insert_commands()
  end
end

-- Shift checkboxes left or right
local function shift_checkboxes(direction)
  if not renoise.song() then return end

  local shifted = {}
  if direction == "left" then
    for i = 1, num_checkboxes do
      shifted[i] = checkboxes[(i % num_checkboxes) + 1].value
    end
  elseif direction == "right" then
    for i = 1, num_checkboxes do
      shifted[i] = checkboxes[((i - 2) % num_checkboxes) + 1].value
    end
  end
  for i = 1, num_checkboxes do
    checkboxes[i].value = shifted[i] and i <= active_steps_volume
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  if not initializing then
    insert_commands()
  end
end

-- Shift retrig checkboxes left or right
local function shift_retrig_checkboxes(direction)
  if not renoise.song() then return end

  local shifted = {}
  if direction == "left" then
    for i = 1, num_checkboxes do
      shifted[i] = retrig_checkboxes[(i % num_checkboxes) + 1].value
    end
  elseif direction == "right" then
    for i = 1, num_checkboxes do
      shifted[i] = retrig_checkboxes[((i - 2) % num_checkboxes) + 1].value
    end
  end
  for i = 1, num_checkboxes do
    retrig_checkboxes[i].value = shifted[i] and i <= active_steps_retrig
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  if not initializing then
    insert_commands()
  end
end

-- Shift playback checkboxes left or right
local function shift_playback_checkboxes(direction)
  if not renoise.song() then return end

  local shifted = {}
  if direction == "left" then
    for i = 1, num_checkboxes do
      shifted[i] = playback_checkboxes[(i % num_checkboxes) + 1].value
    end
  elseif direction == "right" then
    for i = 1, num_checkboxes do
      shifted[i] = playback_checkboxes[((i - 2) % num_checkboxes) + 1].value
    end
  end
  for i = 1, num_checkboxes do
    playback_checkboxes[i].value = shifted[i] and i <= active_steps_playback
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  if not initializing then
    insert_commands()
  end
end

-- Shift panning checkboxes left or right
local function shift_panning_checkboxes(direction)
  if not renoise.song() then return end

  local shifted_left = {}
  local shifted_center = {}
  local shifted_right = {}

  if direction == "left" then
    for i = 1, num_checkboxes do
      shifted_left[i] = panning_left_checkboxes[(i % num_checkboxes) + 1].value
      shifted_center[i] = panning_center_checkboxes[(i % num_checkboxes) + 1].value
      shifted_right[i] = panning_right_checkboxes[(i % num_checkboxes) + 1].value
    end
  elseif direction == "right" then
    for i = 1, num_checkboxes do
      shifted_left[i] = panning_left_checkboxes[((i - 2) % num_checkboxes) + 1].value
      shifted_center[i] = panning_center_checkboxes[((i - 2) % num_checkboxes) + 1].value
      shifted_right[i] = panning_right_checkboxes[((i - 2) % num_checkboxes) + 1].value
    end
  end

  for i = 1, num_checkboxes do
    panning_left_checkboxes[i].value = shifted_left[i]
    panning_center_checkboxes[i].value = shifted_center[i]
    panning_right_checkboxes[i].value = shifted_right[i]
  end

  if not initializing then
    insert_commands()
  end
end

-- Clear Effect Columns
function clear_effect_columns()
  if not renoise.song() then return end

  local pattern = renoise.song().selected_pattern
  local track_index = renoise.song().selected_track_index

  for i = 1, max_rows do
    local line = pattern:track(track_index):line(i)
    for j = 1, #line.effect_columns do
      if line.effect_columns[j].number_string == "0C" or line.effect_columns[j].number_string == "0L" then
        line.effect_columns[j].number_string = ""
        line.effect_columns[j].amount_string = ""
      end
    end
  end
  renoise.app():show_status("Cleared FX Column")
end

-- Clear Volume Column
function clear_volume_column()
  if not renoise.song() then return end

  local pattern = renoise.song().selected_pattern
  local track_index = renoise.song().selected_track_index
  local track = renoise.song().selected_track

  for i = 1, max_rows do
    local line = pattern:track(track_index):line(i)
    for j = 1, track.visible_note_columns do
      line:note_column(j).volume_string = ""
    end
  end
  renoise.app():show_status("Cleared Volume Column")
end

-- Clear Panning Column
function clear_panning_column()
  if not renoise.song() then return end

  local pattern = renoise.song().selected_pattern
  local track_index = renoise.song().selected_track_index
  local track = renoise.song().selected_track

  for i = 1, max_rows do
    local line = pattern:track(track_index):line(i)
    for j = 1, track.visible_note_columns do
      line:note_column(j).panning_string = ""
    end
  end
  renoise.app():show_status("Cleared Panning Column")
end

-- Clear Retrig
function clear_retrig()
  if not renoise.song() then return end

  local pattern = renoise.song().selected_pattern
  local track_index = renoise.song().selected_track_index

  for i = 1, max_rows do
    local line = pattern:track(track_index):line(i)
    line.effect_columns[2].number_string = ""
    line.effect_columns[2].amount_string = ""
  end
  renoise.app():show_status("Cleared Retrig Effect")
end

-- Clear Playback Effect
function clear_playback_effect()
  if not renoise.song() then return end

  local pattern = renoise.song().selected_pattern
  local track_index = renoise.song().selected_track_index

  for i = 1, max_rows do
    local line = pattern:track(track_index):line(i)
    line.effect_columns[3].number_string = ""
    line.effect_columns[3].amount_string = ""
  end
  renoise.app():show_status("Cleared Playback Effect")
end

-- Clear Effect Column 4
function clear_effect_column_4()
  if not renoise.song() then return end

  local pattern = renoise.song().selected_pattern
  local track_index = renoise.song().selected_track_index

  for i = 1, max_rows do
    local line = pattern:track(track_index):line(i)
    if line.effect_columns[4] then
      if line.effect_columns[4].number_string == "0P" then
        line.effect_columns[4].number_string = ""
        line.effect_columns[4].amount_string = ""
      end
    end
  end
  renoise.app():show_status("Cleared Effect Column 4")
end

function insert_commands()
  max_rows = renoise.song().selected_pattern.number_of_lines

  if not renoise.song() then return end

  local pattern = renoise.song().selected_pattern
  local track = renoise.song().selected_track
  local track_index = renoise.song().selected_track_index
  local visible_note_columns = track.visible_note_columns

  if retrig_column_choice == "FX Column" then
    clear_retrig()
  elseif retrig_column_choice == "Volume Column" then
    clear_volume_column()
  elseif retrig_column_choice == "Panning Column" then
    clear_panning_column()
  end

  -- Ensure effect columns are visible
  if track.visible_effect_columns < 4 then
    track.visible_effect_columns = 4
  end

  -- We will only write the first 16 steps
  local steps_to_write = num_checkboxes

  -- Volume handling
  local any_checkbox_checked = false
  for i = 1, num_checkboxes do
    if checkboxes[i].value then
      any_checkbox_checked = true
      break
    end
  end

  if any_checkbox_checked then
    for i = 1, steps_to_write do
      local line = pattern:track(track_index):line(i)
      if column_choice == "FX Column" then
        if checkboxes[i].value then
          line.effect_columns[1].number_string = "0C"
          line.effect_columns[1].amount_string = "0F"
        else
          line.effect_columns[1].number_string = "0C"
          line.effect_columns[1].amount_string = "00"
        end
      elseif column_choice == "Volume Column" then
        track.volume_column_visible = true
        for j = 1, visible_note_columns do
          local note_column = line:note_column(j)
          if checkboxes[i].value then
            note_column.volume_string = "80"
          else
            note_column.volume_string = "00"
          end
        end
      elseif column_choice == "FX Column (L00)" then
        if checkboxes[i].value then
          line.effect_columns[1].number_string = "0L"
          line.effect_columns[1].amount_string = "C0"
        else
          line.effect_columns[1].number_string = "0L"
          line.effect_columns[1].amount_string = "00"
        end
      end
    end
  else
    -- Do nothing if all checkboxes are empty
    print("No volume checkboxes are checked; skipping output.")
  end

  -- Panning handling
  local all_panning_center = true
  for i = 1, num_checkboxes do
    if panning_left_checkboxes[i].value or panning_right_checkboxes[i].value then
      all_panning_center = false
      break
    end
  end

  if not all_panning_center then
    for i = 1, steps_to_write do
      local line = pattern:track(track_index):line(i)
      if panning_column_choice == "Panning Column" then
        renoise.song().selected_track.panning_column_visible = true
        if panning_left_checkboxes[i].value then
          line:note_column(1).panning_string = "00"
        elseif panning_right_checkboxes[i].value then
          line:note_column(1).panning_string = "80"
        else
          line:note_column(1).panning_string = "40"
        end
      elseif panning_column_choice == "FX Column" then
        if panning_left_checkboxes[i].value then
          line.effect_columns[4].number_string = "0P"
          line.effect_columns[4].amount_string = "00"
        elseif panning_right_checkboxes[i].value then
          line.effect_columns[4].number_string = "0P"
          line.effect_columns[4].amount_string = "FF"
        else
          line.effect_columns[4].number_string = "0P"
          line.effect_columns[4].amount_string = "7F"
        end
      end
    end
  else
    -- Do nothing if all panning checkboxes are set to center
    print("Panning Gater: All steps are center; no output generated.")
    -- Optionally, you can clear the panning effect columns here
  end

  -- Retrig handling
  local retrig_is_empty = true
  for i = 1, num_checkboxes do
    if retrig_checkboxes[i].value then
      retrig_is_empty = false
      break
    end
  end

  if not retrig_is_empty then
    for i = 1, steps_to_write do
      local line = pattern:track(track_index):line(i)

      if retrig_checkboxes[i].value then
        if retrig_column_choice == "FX Column" then
          line.effect_columns[2].number_string = "0R"
          line.effect_columns[2].amount_string = string.format("%02X", retrig_value)
        elseif retrig_column_choice == "Volume Column" then
          track.volume_column_visible = true
          for j = 1, visible_note_columns do
            local note_column = line:note_column(j)
            note_column.volume_string = string.format("R%X", retrig_value)
          end
        elseif retrig_column_choice == "Panning Column" then
          renoise.song().selected_track.panning_column_visible = true
          for j = 1, visible_note_columns do
            local note_column = line:note_column(j)
            note_column.panning_string = string.format("R%X", retrig_value)
          end
        end
      end
    end
  else
    print("Retrig Gater: No retrig values set; no output generated.")
  end

  -- Playback handling
  local any_playback_checked = false
  for i = 1, num_checkboxes do
    if playback_checkboxes[i].value then
      any_playback_checked = true
      break
    end
  end

  if any_playback_checked then
    for i = 1, steps_to_write do
      local line = pattern:track(track_index):line(i)
      -- Ensure the third effect column is visible
      if track.visible_effect_columns < 3 then
        track.visible_effect_columns = 4
      end

      if playback_checkboxes[i].value then
        line.effect_columns[3].number_string = "0B"
        line.effect_columns[3].amount_string = "00"
      else
        line.effect_columns[3].number_string = "0B"
        line.effect_columns[3].amount_string = "01"
      end
    end
  else
    -- Do nothing if all playback checkboxes are unchecked
    print("No playback checkboxes are checked; skipping output.")
  end

  -- After writing the first 16 steps, replicate them to fill the pattern
  PakettiReplicateAtCursorGater(0, "selected_track", "above_and_current")

  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

function PakettiReplicateAtCursorGater(transpose, tracks_option, row_option)
  local song = renoise.song()
  local pattern = song.selected_pattern
  local cursor_row = num_checkboxes -- Start from after the initial 16 steps
  local pattern_length = pattern.number_of_lines

  -- Determine the repeat_length and starting row based on row_option
  local repeat_length, start_row
  if row_option == "above_current" then
    if cursor_row == 1 then
      renoise.app():show_status("You are on the first row, nothing to replicate.")
      return
    end
    repeat_length = cursor_row - 1
    start_row = cursor_row
  elseif row_option == "above_and_current" then
    repeat_length = cursor_row
    start_row = cursor_row + 1
    if cursor_row == pattern_length then
      renoise.app():show_status("You are on the last row, nothing to replicate.")
      return
    end
  else
    renoise.app():show_status("Invalid row option: " .. tostring(row_option))
    return
  end

  if repeat_length == 0 then
    renoise.app():show_status("No rows to replicate.")
    return
  end

  transpose = transpose or 0

  local function transpose_note(note_value, transpose_amount)
    local min_note = 0
    local max_note = 119

    if note_value >= min_note and note_value <= max_note then
      local new_note = note_value + transpose_amount
      if new_note > max_note then
        new_note = max_note
      elseif new_note < min_note then
        new_note = min_note
      end
      return new_note
    else
      return note_value
    end
  end

  -- Function to replicate content on a track
  local function replicate_on_track(track_index)
    for row = start_row, pattern_length do
      local source_row = ((row - start_row) % repeat_length) + 1
      local source_line = pattern:track(track_index):line(source_row)
      local dest_line = pattern:track(track_index):line(row)

      -- Copy note columns subcolumns only (volume, panning, delay)
      for col = 1, #source_line.note_columns do
        local source_note = source_line.note_columns[col]
        local dest_note = dest_line.note_columns[col]

        -- Leave note and instrument values untouched
        dest_note.volume_value = source_note.volume_value
        dest_note.panning_value = source_note.panning_value
        dest_note.delay_value = source_note.delay_value
      end

      -- Copy effect columns
      for col = 1, #source_line.effect_columns do
        local source_effect = source_line.effect_columns[col]
        local dest_effect = dest_line.effect_columns[col]

        dest_effect:copy_from(source_effect)
      end
    end
  end

  if tracks_option == "all_tracks" then
    for track_index = 1, #pattern.tracks do
      replicate_on_track(track_index)
    end
  elseif tracks_option == "selected_track" then
    local selected_track_index = song.selected_track_index
    replicate_on_track(selected_track_index)
  else
    renoise.app():show_status("Invalid tracks option: " .. tostring(tracks_option))
    return
  end

  renoise.app():show_status("Replicated content with transpose: " .. transpose)
end

-- Preset functionality
local function apply_preset(preset, is_retrig, is_playback)
  if not renoise.song() then return end

  initializing = true

  local preset_state = {}
  if preset == "all" then
    preset_state = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
  elseif preset == "every_2nd" then
    preset_state = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0}
  elseif preset == "every_third" then
    preset_state = {1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1}
  elseif preset == "every_fourth" then
    preset_state = {1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0}
  elseif preset == "jaguar" then
    preset_state = {1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0}
  elseif preset == "caapi" then
    preset_state = {1,0,1,0,1,0,1,0,1,1,1,0,1,1,1,0}
  elseif preset == "none" then
    preset_state = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  end

  if is_retrig then
    for i = 1, num_checkboxes do
      retrig_checkboxes[i].value = preset_state[i] == 1
    end
  elseif is_playback then
    for i = 1, num_checkboxes do
      playback_checkboxes[i].value = preset_state[i] == 1
    end
  else
    for i = 1, num_checkboxes do
      checkboxes[i].value = preset_state[i] == 1
    end
  end

  initializing = false
  insert_commands()
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Custom key handler function
local function my_keyhandler_func(dialog, key)
  local closer = "esc"
  if key.modifiers == "" and key.name == closer then
    dialog:close()
    dialog = nil
    return
  else 
    return key
  end
end

-- Create the dialog
function pakettiGaterDialog()
  if dialog and dialog.visible then
    dialog:close()
    dialog = nil
    return
  end

  initializing = true -- Start initialization

  initialize_checkboxes(num_checkboxes)
  local content = vb:column {
    vb:text { text = "Volume Gater", font = "bold" },
    vb:switch {
      items = { "FX Column (C00)", "Volume Column", "FX Column (L00)" },
      value = 1,
      width = 300,
      notifier = function(index)
        column_choice = (index == 1) and "FX Column" or (index == 2) and "Volume Column" or "FX Column (L00)"
        if not initializing then
          insert_commands()
        end
      end
    },
    vb:row {
      buttons[1], buttons[2], buttons[3], buttons[4], buttons[5], buttons[6], buttons[7], buttons[8],
      buttons[9], buttons[10], buttons[11], buttons[12], buttons[13], buttons[14], buttons[15], buttons[16],
      vb:valuebox {
        min = 1,
        max = num_checkboxes,
        value = active_steps_volume,
        width = 50,
        notifier = set_active_steps_volume
      }
    },
    vb:row(checkboxes),
    vb:row {
      vb:button { text = "Clear", pressed = clear_volume_gater },
      vb:button { text = "Random", pressed = rand_volume_checkboxes },
      vb:button { text = "<", pressed = function() shift_checkboxes("left") end },
      vb:button { text = ">", pressed = function() shift_checkboxes("right") end },
      vb:button { text = "<<", pressed = function()
        shift_checkboxes("left")
        shift_retrig_checkboxes("left")
        shift_playback_checkboxes("left")
        shift_panning_checkboxes("left")
      end },
      vb:button { text = ">>", pressed = function()
        shift_checkboxes("right")
        shift_retrig_checkboxes("right")
        shift_playback_checkboxes("right")
        shift_panning_checkboxes("right")
      end },
      vb:button { text = "Clear FX Column", pressed = clear_effect_columns },
      vb:button { text = "Clear Volume Column", pressed = clear_volume_column },
      vb:button { text = "Receive", pressed = receive_volume_checkboxes }
    },
    vb:row {
      vb:button { text = "All", pressed = function() apply_preset("all", false, false) end },
      vb:button { text = "Every 2nd", pressed = function() apply_preset("every_2nd", false, false) end },
      vb:button { text = "Every 3rd", pressed = function() apply_preset("every_third", false, false) end },
      vb:button { text = "Every 4th", pressed = function() apply_preset("every_fourth", false, false) end },
      vb:button { text = "Jaguar", pressed = function() apply_preset("jaguar", false, false) end},
      vb:button { text = "Caapi", pressed = function() apply_preset("caapi", false, false) end} 
    },
    vb:text { text = "Retrig Gater", font = "bold" },
    vb:row {
      vb:valuebox {
        min = 1,
        max = 15,
        value = retrig_value,
        width = 50,
        tooltip = "Retrig Speed",
        notifier = function(value)
          retrig_value = value
          if not initializing then
            insert_commands()
          end
        end
      },
      vb:text { text = "Retrig Speed" }
    },
    vb:switch {
      items = { "FX Column", "Volume Column", "Panning Column" },
      value = 1,
      width = 300,
      notifier = function(index)
        retrig_column_choice = (index == 1) and "FX Column" or (index == 2) and "Volume Column" or "Panning Column"
        if not initializing then
          insert_commands()
        end
      end
    },
    vb:row {
      retrig_buttons[1], retrig_buttons[2], retrig_buttons[3], retrig_buttons[4], retrig_buttons[5], retrig_buttons[6], retrig_buttons[7], retrig_buttons[8],
      retrig_buttons[9], retrig_buttons[10], retrig_buttons[11], retrig_buttons[12], retrig_buttons[13], retrig_buttons[14], retrig_buttons[15], retrig_buttons[16],
      vb:valuebox {
        min = 1,
        max = num_checkboxes,
        value = active_steps_retrig,
        width = 50,
        notifier = set_active_steps_retrig
      }
    },
    vb:row(retrig_checkboxes),
    vb:row {
      vb:button { text = "Clear", pressed = clear_retrig_checkboxes },
      vb:button { text = "Random", pressed = rand_retrig_checkboxes },
      vb:button { text = "<", pressed = function() shift_retrig_checkboxes("left") end },
      vb:button { text = ">", pressed = function() shift_retrig_checkboxes("right") end },
      vb:button { text = "Receive", pressed = receive_retrig_checkboxes }
    },
    vb:text { text = "Playback Direction Gater", font = "bold" },
    vb:row {
      playback_buttons[1], playback_buttons[2], playback_buttons[3], playback_buttons[4], playback_buttons[5], playback_buttons[6], playback_buttons[7], playback_buttons[8],
      playback_buttons[9], playback_buttons[10], playback_buttons[11], playback_buttons[12], playback_buttons[13], playback_buttons[14], playback_buttons[15], playback_buttons[16],
      vb:valuebox {
        min = 1,
        max = num_checkboxes,
        value = active_steps_playback,
        width = 50,
        notifier = set_active_steps_playback
      }
    },
    vb:row(playback_checkboxes),
    vb:row {
      vb:button { text = "Clear", pressed = clear_playback_checkboxes },
      vb:button { text = "Random", pressed = rand_playback_checkboxes },
      vb:button { text = "<", pressed = function() shift_playback_checkboxes("left") end },
      vb:button { text = ">", pressed = function() shift_playback_checkboxes("right") end },
      vb:button { text = "Receive", pressed = receive_playback_checkboxes }
    },
    vb:text { text = "Panning Gater", font = "bold" },
    vb:switch {
      items = { "FX Column", "Panning Column" },
      value = 1,
      width = 300,
      notifier = function(index)
        panning_column_choice = (index == 1) and "FX Column" or "Panning Column"
        if not initializing then
          insert_commands()
        end
      end
    },
    vb:row {
      panning_buttons[1], panning_buttons[2], panning_buttons[3], panning_buttons[4], panning_buttons[5], 
      panning_buttons[6], panning_buttons[7], panning_buttons[8], panning_buttons[9], 
      panning_buttons[10], panning_buttons[11], panning_buttons[12], panning_buttons[13], 
      panning_buttons[14], panning_buttons[15], panning_buttons[16],
      vb:valuebox {
        min = 1,
        max = num_checkboxes,
        value = active_steps_panning,
        width = 50,
        notifier = set_active_steps_panning
      }
    },
    vb:row(panning_left_checkboxes),
    vb:row(panning_center_checkboxes),
    vb:row(panning_right_checkboxes),
    vb:row {
      vb:button { text = "Clear", pressed = clear_panning_checkboxes },
      vb:button { text = "Random", pressed = rand_panning_checkboxes },
      vb:button { text = "<", pressed = function() shift_panning_checkboxes("left") end },
      vb:button { text = ">", pressed = function() shift_panning_checkboxes("right") end },
      vb:button { text = "Receive", pressed = receive_panning_checkboxes },
    },
    vb:row {
      vb:button { text = "Global <<", pressed = function()
        shift_checkboxes("left")
        shift_retrig_checkboxes("left")
        shift_playback_checkboxes("left")
        shift_panning_checkboxes("left")
      end },
      vb:button { text = "Global >>", pressed = function()
        shift_checkboxes("right")
        shift_retrig_checkboxes("right")
        shift_playback_checkboxes("right")
        shift_panning_checkboxes("right")
      end },
      vb:button { text = "Global Receive", pressed = function()
        initializing = true
        receive_volume_checkboxes()
        receive_retrig_checkboxes()
        receive_playback_checkboxes()
        receive_panning_checkboxes()
        initializing = false
        insert_commands()
      end }
    }
  }

  dialog = renoise.app():show_custom_dialog("Paketti Volume/Retrig/Playback/Panning Gater", content, my_keyhandler_func)
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  initializing = false -- End initialization
end

-- Handle scenario when the dialog is closed by other means
renoise.app().window.active_middle_frame_observable:add_notifier(function()
  if dialog and not dialog.visible then
    dialog = nil
  end
end)

-- Keybinding function
renoise.tool():add_keybinding{name="Global:Paketti:Paketti Gater Dialog...", invoke = function()
  max_rows = renoise.song().selected_pattern.number_of_lines
  if renoise.song() then
    pakettiGaterDialog()
    renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
  end
end}

renoise.tool():add_keybinding{name="Global:Paketti:Paketti Gater Insert Commands", invoke=function() insert_commands() end}

renoise.tool():add_midi_mapping{name="Paketti:Paketti Gater Insert Commands", invoke=function(message)
  if message:is_trigger() then
    insert_commands()
  end
end}





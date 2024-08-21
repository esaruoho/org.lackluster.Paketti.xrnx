local vb = renoise.ViewBuilder()
local dialog
local checkboxes = {}
local retrig_checkboxes = {}
local num_checkboxes = 16
local max_rows = 64
local column_choice = "FX Column"
local retrig_value = 4
local retrig_column_choice = "FX Column"
local active_steps_volume = num_checkboxes -- Default to all checkboxes active
local active_steps_retrig = num_checkboxes -- Default to all checkboxes active

-- Colors for buttons
local normal_color = nil
local highlight_color = {0x22, 0xaa, 0xff} -- Custom highlight color for specific buttons

-- Initialize buttons and checkboxes
local buttons = {}
local retrig_buttons = {}
local function initialize_checkboxes(count)
  checkboxes = {}
  retrig_checkboxes = {}
  buttons = {}
  retrig_buttons = {}
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
    checkboxes[i] = vb:checkbox {
      value = false,
      width = 30,
      notifier = function()
        renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
      end
    }
    retrig_checkboxes[i] = vb:checkbox {
      value = false,
      width = 30,
      notifier = function()
        renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
      end
    }
  end
end

initialize_checkboxes(num_checkboxes)

-- Set active steps based on the valuebox
local function set_active_steps_volume(value)
  active_steps_volume = value
end

local function set_active_steps_retrig(value)
  active_steps_retrig = value
end

-- Receive Volume checkboxes state
local function receive_volume_checkboxes()
  if not renoise.song() then return end

  local pattern = renoise.song().selected_pattern
  local track_index = renoise.song().selected_track_index
  local track = renoise.song().selected_track
  local visible_note_columns = track.visible_note_columns

  for i = 1, num_checkboxes do
    local line_index = 1 + i -1
--    local line_index = renoise.song().selected_line_index + i - 1
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
end

-- Receive Retrig checkboxes state
local function receive_retrig_checkboxes()
  if not renoise.song() then return end

  local pattern = renoise.song().selected_pattern
  local track_index = renoise.song().selected_track_index
  local track = renoise.song().selected_track
  local visible_note_columns = track.visible_note_columns

  for i = 1, num_checkboxes do
    local line_index = 1 + i -1
--    local line_index = renoise.song().selected_line_index + i - 1
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
end

-- Clear Volume Gater
local function clear_volume_gater()
  if not renoise.song() then return end

  for i = 1, num_checkboxes do
    checkboxes[i].value = false
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Clear Retrig checkboxes
local function clear_retrig_checkboxes()
  if not renoise.song() then return end

  for i = 1, num_checkboxes do
    retrig_checkboxes[i].value = false
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
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
end

-- Clear Volume Column
local function clear_volume_column()
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

-- Clear Panning Column for Retrig
local function clear_panning_column()
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

-- Clear Effect Columns
local function clear_effect_columns()
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

-- Clear Retrig
local function clear_retrig()
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

-- Insert commands into the selected track
local function insert_commands()
  max_rows=renoise.song().selected_pattern.number_of_lines


  if not renoise.song() then return end

  local pattern = renoise.song().selected_pattern
  local track = renoise.song().selected_track
  local track_index = renoise.song().selected_track_index
  local visible_note_columns = track.visible_note_columns

  -- Ensure effect columns are visible
  if track.visible_effect_columns < 2 then
    track.visible_effect_columns = 2
  end

  -- Volume handling
  local volume_is_empty = true
  for i = 1, max_rows do
    local line = pattern:track(track_index):line(i)
    if column_choice == "FX Column" then
      if checkboxes[(i - 1) % active_steps_volume + 1].value then
        volume_is_empty = false
        line.effect_columns[1].number_string = "0C"
        line.effect_columns[1].amount_string = "0F"
      elseif not volume_is_empty then
        line.effect_columns[1].number_string = "0C"
        line.effect_columns[1].amount_string = "00"
      end
    elseif column_choice == "Volume Column" then
      track.volume_column_visible = true
      for j = 1, visible_note_columns do
        local note_column = line:note_column(j)
        if checkboxes[(i - 1) % active_steps_volume + 1].value then
          volume_is_empty = false
          note_column.volume_string = "80"
        elseif not volume_is_empty then
          note_column.volume_string = "00"
        end
      end
    elseif column_choice == "FX Column (L00)" then
      if checkboxes[(i - 1) % active_steps_volume + 1].value then
        volume_is_empty = false
        line.effect_columns[1].number_string = "0L"
        line.effect_columns[1].amount_string = "C0"
      else
        line.effect_columns[1].number_string = "0L"
        line.effect_columns[1].amount_string = "00"
      end
    end
  end
  if volume_is_empty then
    print("Volume Gater: No volume values set; no output generated.")
  end

  -- Retrig handling
  local retrig_is_empty = true
  for i = 1, max_rows do
    local line = pattern:track(track_index):line(i)
    if retrig_checkboxes[(i - 1) % active_steps_retrig + 1].value then
      retrig_is_empty = false
      if retrig_column_choice == "FX Column" then
        line.effect_columns[2].number_string = "0R"
        line.effect_columns[2].amount_string = string.format("%02X", retrig_value)
      elseif retrig_column_choice == "Volume Column" then
        for j = 1, visible_note_columns do
          local note_column = line:note_column(j)
          note_column.volume_string = string.format("R%X", retrig_value)
        end
      elseif retrig_column_choice == "Panning Column" then
        track.panning_column_visible = true
        for j = 1, visible_note_columns do
          local note_column = line:note_column(j)
          note_column.panning_string = string.format("R%X", retrig_value)
        end
      end
    else
      if retrig_column_choice == "FX Column" then
        line.effect_columns[2].number_string = ""
        line.effect_columns[2].amount_string = ""
      elseif retrig_column_choice == "Volume Column" then
        for j = 1, visible_note_columns do
          local note_column = line:note_column(j)
          note_column.volume_string = ""
        end
      elseif retrig_column_choice == "Panning Column" then
        for j = 1, visible_note_columns do
          local note_column = line:note_column(j)
          note_column.panning_string = ""
        end
      end
    end
  end
  if retrig_is_empty then
    print("Retrig Gater: No retrig values set; no output generated.")
  end
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Preset functionality
local function apply_preset(preset, is_retrig)
  if not renoise.song() then return end

  local preset_state = {}
  if preset == "all" then
    preset_state = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
  elseif preset == "every_2nd" then
    preset_state = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0}
  elseif preset == "every_third" then
    preset_state = {1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1}
  elseif preset == "every_fourth" then
    preset_state = {1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0}
  elseif preset == "none" then
    preset_state = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  end

  if is_retrig then
    for i = 1, num_checkboxes do
      retrig_checkboxes[i].value = preset_state[i] == 1
    end
  else
    for i = 1, num_checkboxes do
      checkboxes[i].value = preset_state[i] == 1
    end
  end

  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

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

-- Create the dialog
function pakettiGaterDialog()
  if dialog and dialog.visible then
    dialog:close()
    dialog = nil
    return
  end

  initialize_checkboxes(num_checkboxes)
  local content = vb:column {
    vb:text { text = "Volume Gater", font = "bold" },
    vb:switch {
      items = { "FX Column (C00)", "Volume Column", "FX Column (L00)" },
      value = 1,
      width = 300,
      notifier = function(index)
        column_choice = (index == 1) and "FX Column" or (index == 2) and "Volume Column" or "FX Column (L00)"
      end
    },
    vb:row {
      -- Manually adding each button to avoid using unpack
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
      vb:button { text = "Randomize", pressed = rand_volume_checkboxes },
      vb:button { text = "<<", pressed = function() shift_checkboxes("left") end },
      vb:button { text = ">>", pressed = function() shift_checkboxes("right") end },
      vb:button { text = "Clear FX Column", pressed = clear_effect_columns },
      vb:button { text = "Clear Volume Column", pressed = clear_volume_column },
      vb:button { text = "Receive", pressed = receive_volume_checkboxes }
    },
    vb:row {
      vb:button { text = "None", pressed = function() apply_preset("none", false) end },
      vb:button { text = "All", pressed = function() apply_preset("all", false) end },
      vb:button { text = "Every 2nd", pressed = function() apply_preset("every_2nd", false) end },
      vb:button { text = "Every 3rd", pressed = function() apply_preset("every_third", false) end },
      vb:button { text = "Every 4th", pressed = function() apply_preset("every_fourth", false) end }
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
      end
    },
    vb:row {
      -- Manually adding each retrig button to avoid using unpack
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
      vb:button { text = "Randomize", pressed = rand_retrig_checkboxes },
      vb:button { text = "<<", pressed = function() shift_retrig_checkboxes("left") end },
      vb:button { text = ">>", pressed = function() shift_retrig_checkboxes("right") end },
      vb:button { text = "Clear FX Column", pressed = clear_retrig },
      vb:button { text = "Clear Volume Column", pressed = clear_volume_column },
      vb:button { text = "Clear Panning Column", pressed = clear_panning_column },
      vb:button { text = "Receive", pressed = receive_retrig_checkboxes }
    },
    vb:row {vb:button { text = "LPB*2", pressed = function() cloneAndExpandPatternToLPBDouble() end}, vb:button { text = "LPB/2", pressed = 
    function() 
    cloneAndShrinkPatternToLPBHalve() end }},
    vb:button { text = "Print", pressed = insert_commands }
  }

  dialog = renoise.app():show_custom_dialog("Paketti Volume/Retrig Gater", content, my_keyhandler_func)
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
end

-- Handle scenario when the dialog is closed by other means
renoise.app().window.active_middle_frame_observable:add_notifier(function()
  if dialog and not dialog.visible then
    dialog = nil
  end
end)

-- Keybinding function
renoise.tool():add_keybinding{name="Global:Paketti:Paketti Gater Dialog...",invoke = function()
  max_rows=renoise.song().selected_pattern.number_of_lines
    if renoise.song() then
      pakettiGaterDialog()
      renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
    end
  end
}

